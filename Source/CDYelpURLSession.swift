import Foundation

actor CDYelpURLSession {
    private let session: URLSession
    private let makeDecoder: () -> JSONDecoder
    private let cache: CDYelpResponseCache?
    private let monitors: [any CDYelpEventMonitor]
    private let adapters: [any CDYelpRequestAdapter]
    private let retryConfig: CDYelpRetryConfiguration
    private var retrySleepTasks: [UUID: Task<Void, Error>] = [:]

    init(
        session: URLSession,
        makeDecoder: @escaping () -> JSONDecoder,
        cache: CDYelpResponseCache?,
        monitors: [any CDYelpEventMonitor],
        adapters: [any CDYelpRequestAdapter],
        retryConfig: CDYelpRetryConfiguration
    ) {
        self.session = session
        self.makeDecoder = makeDecoder
        self.cache = cache
        self.monitors = monitors
        self.adapters = adapters
        self.retryConfig = retryConfig
    }

    /// A request that failed to construct entirely (e.g. a non-finite query parameter, a JSON
    /// body-encoding failure) has no real `URLRequest` to notify monitors with. Using this fixed,
    /// non-throwing placeholder — rather than skipping notification — keeps the "every logical
    /// call fires a paired requestDidStart/requestDidComplete" invariant true even for failures
    /// that occur before a request exists, matching the adapter-failure path below.
    private static let placeholderRequestURL = URL(string: CDYelpURL.base) ?? URL(fileURLWithPath: "/")

    func perform<T: Decodable>(
        buildRequest: () throws -> URLRequest,
        decoder: JSONDecoder? = nil,
        cacheable: Bool = true
    ) async throws -> T {
        let builtRequest: URLRequest
        do {
            builtRequest = try buildRequest()
        } catch {
            // buildRequest (CDYelpRouter.asURLRequest) already throws a wrapped CDYelpNetworkError
            // for every one of its own failure sites — don't wrap it a second time.
            let networkError = (error as? CDYelpNetworkError) ?? .invalidRequest(underlying: error)
            let placeholderRequest = URLRequest(url: Self.placeholderRequestURL)
            // Fire start before complete so the monitor lifecycle is always paired, matching the
            // adapter-failure path below even though no real URLRequest exists yet.
            notifyStart(placeholderRequest)
            notifyComplete(placeholderRequest, response: nil, data: nil, error: networkError)
            throw networkError
        }
        // One-time setup, run exactly once per logical API call regardless of how many retry
        // attempts occur below: the adapter chain, header restoration, and cache lookup.
        var request = builtRequest
        let originalHeaders = builtRequest.allHTTPHeaderFields ?? [:]
        do {
            for adapter in adapters {
                request = try adapter.adapt(request)
            }
        } catch {
            // A custom adapter may deliberately throw a typed CDYelpNetworkError itself; don't
            // relabel it as .invalidRequest by wrapping it a second time.
            let networkError = (error as? CDYelpNetworkError) ?? .invalidRequest(underlying: error)
            // Fire start before complete so the monitor lifecycle is always paired.
            notifyStart(request)
            notifyComplete(request, response: nil, data: nil, error: networkError)
            throw networkError
        }
        // Re-inject any framework-set header an adapter inadvertently removed entirely — not
        // just the handful of headers CDYelpRouter happens to set today. An adapter that sets a
        // different value for a given header (e.g. token rotation) keeps its replacement; only
        // headers missing from the adapted request are restored from their original value.
        for (header, originalValue) in originalHeaders {
            restoreHeaderIfStripped(header, originalValue: originalValue, in: &request)
        }

        // .uppercased() matches the normalization shouldRetry uses for idempotentHTTPMethods.
        // URLRequest.httpMethod's own setter already uppercases on assignment (confirmed: even
        // an adapter that assigns "get" ends up with "GET"), so this is defense-in-depth rather
        // than a fix for a reachable bug — kept for consistency between the two checks.
        let cacheKey: String? = (cacheable && request.httpMethod?.uppercased() == "GET" && cache != nil) ? CDYelpCacheKey.key(for: request) : nil
        if let cacheKey, let cache, let cached = cache.data(forKey: cacheKey) {
            let decoded: T? = try? decodeWrapping(cached, decoder: decoder)
            if let decoded {
                notifyStart(request)
                notifyComplete(request, response: nil, data: cached, error: nil)
                return decoded
            }
            // Evict the undecodable entry and fall through to a live network fetch below — a
            // corrupt/stale cache entry (e.g. a model shape change after an app update) should
            // not fail the caller when the network can serve a fresh response right now. No
            // notifyStart/notifyComplete here: the single pair below covers this logical request.
            cache.remove(forKey: cacheKey)
        }

        // requestDidStart fires once per logical request, regardless of retry count.
        notifyStart(request)

        var attempt: UInt = 0
        while true {
            let data: Data
            let httpResponse: HTTPURLResponse?
            do {
                let (responseData, response) = try await session.data(for: request)
                data = responseData
                httpResponse = response as? HTTPURLResponse
            } catch {
                let networkError = CDYelpNetworkError.networkFailure(underlying: error)
                try await retryOrThrow(networkError, request: request, attempt: &attempt, response: nil, data: nil)
                continue
            }

            // Guard before notifying monitors so non-HTTP responses don't produce a false success signal.
            // Routed through retryOrThrow like every other failure path below, so a transport that
            // occasionally hands back a non-HTTP URLResponse still benefits from retry/backoff.
            guard let httpResponse else {
                let error = CDYelpNetworkError.networkFailure(underlying: URLError(.badServerResponse))
                try await retryOrThrow(error, request: request, attempt: &attempt, response: nil, data: data)
                continue
            }

            let statusCode = httpResponse.statusCode
            guard (200 ..< 300).contains(statusCode) else {
                let error = CDYelpNetworkError.httpError(statusCode: statusCode, data: data, headers: httpResponse.stringHeaderFields)
                try await retryOrThrow(error, request: request, attempt: &attempt, response: httpResponse, data: data)
                continue
            }

            let decoded: T
            do {
                decoded = try decodeWrapping(data, decoder: decoder)
            } catch {
                notifyComplete(request, response: httpResponse, data: data, error: error)
                throw error
            }
            notifyComplete(request, response: httpResponse, data: data, error: nil)
            if let cacheKey {
                cache?.set(data: data, forKey: cacheKey)
            }
            return decoded
        }
    }

    /// Shared retry-or-throw path for both the transport-error and HTTP-status-error cases:
    /// returns (having slept for backoff, notified monitors, and advanced `attempt`) if the
    /// caller should retry, or notifies monitors of the terminal failure and throws `error` (or
    /// a cancellation error from the backoff sleep itself) if it shouldn't. Owns incrementing
    /// `attempt` itself so every call site doesn't have to repeat `attempt += 1` after this returns.
    private func retryOrThrow(
        _ error: CDYelpNetworkError,
        request: URLRequest,
        attempt: inout UInt,
        response: HTTPURLResponse?,
        data: Data?
    ) async throws {
        guard shouldRetry(error, httpMethod: request.httpMethod, attempt: attempt) else {
            notifyComplete(request, response: response, data: data, error: error)
            throw error
        }
        notifyRetry(request, retryCount: Int(attempt + 1))
        do {
            try await trackedSleep(nanoseconds: backoffNanoseconds(attempt: attempt, error: error))
        } catch {
            notifyComplete(request, response: response, data: data, error: error)
            throw error
        }
        attempt += 1
    }

    private func restoreHeaderIfStripped(_ header: String, originalValue: String?, in request: inout URLRequest) {
        guard let originalValue, request.value(forHTTPHeaderField: header) == nil else { return }
        request.setValue(originalValue, forHTTPHeaderField: header)
    }

    private func notifyStart(_ request: URLRequest) {
        for monitor in monitors {
            monitor.requestDidStart(urlRequest: request)
        }
    }

    private func notifyComplete(_ request: URLRequest, response: HTTPURLResponse?, data: Data?, error: Error?) {
        for monitor in monitors {
            monitor.requestDidComplete(urlRequest: request, response: response, data: data, error: error)
        }
    }

    private func notifyRetry(_ request: URLRequest, retryCount: Int) {
        for monitor in monitors {
            monitor.requestWillRetry(urlRequest: request, retryCount: retryCount)
        }
    }

    private func trackedSleep(nanoseconds: UInt64) async throws {
        let id = UUID()
        let task = Task<Void, Error> { try await Task.sleep(nanoseconds: nanoseconds) }
        retrySleepTasks[id] = task
        defer {
            task.cancel()
            retrySleepTasks.removeValue(forKey: id)
        }
        do {
            // withTaskCancellationHandler forwards cancellation of the caller's ambient Task
            // (e.g. `Task { try await client.searchBusinesses(...) }.cancel()`) into the
            // detached sleep task, which otherwise wouldn't observe it — an unstructured
            // Task's cancellation state isn't linked to the task that created it.
            try await withTaskCancellationHandler {
                try await task.value
            } onCancel: {
                task.cancel()
            }
        } catch {
            // Wrap so cancellation during backoff still honors the documented
            // "Throws: CDYelpNetworkError" contract on every public API method.
            throw CDYelpNetworkError.networkFailure(underlying: error)
        }
    }

    private func decodeWrapping<T: Decodable>(_ data: Data, decoder: JSONDecoder?) throws -> T {
        do {
            return try (decoder ?? makeDecoder()).decode(T.self, from: data)
        } catch {
            throw CDYelpNetworkError.decodingFailed(underlying: error)
        }
    }

    /// Cancels in-progress URLSession tasks and any Tasks sleeping during retry backoff.
    /// Awaits both, so cancellation is guaranteed to be in effect by the time this returns.
    func cancelAllTasks() async {
        let (dataTasks, uploadTasks, downloadTasks) = await session.tasks
        for task in dataTasks {
            task.cancel()
        }
        for task in uploadTasks {
            task.cancel()
        }
        for task in downloadTasks {
            task.cancel()
        }
        cancelAllRetrySleepTasks()
    }

    private func cancelAllRetrySleepTasks() {
        for task in retrySleepTasks.values {
            task.cancel()
        }
        retrySleepTasks.removeAll()
    }

    nonisolated func clearCache() {
        cache?.removeAll()
    }

    /// HTTP methods safe to automatically resend without risking a duplicate side effect,
    /// matching the set Alamofire's `RetryPolicy` retried by default (notably excluding POST).
    private static let idempotentHTTPMethods: Set<String> = ["DELETE", "GET", "HEAD", "OPTIONS", "PUT", "TRACE"]

    private func shouldRetry(_ error: CDYelpNetworkError, httpMethod: String?, attempt: UInt) -> Bool {
        guard attempt < retryConfig.retryLimit else { return false }
        guard let httpMethod, Self.idempotentHTTPMethods.contains(httpMethod.uppercased()) else { return false }
        switch error {
        case let .httpError(statusCode, _, _):
            return retryConfig.retryableHTTPStatusCodes.contains(statusCode)
        case let .networkFailure(underlying):
            guard let urlError = underlying as? URLError else { return false }
            // .cancelled must never be retried, even if a caller's retryableURLErrorCodes
            // includes it — cancelAllTasks()/cancelAllPendingAPIRequests() must reliably
            // terminate an in-flight request rather than have it silently resent.
            guard urlError.code != .cancelled else { return false }
            return retryConfig.retryableURLErrorCodes.contains(urlError.code)
        default:
            return false
        }
    }

    /// Prefers a server-provided `Retry-After` header (seconds or HTTP-date form) over blind
    /// exponential backoff when the failing response supplies one, so a rate-limited endpoint
    /// that tells the client exactly how long to wait is honored instead of guessed at.
    private func backoffNanoseconds(attempt: UInt, error: CDYelpNetworkError) -> UInt64 {
        let maxDelay: TimeInterval = 300
        if case let .httpError(_, _, headers) = error, let retryAfter = Self.retryAfterInterval(from: headers) {
            return UInt64(max(0, min(retryAfter, maxDelay)) * 1_000_000_000)
        }
        let delay = min(retryConfig.initialDelay * pow(2.0, Double(attempt)), maxDelay)
        return UInt64(max(0, delay) * 1_000_000_000)
    }

    /// Parses a `Retry-After` header value per RFC 9110 §10.2.3: either a non-negative integer
    /// number of seconds, or an HTTP-date to wait until. Returns nil for anything else so the
    /// caller falls back to exponential backoff instead of trusting a malformed value.
    private static func retryAfterInterval(from headers: [String: String]) -> TimeInterval? {
        guard let value = headers.first(where: { $0.key.caseInsensitiveCompare("Retry-After") == .orderedSame })?.value else {
            return nil
        }
        if let seconds = TimeInterval(value.trimmingCharacters(in: .whitespaces)), seconds >= 0 {
            return seconds
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        guard let date = formatter.date(from: value) else { return nil }
        return max(0, date.timeIntervalSinceNow)
    }
}

extension HTTPURLResponse {
    /// Snapshots `allHeaderFields` as `[String: String]` for `CDYelpNetworkError.httpError`,
    /// dropping any non-String key/value pairs (HTTPURLResponse's header dictionary is typed
    /// as `[AnyHashable: Any]`, but HTTP header names and values are always strings in practice).
    var stringHeaderFields: [String: String] {
        let pairs = allHeaderFields.compactMap { key, value -> (String, String)? in
            guard let key = key as? String, let value = value as? String else { return nil }
            return (key, value)
        }
        // uniquingKeysWith rather than uniqueKeysWithValues: HTTPURLResponse can report the same
        // header name differing only in case (e.g. proxies/CDNs), which would otherwise trap.
        return Dictionary(pairs, uniquingKeysWith: { first, _ in first })
    }
}
