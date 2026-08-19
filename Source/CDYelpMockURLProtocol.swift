import Foundation

/// A URLProtocol subclass for intercepting network requests in tests.
/// Register before creating CDYelpAPIClient; deregister after the test.
public final class CDYelpMockURLProtocol: URLProtocol {
    public struct Stub: Sendable {
        public let data: Data
        public let statusCode: Int
        public let headers: [String: String]
        public let transportError: URLError.Code?

        public init(data: Data, statusCode: Int = 200, headers: [String: String] = [:]) {
            self.data = data
            self.statusCode = statusCode
            self.headers = headers
            transportError = nil
        }

        /// A stub that fails with a raw transport-level error (e.g. `.timedOut`) instead of
        /// returning a response, for testing the `CDYelpNetworkError.networkFailure` path.
        public init(transportError: URLError.Code) {
            data = Data()
            statusCode = 0
            headers = [:]
            self.transportError = transportError
        }
    }

    private static let lock = NSLock()
    private nonisolated(unsafe) static var stubs: [String: Stub] = [:]

    /// Register a stub response for a URL prefix. All requests whose URL contains `urlContains` will receive this stub.
    public static func register(stub: Stub, forURLContaining urlContains: String) {
        lock.lock()
        stubs[urlContains] = stub
        lock.unlock()
    }

    /// Remove the stub registered for a specific URL key.
    public static func removeStub(forURLContaining urlContains: String) {
        lock.lock()
        stubs.removeValue(forKey: urlContains)
        lock.unlock()
    }

    /// Remove all registered stubs.
    public static func removeAllStubs() {
        lock.lock()
        stubs.removeAll()
        lock.unlock()
    }

    // MARK: - URLProtocol

    override public static func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url?.absoluteString else { return false }
        lock.lock()
        defer { lock.unlock() }
        return stubs.keys.contains(where: { url.contains($0) })
    }

    override public static func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override public func startLoading() {
        guard let url = request.url?.absoluteString else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }

        Self.lock.lock()
        let matchingStub = Self.stubs.first(where: { url.contains($0.key) })?.value
        Self.lock.unlock()

        guard let stub = matchingStub else {
            client?.urlProtocol(self, didFailWithError: URLError(.fileDoesNotExist))
            return
        }

        if let transportError = stub.transportError {
            client?.urlProtocol(self, didFailWithError: URLError(transportError))
            return
        }

        guard let response = HTTPURLResponse(
            url: request.url!,
            statusCode: stub.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: stub.headers
        ) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stub.data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override public func stopLoading() {}
}
