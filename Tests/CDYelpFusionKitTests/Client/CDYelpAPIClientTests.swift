@testable import CDYelpFusionKit
import CDYelpFusionKitTesting
import Foundation
import Testing

@Suite(.serialized)
struct CDYelpAPIClientTests {
    @Test func searchBusinessesReturnsDecodedResponse() async throws {
        let fixture = try FixtureLoader.data(named: "search_response.json")
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.searchBusinesses(
            byTerm: "coffee",
            location: "San Francisco",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )
        #expect(response.businesses?.isEmpty == false)
    }

    @Test func searchBusinessesReturns404AsError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient()
        await #expect(throws: Error.self) {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
        }
    }

    @Test func searchBusinessesReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func malformedResponseBodyThrowsDecodingFailed() async {
        // "total" is Int? — providing a string causes a type-mismatch DecodingError
        let malformedData = Data(#"{"total":"not-an-int"}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: malformedData, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
            Issue.record("Expected CDYelpNetworkError.decodingFailed to be thrown")
        } catch CDYelpNetworkError.decodingFailed {
            // Correct — framework wraps decoder failures in .decodingFailed
        } catch {
            Issue.record("Expected CDYelpNetworkError.decodingFailed but threw \(error)")
        }
    }

    @Test func cachedMalformedResponseThrowsDecodingFailed() async {
        // Cache write happens before decode (CDYelpURLSession stores the raw bytes on any 2xx).
        // A 200 with un-decodable JSON writes to cache, then throws .decodingFailed.
        // The second call reads from cache and must also throw .decodingFailed — not a raw DecodingError.
        // "total" is Int? — providing a string causes a type-mismatch DecodingError
        let malformedData = Data(#"{"total":"not-an-int"}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: malformedData, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        let client = CDYelpMockClientFactory.makeClient(cacheConfiguration: CDYelpCacheConfiguration(ttl: 300))

        // First call — network path, data is cached before decode fails
        do {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
        } catch CDYelpNetworkError.decodingFailed {
            // Expected — continue to test cache path
        } catch {
            Issue.record("First call threw unexpected error: \(error)")
            return
        }
        CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search")

        // Second call — served from cache; must still wrap in .decodingFailed (not raw DecodingError)
        do {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
            Issue.record("Expected CDYelpNetworkError.decodingFailed from cache path")
        } catch CDYelpNetworkError.decodingFailed {
            // Correct — cache-hit decode errors are wrapped consistently
        } catch {
            Issue.record("Cache path threw unexpected error type: \(error)")
        }
    }

    @Test func adapterFailureThrowsInvalidRequestError() async {
        let client = CDYelpMockClientFactory.makeClient(requestAdapters: [ThrowingAdapter()])
        do {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
            Issue.record("Expected CDYelpNetworkError.invalidRequest to be thrown")
        } catch CDYelpNetworkError.invalidRequest {
            // Correct — adapter failures are wrapped in .invalidRequest
        } catch {
            Issue.record("Expected CDYelpNetworkError.invalidRequest but threw \(error)")
        }
    }

    @Test func cachedResponseServedWithoutSecondNetworkCall() async throws {
        let fixture = try FixtureLoader.data(named: "search_response.json")
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient(
            cacheConfiguration: CDYelpCacheConfiguration(ttl: 300)
        )

        let first = try await client.searchBusinesses(
            byTerm: "coffee", location: "SF",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )

        // Remove the stub — any real network call would now fail
        CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search")

        let second = try await client.searchBusinesses(
            byTerm: "coffee", location: "SF",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )

        #expect(first.businesses?.count == second.businesses?.count)
    }

    @Test func eventMonitorReceivesRequestStartedCallback() async throws {
        let fixture = try FixtureLoader.data(named: "search_response.json")
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let spy = LocalSpyMonitor()
        let client = CDYelpMockClientFactory.makeClient(eventMonitors: [spy])
        _ = try await client.searchBusinesses(
            byTerm: "coffee", location: "SF",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )

        #expect(spy.startedURLs.first?.absoluteString.contains("businesses/search") == true)
    }

    @Test func eventMonitorReceivesCompletedCallbackOnSuccess() async throws {
        let fixture = try FixtureLoader.data(named: "search_response.json")
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let spy = LocalSpyMonitor()
        let client = CDYelpMockClientFactory.makeClient(eventMonitors: [spy])
        _ = try await client.searchBusinesses(
            byTerm: "coffee", location: "SF",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )

        let completed = spy.completedRequests
        #expect(completed.count == 1)
        #expect(completed.first?.response != nil)
        #expect(completed.first?.error == nil)
    }

    @Test func postEndpointResponseIsNotCached() async throws {
        let fixture = """
        {"response":"Test AI response"}
        """.data(using: .utf8)!
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "ai/chat"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "ai/chat") }

        let client = CDYelpMockClientFactory.makeClient(
            cacheConfiguration: CDYelpCacheConfiguration(ttl: 300)
        )
        _ = try await client.fetchAIChat(query: "best tacos")

        // Remove the stub — a cached POST response would succeed; a network call would fail.
        CDYelpMockURLProtocol.removeStub(forURLContaining: "ai/chat")

        await #expect(throws: Error.self) {
            _ = try await client.fetchAIChat(query: "best tacos")
        }
    }

    @Test func fetchJobsPostResponseIsNotCached() async throws {
        let fixture = """
        {"jobs":[]}
        """.data(using: .utf8)!
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "jobs"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "jobs") }

        let client = CDYelpMockClientFactory.makeClient(
            cacheConfiguration: CDYelpCacheConfiguration(ttl: 300)
        )
        _ = try await client.fetchJobs(forQuery: "plumber")

        CDYelpMockURLProtocol.removeStub(forURLContaining: "jobs")

        await #expect(throws: Error.self) {
            _ = try await client.fetchJobs(forQuery: "plumber")
        }
    }

    @Test func fetchReviewsDecodesDateFields() async throws {
        let fixture = try FixtureLoader.data(named: "reviews_response.json")
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "reviews"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "reviews") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.fetchReviews(
            forBusinessId: "gary-danko-san-francisco",
            locale: nil
        )
        #expect(response.reviews?.isEmpty == false)
    }

    @Test func http500TriggersRetryUpToLimit() async throws {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 500),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let spy = LocalSpyMonitor()
        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(retryLimit: 2, initialDelay: 0),
            eventMonitors: [spy]
        )
        await #expect(throws: Error.self) {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
        }
        #expect(spy.retryEventCount == 2)
    }

    @Test func http500FinalThrowIsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 500),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(retryLimit: 1, initialDelay: 0)
        )
        do {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _) {
            #expect(statusCode == 500)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(500) but threw \(error)")
        }
    }

    @Test func non500StatusCodeDoesNotTriggerRetry() async throws {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let spy = LocalSpyMonitor()
        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(retryLimit: 3, initialDelay: 0),
            eventMonitors: [spy]
        )
        await #expect(throws: Error.self) {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
        }
        #expect(spy.retryEventCount == 0)
    }
}

// MARK: - Test Helpers

private final class LocalSpyMonitor: CDYelpEventMonitor, @unchecked Sendable {
    struct CompletedRequest {
        let response: HTTPURLResponse?
        let error: Error?
    }

    private let lock = NSLock()
    private var _startedURLs: [URL] = []
    private var _retryEventCount: Int = 0
    private var _completedRequests: [CompletedRequest] = []

    var startedURLs: [URL] {
        lock.lock()
        defer { lock.unlock() }
        return _startedURLs
    }

    var retryEventCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _retryEventCount
    }

    var completedRequests: [CompletedRequest] {
        lock.lock()
        defer { lock.unlock() }
        return _completedRequests
    }

    func requestDidStart(urlRequest: URLRequest) {
        lock.lock()
        if let url = urlRequest.url { _startedURLs.append(url) }
        lock.unlock()
    }

    func requestDidComplete(urlRequest _: URLRequest?, response: HTTPURLResponse?, data _: Data?, error: Error?) {
        lock.lock()
        _completedRequests.append(CompletedRequest(response: response, error: error))
        lock.unlock()
    }

    func requestWillRetry(urlRequest _: URLRequest?, retryCount _: Int) {
        lock.lock()
        _retryEventCount += 1
        lock.unlock()
    }
}

private final class ThrowingAdapter: CDYelpRequestAdapter, @unchecked Sendable {
    struct AdapterError: Error {}
    func adapt(_: URLRequest) throws -> URLRequest {
        throw AdapterError()
    }
}
