import Foundation
import Testing
@testable import CDYelpFusionKit

struct CDYelpEventMonitorTests {
    struct RequestCompletion {
        let urlRequest: URLRequest?
        let response: HTTPURLResponse?
        let data: Data?
        let error: Error?
    }

    struct RetryEvent {
        let urlRequest: URLRequest?
        let retryCount: Int
    }

    final class SpyMonitor: CDYelpEventMonitor, @unchecked Sendable {
        var startedRequests: [URLRequest] = []
        var completedRequests: [RequestCompletion] = []
        var retryEvents: [RetryEvent] = []

        func requestDidStart(urlRequest: URLRequest) {
            startedRequests.append(urlRequest)
        }

        func requestDidComplete(urlRequest: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) {
            completedRequests.append(RequestCompletion(urlRequest: urlRequest, response: response, data: data, error: error))
        }

        func requestWillRetry(urlRequest: URLRequest?, retryCount: Int) {
            retryEvents.append(RetryEvent(urlRequest: urlRequest, retryCount: retryCount))
        }
    }

    @Test func monitorDefaultImplementationsAreNoOps() {
        final class MinimalMonitor: CDYelpEventMonitor {}
        let monitor = MinimalMonitor()
        guard let url = URL(string: "https://api.yelp.com") else { return }
        monitor.requestDidStart(urlRequest: URLRequest(url: url))
        monitor.requestWillRetry(urlRequest: URLRequest(url: url), retryCount: 1)
    }

    @Test func requestAdapterReceivesAndReturnsRequest() throws {
        final class HeaderAdapter: CDYelpRequestAdapter {
            func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
                var req = urlRequest
                req.addValue("test-value", forHTTPHeaderField: "X-Custom-Header")
                return req
            }
        }

        let adapter = HeaderAdapter()
        guard let url = URL(string: "https://api.yelp.com/v3/businesses/search") else { return }
        var request = URLRequest(url: url)
        request = try adapter.adapt(request)
        #expect(request.value(forHTTPHeaderField: "X-Custom-Header") == "test-value")
    }

    @Test func spyMonitorCapturesStartedRequests() {
        let spy = SpyMonitor()
        guard let url = URL(string: "https://api.yelp.com") else { return }
        spy.requestDidStart(urlRequest: URLRequest(url: url))
        #expect(spy.startedRequests.count == 1)
        #expect(spy.startedRequests.first?.url == url)
    }

    @Test func spyMonitorCapturesCompletedRequests() {
        let spy = SpyMonitor()
        guard let url = URL(string: "https://api.yelp.com") else { return }
        let data = "{}".data(using: .utf8)
        spy.requestDidComplete(urlRequest: URLRequest(url: url), response: nil, data: data, error: nil)
        #expect(spy.completedRequests.count == 1)
        #expect(spy.completedRequests.first?.urlRequest?.url == url)
        #expect(spy.completedRequests.first?.data == data)
    }

    @Test func spyMonitorCapturesRetryEvents() {
        let spy = SpyMonitor()
        guard let url = URL(string: "https://api.yelp.com") else { return }
        spy.requestWillRetry(urlRequest: URLRequest(url: url), retryCount: 2)
        #expect(spy.retryEvents.count == 1)
        #expect(spy.retryEvents.first?.urlRequest?.url == url)
        #expect(spy.retryEvents.first?.retryCount == 2)
    }
}
