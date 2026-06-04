#if DEBUG || TESTING
    import Foundation

    /// A URLProtocol subclass for intercepting network requests in tests.
    /// Register before creating CDYelpAPIClient; deregister after the test.
    public final class CDYelpMockURLProtocol: URLProtocol {
        public struct Stub: Sendable {
            public let data: Data
            public let statusCode: Int
            public let headers: [String: String]

            public init(data: Data, statusCode: Int = 200, headers: [String: String] = [:]) {
                self.data = data
                self.statusCode = statusCode
                self.headers = headers
            }
        }

        private static let lock = NSLock()
        private static var stubs: [String: Stub] = [:]

        /// Register a stub response for a URL prefix. All requests whose URL contains `urlContains` will receive this stub.
        public static func register(stub: Stub, forURLContaining urlContains: String) {
            lock.lock()
            stubs[urlContains] = stub
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

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: stub.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: stub.headers
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: stub.data)
            client?.urlProtocolDidFinishLoading(self)
        }

        override public func stopLoading() {}
    }
#endif
