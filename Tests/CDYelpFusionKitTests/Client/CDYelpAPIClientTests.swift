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

    @Test func malformedResponseDoesNotPoisonCache() async throws {
        // A 200 with un-decodable JSON must throw .decodingFailed without caching the bad bytes.
        // If the cache were written before the decode (the bug this tests for), replacing the stub
        // with valid data would not help — the second call would still decode the cached garbage.
        let malformedData = Data(#"{"total":"not-an-int"}"#.utf8)
        let validData = try FixtureLoader.data(named: "search_response.json")
        CDYelpMockURLProtocol.register(
            stub: .init(data: malformedData, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient(cacheConfiguration: CDYelpCacheConfiguration(ttl: 300))

        // First call — malformed 200 must throw .decodingFailed; bad bytes must NOT be cached
        do {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
            Issue.record("Expected CDYelpNetworkError.decodingFailed to be thrown")
            return
        } catch CDYelpNetworkError.decodingFailed {
            // Expected — continue to verify the cache was not poisoned
        } catch {
            Issue.record("First call threw unexpected error: \(error)")
            return
        }

        // Replace stub with valid data. If the cache were poisoned, this second call would
        // serve the cached garbage and throw again instead of succeeding.
        CDYelpMockURLProtocol.register(
            stub: .init(data: validData, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        let response = try await client.searchBusinesses(
            byTerm: "coffee", location: "SF",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )
        #expect(response.businesses?.isEmpty == false)
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

    @Test func eventMonitorReceivesErrorOnHttpFailure() async {
        // requestDidComplete must carry the HTTP error, not nil, for non-2xx responses.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let spy = LocalSpyMonitor()
        let client = CDYelpMockClientFactory.makeClient(eventMonitors: [spy])
        await #expect(throws: Error.self) {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
        }
        let completed = spy.completedRequests
        #expect(completed.count == 1)
        #expect(completed.first?.error != nil)
    }

    @Test func http500RetriesDoNotFireSpuriousCompleteEvents() async {
        // With retryLimit:2 and a persistent 500, requestDidComplete must fire exactly once
        // (on the terminal failure), not once per attempt.
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
        #expect(spy.completedRequests.count == 1)
        #expect(spy.completedRequests.first?.error != nil)
    }

    @Test func postEndpointDoesNotRetryOnRetryableStatusCode() async throws {
        // POST endpoints (aiChat, jobs) must never be automatically retried: retrying a POST
        // whose response was lost to a transient error risks the server processing it twice.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 500),
            forURLContaining: "jobs"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "jobs") }

        let spy = LocalSpyMonitor()
        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(retryLimit: 3, initialDelay: 0),
            eventMonitors: [spy]
        )
        await #expect(throws: Error.self) {
            _ = try await client.fetchJobs(forQuery: "plumber")
        }
        #expect(spy.retryEventCount == 0)
    }

    @Test func requestAdapterRunsOncePerLogicalCallWithRetry() async throws {
        // With retryLimit: 1, a retried 500 causes two network attempts but the adapter
        // must execute only once — on the first attempt.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 500),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let counter = AdapterCallCounter()
        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(retryLimit: 1, initialDelay: 0),
            requestAdapters: [counter]
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
        #expect(counter.callCount == 1)
    }

    @Test func eventMonitorFiresOncePerLogicalRequestWithRetry() async throws {
        // A request that retries must produce exactly one requestDidStart and one
        // requestDidComplete — not one per attempt.
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
        #expect(spy.startedURLs.count == 1)
        #expect(spy.completedRequests.count == 1)
        #expect(spy.retryEventCount == 2)
    }

    @Test func eventMonitorReceivesCacheHitCallbacks() async throws {
        // Monitors must see requestDidStart + requestDidComplete for cache-served responses,
        // not just for network calls.
        let fixture = try FixtureLoader.data(named: "search_response.json")
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let spy = LocalSpyMonitor()
        let client = CDYelpMockClientFactory.makeClient(
            cacheConfiguration: CDYelpCacheConfiguration(ttl: 300),
            eventMonitors: [spy]
        )

        // First call — network path, warms the cache
        _ = try await client.searchBusinesses(
            byTerm: "coffee", location: "SF",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )

        // Remove stub so any network call would fail; second call must come from cache
        CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search")

        _ = try await client.searchBusinesses(
            byTerm: "coffee", location: "SF",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )

        #expect(spy.startedURLs.count == 2)
        #expect(spy.completedRequests.count == 2)
        #expect(spy.completedRequests.allSatisfy { $0.error == nil })
    }

    @Test func fetchOpeningsBypassesCacheDespiteCacheConfigurationEnabled() async throws {
        // Regression test: the unified caching pipeline caches any GET request whenever a cache
        // is configured, but fetchOpenings (real-time reservation availability) — along with
        // fetchEngagementMetrics, fetchServiceOfferings, fetchBusinessInsights, and
        // fetchReviewHighlights — was never cached in the pre-v6 Alamofire client and must not
        // silently become cache-eligible now. If it were cached, the second call below (after the
        // stub is removed) would succeed with the stale cached response instead of failing.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data("{}".utf8), statusCode: 200),
            forURLContaining: "openings"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "openings") }

        let client = CDYelpMockClientFactory.makeClient(cacheConfiguration: CDYelpCacheConfiguration(ttl: 300))

        // First call — network path, would also warm the cache if openings were cacheable.
        _ = try await client.fetchOpenings(forBusinessId: "gary-danko-san-francisco", covers: 2, date: "2026-08-01", time: "19:00")

        // Remove the stub so any network call fails; a cached response would let this succeed anyway.
        CDYelpMockURLProtocol.removeStub(forURLContaining: "openings")

        await #expect(throws: Error.self) {
            _ = try await client.fetchOpenings(forBusinessId: "gary-danko-san-francisco", covers: 2, date: "2026-08-01", time: "19:00")
        }
    }

    @Test func adapterThatRemovesAuthHeaderGetsAuthRestored() async throws {
        // An adapter that does a wholesale header replacement (allHTTPHeaderFields = [...])
        // inadvertently removes the Authorization header. The framework must detect this and
        // re-inject auth so the Bearer token always reaches the network.
        let fixture = try FixtureLoader.data(named: "search_response.json")
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let captor = RequestCapturingMonitor()
        let client = CDYelpMockClientFactory.makeClient(
            eventMonitors: [captor],
            requestAdapters: [HeaderStrippingAdapter()]
        )
        _ = try await client.searchBusinesses(
            byTerm: "coffee", location: "SF",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )

        #expect(captor.capturedRequest?.value(forHTTPHeaderField: "Authorization")?.hasPrefix("Bearer ") == true)
    }

    @Test func adapterThatStripsHeadersGetsAcceptRestoredOnGetRequest() async throws {
        // The same wholesale header replacement that strips Authorization also strips Accept.
        // The framework must restore Accept, not just Authorization, on GET requests.
        let fixture = try FixtureLoader.data(named: "search_response.json")
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let captor = RequestCapturingMonitor()
        let client = CDYelpMockClientFactory.makeClient(
            eventMonitors: [captor],
            requestAdapters: [HeaderStrippingAdapter()]
        )
        _ = try await client.searchBusinesses(
            byTerm: "coffee", location: "SF",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )

        #expect(captor.capturedRequest?.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func adapterThatStripsHeadersGetsAcceptAndContentTypeRestoredOnPostRequest() async throws {
        // The same wholesale header replacement on a POST endpoint (jobs) must restore both
        // Accept and Content-Type, not just Authorization.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data("{}".utf8), statusCode: 200),
            forURLContaining: "jobs"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "jobs") }

        let captor = RequestCapturingMonitor()
        let client = CDYelpMockClientFactory.makeClient(
            eventMonitors: [captor],
            requestAdapters: [HeaderStrippingAdapter()]
        )
        _ = try await client.fetchJobs(forQuery: "plumber")

        #expect(captor.capturedRequest?.value(forHTTPHeaderField: "Accept") == "application/json")
        #expect(captor.capturedRequest?.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test func adapterThatReplacesAuthHeaderKeepsItsValue() async throws {
        // An adapter that performs token rotation sets a new Authorization value.
        // The framework must preserve the adapter's value, not overwrite it with the init-time key.
        let fixture = try FixtureLoader.data(named: "search_response.json")
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let captor = RequestCapturingMonitor()
        let rotatedToken = "Bearer rotated-token-xyz"
        let client = CDYelpMockClientFactory.makeClient(
            eventMonitors: [captor],
            requestAdapters: [TokenRotationAdapter(token: rotatedToken)]
        )
        _ = try await client.searchBusinesses(
            byTerm: "coffee", location: "SF",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )

        #expect(captor.capturedRequest?.value(forHTTPHeaderField: "Authorization") == rotatedToken)
    }

    @Test func monitorReceivesErrorOnDecodingFailureAfter200() async {
        // A 200 response with malformed JSON must deliver error: decodingFailed to monitors,
        // not nil — the success signal must not fire before decoding succeeds.
        let malformedData = Data(#"{"total":"not-an-int"}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: malformedData, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let spy = LocalSpyMonitor()
        let client = CDYelpMockClientFactory.makeClient(eventMonitors: [spy])
        await #expect(throws: Error.self) {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
        }
        #expect(spy.completedRequests.count == 1)
        #expect(spy.completedRequests.first?.error != nil)
    }

    @Test func monitorLifecycleIsCompleteOnAdapterFailure() async {
        // An adapter failure must produce a paired requestDidStart + requestDidComplete;
        // monitors that track in-flight request counts must not diverge.
        let spy = LocalSpyMonitor()
        let client = CDYelpMockClientFactory.makeClient(
            eventMonitors: [spy],
            requestAdapters: [ThrowingAdapter()]
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
        #expect(spy.startedURLs.count == 1)
        #expect(spy.completedRequests.count == 1)
        #expect(spy.completedRequests.first?.error != nil)
    }

    @Test func cancelAllPendingAPIRequestsCompletesWithNoInFlightRequests() async {
        // Smoke test: previously zero coverage existed for this method at all. Calling it with
        // nothing in flight must simply return, not hang or crash.
        let client = CDYelpMockClientFactory.makeClient()
        await client.cancelAllPendingAPIRequests()
    }

    @Test func cancelAllPendingAPIRequestsInterruptsRetryBackoff() async throws {
        // cancelAllPendingAPIRequests() must cut short an in-flight retry-backoff sleep rather
        // than letting it run to completion — verified by asserting the call fails well before
        // the configured initialDelay would otherwise elapse.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 500),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(retryLimit: 3, initialDelay: 10)
        )

        let task = Task {
            try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
        }

        // Give the first attempt time to fail and enter the retry-backoff sleep.
        try await Task.sleep(nanoseconds: 100_000_000)
        let start = Date()
        await client.cancelAllPendingAPIRequests()

        await #expect(throws: CDYelpNetworkError.self) {
            _ = try await task.value
        }
        #expect(Date().timeIntervalSince(start) < 2)
    }

    @Test func ambientTaskCancellationInterruptsRetryBackoff() async throws {
        // Regression test: trackedSleep used to run the backoff sleep in a detached Task whose
        // cancellation state was disconnected from the caller's ambient Task, so cancelling the
        // Task that invoked an API method had no effect on an in-flight retry-backoff sleep.
        // Cancelling the wrapping Task directly (the idiomatic Swift concurrency pattern, as
        // opposed to calling cancelAllPendingAPIRequests()) must also interrupt the backoff.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 500),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(retryLimit: 3, initialDelay: 10)
        )

        let task = Task {
            try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
        }

        // Give the first attempt time to fail and enter the retry-backoff sleep.
        try await Task.sleep(nanoseconds: 100_000_000)
        let start = Date()
        task.cancel()

        await #expect(throws: (any Error).self) {
            _ = try await task.value
        }
        #expect(Date().timeIntervalSince(start) < 2)
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

private final class AdapterCallCounter: CDYelpRequestAdapter, @unchecked Sendable {
    private let lock = NSLock()
    private var _callCount = 0
    var callCount: Int {
        lock.withLock { _callCount }
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        lock.withLock { _callCount += 1 }
        return urlRequest
    }
}

private final class ThrowingAdapter: CDYelpRequestAdapter, @unchecked Sendable {
    struct AdapterError: Error {}
    func adapt(_: URLRequest) throws -> URLRequest {
        throw AdapterError()
    }
}

private final class HeaderStrippingAdapter: CDYelpRequestAdapter, @unchecked Sendable {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var req = urlRequest
        req.allHTTPHeaderFields = ["X-Custom": "value"]
        return req
    }
}

private final class TokenRotationAdapter: CDYelpRequestAdapter, @unchecked Sendable {
    private let token: String
    init(token: String) {
        self.token = token
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var req = urlRequest
        req.setValue(token, forHTTPHeaderField: "Authorization")
        return req
    }
}

private final class RequestCapturingMonitor: CDYelpEventMonitor, @unchecked Sendable {
    private let lock = NSLock()
    private var _capturedRequest: URLRequest?

    var capturedRequest: URLRequest? {
        lock.withLock { _capturedRequest }
    }

    func requestDidStart(urlRequest: URLRequest) {
        lock.withLock { _capturedRequest = urlRequest }
    }
}
