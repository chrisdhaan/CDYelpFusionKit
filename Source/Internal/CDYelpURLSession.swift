import Foundation

actor CDYelpURLSession {
    private let session: URLSession
    private let makeDecoder: () -> JSONDecoder
    private let cache: CDYelpResponseCache?
    private let monitors: [any CDYelpEventMonitor]
    private let adapters: [any CDYelpRequestAdapter]
    private let retryConfig: CDYelpRetryConfiguration

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
        attempt: UInt = 0
    ) async throws -> T {
        var request = urlRequest
        do {
            for adapter in adapters {
                request = try adapter.adapt(request)
            }
        } catch {
            let networkError = CDYelpNetworkError.invalidRequest(underlying: error)
            for monitor in monitors {
                monitor.requestDidComplete(urlRequest: request, response: nil, data: nil, error: networkError)
            }
            throw networkError
        }

        let cacheKey: String? = request.httpMethod == "GET" ? CDYelpCacheKey.key(for: request) : nil
        if let cacheKey, let cache, let cached = cache.data(forKey: cacheKey) {
            let dec = decoder ?? makeDecoder()
            return try dec.decode(T.self, from: cached)
        }

        for monitor in monitors {
            monitor.requestDidStart(urlRequest: request)
        }

        let data: Data
        let httpResponse: HTTPURLResponse?
        do {
            let (responseData, response) = try await session.data(for: request)
            data = responseData
            httpResponse = response as? HTTPURLResponse
        } catch {
            for monitor in monitors {
                monitor.requestDidComplete(urlRequest: request, response: nil, data: nil, error: error)
            }
            let networkError = CDYelpNetworkError.networkFailure(underlying: error)
            if shouldRetry(statusCode: nil, error: error, attempt: attempt) {
                for monitor in monitors {
                    monitor.requestWillRetry(urlRequest: request, retryCount: Int(attempt + 1))
                }
                try await Task.sleep(nanoseconds: backoffNanoseconds(attempt: attempt))
                return try await perform(urlRequest, decoder: decoder, attempt: attempt + 1)
            }
            throw networkError
        }

        for monitor in monitors {
            monitor.requestDidComplete(urlRequest: request, response: httpResponse, data: data, error: nil)
        }

        guard let httpResponse else {
            throw CDYelpNetworkError.networkFailure(underlying: URLError(.badServerResponse))
        }

        let statusCode = httpResponse.statusCode
        guard (200 ..< 300).contains(statusCode) else {
            let error = CDYelpNetworkError.httpError(statusCode: statusCode, data: data)
            if shouldRetry(statusCode: statusCode, error: nil, attempt: attempt) {
                for monitor in monitors {
                    monitor.requestWillRetry(urlRequest: request, retryCount: Int(attempt + 1))
                }
                try await Task.sleep(nanoseconds: backoffNanoseconds(attempt: attempt))
                return try await perform(urlRequest, decoder: decoder, attempt: attempt + 1)
            }
            throw error
        }

        if let cacheKey {
            cache?.set(data: data, forKey: cacheKey)
        }

        let dec = decoder ?? makeDecoder()
        do {
            return try dec.decode(T.self, from: data)
        } catch {
            throw CDYelpNetworkError.decodingFailed(underlying: error)
        }
    }

    /// Cancellation is delivered asynchronously by URLSession; the function returns before
    /// tasks are cancelled. In-flight requests sleeping during retry backoff may fire one
    /// additional attempt before the cancellation takes effect.
    nonisolated func cancelAllTasks() {
        session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            for task in dataTasks {
                task.cancel()
            }
            for task in uploadTasks {
                task.cancel()
            }
            for task in downloadTasks {
                task.cancel()
            }
        }
    }

    func clearCache() {
        cache?.removeAll()
    }

    private func shouldRetry(statusCode: Int?, error: Error?, attempt: UInt) -> Bool {
        guard attempt < retryConfig.retryLimit else { return false }
        if let code = statusCode {
            return retryConfig.retryableHTTPStatusCodes.contains(code)
        }
        if let urlError = error as? URLError {
            return retryConfig.retryableURLErrorCodes.contains(urlError.code)
        }
        return false
    }

    private func backoffNanoseconds(attempt: UInt) -> UInt64 {
        let maxDelay: TimeInterval = 300
        let delay = min(retryConfig.initialDelay * pow(2.0, Double(attempt)), maxDelay)
        return UInt64(max(0, delay) * 1_000_000_000)
    }
}
