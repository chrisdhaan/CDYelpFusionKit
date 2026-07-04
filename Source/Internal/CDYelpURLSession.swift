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

    func perform<T: Decodable>(
        _ urlRequest: URLRequest,
        decoder: JSONDecoder? = nil,
        cacheable: Bool = true
    ) async throws -> T {
        try await perform(urlRequest, decoder: decoder, cacheable: cacheable, attempt: 0)
    }

    private func perform<T: Decodable>(
        _ urlRequest: URLRequest,
        decoder: JSONDecoder?,
        cacheable: Bool,
        attempt: UInt
    ) async throws -> T {
        // Run adapters only on the first attempt. On retry, urlRequest is already the adapted
        // request passed from the previous attempt, so the adapter chain runs exactly once
        // per logical API call regardless of how many retry attempts occur.
        var request = urlRequest
        if attempt == 0 {
            let authHeader = urlRequest.value(forHTTPHeaderField: "Authorization")
            do {
                for adapter in adapters {
                    request = try adapter.adapt(request)
                }
            } catch {
                let networkError = CDYelpNetworkError.invalidRequest(underlying: error)
                // Fire start before complete so the monitor lifecycle is always paired.
                notifyStart(request)
                notifyComplete(request, response: nil, data: nil, error: networkError)
                throw networkError
            }
            // Re-inject auth only if an adapter inadvertently removed it entirely; an adapter
            // that sets a different value (e.g. token rotation) keeps its replacement.
            if let authHeader, request.value(forHTTPHeaderField: "Authorization") == nil {
                request.setValue(authHeader, forHTTPHeaderField: "Authorization")
            }
        }

        let cacheKey: String? = (cacheable && request.httpMethod == "GET" && cache != nil) ? CDYelpCacheKey.key(for: request) : nil
        // Cache is only ever consulted on the first attempt — a retry means the caller's retry
        // policy asked for a fresh network attempt, not an opportunistic cache hit.
        if attempt == 0, let cacheKey, let cache, let cached = cache.data(forKey: cacheKey) {
            notifyStart(request)
            let decoded: T
            do {
                decoded = try decodeWrapping(cached, decoder: decoder)
            } catch {
                // Evict the undecodable entry so the next request falls through to the network.
                cache.remove(forKey: cacheKey)
                notifyComplete(request, response: nil, data: cached, error: error)
                throw error
            }
            notifyComplete(request, response: nil, data: cached, error: nil)
            return decoded
        }

        // requestDidStart fires once per logical request (attempt 0 only).
        if attempt == 0 {
            notifyStart(request)
        }

        let data: Data
        let httpResponse: HTTPURLResponse?
        do {
            let (responseData, response) = try await session.data(for: request)
            data = responseData
            httpResponse = response as? HTTPURLResponse
        } catch {
            let networkError = CDYelpNetworkError.networkFailure(underlying: error)
            return try await retryOrThrow(
                networkError, request: request, decoder: decoder, cacheable: cacheable, attempt: attempt, response: nil, data: nil
            )
        }

        // Guard before notifying monitors so non-HTTP responses don't produce a false success signal.
        guard let httpResponse else {
            let error = CDYelpNetworkError.networkFailure(underlying: URLError(.badServerResponse))
            notifyComplete(request, response: nil, data: data, error: error)
            throw error
        }

        let statusCode = httpResponse.statusCode
        guard (200 ..< 300).contains(statusCode) else {
            let error = CDYelpNetworkError.httpError(statusCode: statusCode, data: data)
            return try await retryOrThrow(
                error, request: request, decoder: decoder, cacheable: cacheable, attempt: attempt, response: httpResponse, data: data
            )
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

    /// Shared retry-or-throw path for both the transport-error and HTTP-status-error cases:
    /// decides whether to retry, notifies monitors, sleeps for backoff, then recurses into
    /// `perform`, or notifies monitors of the terminal failure and rethrows.
    private func retryOrThrow<T: Decodable>(
        _ error: CDYelpNetworkError,
        request: URLRequest,
        decoder: JSONDecoder?,
        cacheable: Bool,
        attempt: UInt,
        response: HTTPURLResponse?,
        data: Data?
    ) async throws -> T {
        guard shouldRetry(error, httpMethod: request.httpMethod, attempt: attempt) else {
            notifyComplete(request, response: response, data: data, error: error)
            throw error
        }
        notifyRetry(request, retryCount: Int(attempt + 1))
        do {
            try await trackedSleep(nanoseconds: backoffNanoseconds(attempt: attempt))
        } catch {
            notifyComplete(request, response: response, data: data, error: error)
            throw error
        }
        return try await perform(request, decoder: decoder, cacheable: cacheable, attempt: attempt + 1)
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
        case let .httpError(statusCode, _):
            return retryConfig.retryableHTTPStatusCodes.contains(statusCode)
        case let .networkFailure(underlying):
            guard let urlError = underlying as? URLError else { return false }
            return retryConfig.retryableURLErrorCodes.contains(urlError.code)
        default:
            return false
        }
    }

    private func backoffNanoseconds(attempt: UInt) -> UInt64 {
        let maxDelay: TimeInterval = 300
        let delay = min(retryConfig.initialDelay * pow(2.0, Double(attempt)), maxDelay)
        return UInt64(max(0, delay) * 1_000_000_000)
    }
}
