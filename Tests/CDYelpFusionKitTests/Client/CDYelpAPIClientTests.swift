@testable import CDYelpFusionKit
import CDYelpFusionKitTesting
import Foundation
import Testing

/// .serialized is required: several tests register mock stub keys that are substrings of
/// other tests' keys (e.g. "events" / "events/featured"), and CDYelpMockURLProtocol's stub
/// lookup has no deterministic priority between overlapping keys — safe only because tests
/// never run concurrently and each defers its own stub removal before the next test starts.
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
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func httpErrorCarriesResponseBodyAndHeaders() async {
        // CDYelpNetworkError.httpError's data and headers associated values (added in this PR
        // so callers can read a failed response's error body / rate-limit headers) must actually
        // be the real response body and headers, not empty placeholders.
        let errorBody = Data(#"{"error": {"code": "TOO_MANY_REQUESTS_QPS"}}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: errorBody, statusCode: 429, headers: ["X-RateLimit-Remaining": "0"]),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(retryLimit: 0, initialDelay: 0)
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
        } catch let CDYelpNetworkError.httpError(statusCode, data, headers) {
            #expect(statusCode == 429)
            #expect(data == errorBody)
            #expect(headers["X-RateLimit-Remaining"] == "0")
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(429) but threw \(error)")
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

    @Test func retryAfterSecondsHeaderOverridesExponentialBackoff() async throws {
        // A server-provided Retry-After: 0 must be honored instead of exponential backoff — with
        // initialDelay: 10, exponential backoff alone would take 10s before the first retry, so
        // completing well under that proves the header value won this attempt's delay.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 429, headers: ["Retry-After": "0"]),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(retryLimit: 1, initialDelay: 10)
        )
        let start = Date()
        await #expect(throws: Error.self) {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
        }
        #expect(Date().timeIntervalSince(start) < 2)
    }

    @Test func retryAfterHTTPDateHeaderOverridesExponentialBackoff() async throws {
        // The HTTP-date form of Retry-After (RFC 9110 §10.2.3) must parse and be honored the
        // same way the integer-seconds form is. A date effectively "now" resolves to ~0s, so —
        // as above — completing well under the 10s exponential-only delay proves it was parsed
        // and used rather than silently ignored.
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        let retryAfterDate = formatter.string(from: Date())

        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 429, headers: ["Retry-After": retryAfterDate]),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(retryLimit: 1, initialDelay: 10)
        )
        let start = Date()
        await #expect(throws: Error.self) {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
        }
        #expect(Date().timeIntervalSince(start) < 2)
    }

    @Test func malformedRetryAfterHeaderFallsBackToExponentialBackoff() async throws {
        // A Retry-After value that's neither a valid integer nor a valid HTTP-date must be
        // ignored in favor of exponential backoff, not treated as an immediate (or otherwise
        // arbitrary) retry — proven by observing the full initialDelay actually elapses.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 429, headers: ["Retry-After": "not-a-valid-value"]),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(retryLimit: 1, initialDelay: 1)
        )
        let start = Date()
        await #expect(throws: Error.self) {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
        }
        #expect(Date().timeIntervalSince(start) >= 0.9)
    }

    @Test func transportErrorTriggersRetryAndSurfacesAsNetworkFailure() async {
        // A raw transport-level failure (not an HTTP status code) must be wrapped in
        // CDYelpNetworkError.networkFailure and, when its URLError code is retryable
        // (.timedOut is in the default retryableURLErrorCodes set), must retry like an
        // HTTP-status failure does.
        CDYelpMockURLProtocol.register(
            stub: .init(transportError: .timedOut),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let spy = LocalSpyMonitor()
        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(retryLimit: 2, initialDelay: 0),
            eventMonitors: [spy]
        )
        do {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
            Issue.record("Expected CDYelpNetworkError.networkFailure to be thrown")
        } catch CDYelpNetworkError.networkFailure {
            // Correct — transport failures are wrapped in .networkFailure
        } catch {
            Issue.record("Expected CDYelpNetworkError.networkFailure but threw \(error)")
        }
        #expect(spy.retryEventCount == 2)
    }

    @Test func transportErrorWithNonRetryableCodeDoesNotRetry() async {
        // A transport failure whose URLError code isn't in retryableURLErrorCodes (the default
        // set is [.networkConnectionLost, .notConnectedToInternet, .timedOut]) must not retry.
        CDYelpMockURLProtocol.register(
            stub: .init(transportError: .cannotFindHost),
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

    @Test func cancelledTransportErrorNeverRetriesEvenIfConfiguredAsRetryable() async {
        // cancelAllTasks()/cancelAllPendingAPIRequests() cancel in-flight URLSessionDataTasks,
        // which surfaces as URLError(.cancelled). If a caller's retryConfiguration opted into
        // treating .cancelled as retryable, that must not resurrect a request the caller asked
        // to terminate — .cancelled must never be retried regardless of retryableURLErrorCodes.
        CDYelpMockURLProtocol.register(
            stub: .init(transportError: .cancelled),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let spy = LocalSpyMonitor()
        let client = CDYelpMockClientFactory.makeClient(
            retryConfiguration: CDYelpRetryConfiguration(
                retryLimit: 3,
                initialDelay: 0,
                retryableURLErrorCodes: [.cancelled, .networkConnectionLost, .notConnectedToInternet, .timedOut]
            ),
            eventMonitors: [spy]
        )
        do {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
            Issue.record("Expected CDYelpNetworkError.networkFailure to be thrown")
        } catch CDYelpNetworkError.networkFailure {
            // Correct
        } catch {
            Issue.record("Expected CDYelpNetworkError.networkFailure but threw \(error)")
        }
        #expect(spy.retryEventCount == 0)
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
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
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

    @Test func cacheHitDecodeFailureFallsThroughToLiveNetworkFetch() async throws {
        // Regression test: a cache-hit whose bytes fail to decode (e.g. a stale entry left over
        // after an app update changes the Codable model) must not fail the caller if a live
        // fetch would succeed right now. The pipeline should evict the corrupt entry and fall
        // through to the network, not throw immediately, and re-cache the fresh response.
        let cache = CDYelpResponseCache(configuration: CDYelpCacheConfiguration(ttl: 300))
        let request = try CDYelpRouter.search(parameters: ["term": "coffee"]).asURLRequest(apiKey: "test-key")
        let cacheKey = CDYelpCacheKey.key(for: request)
        cache.set(data: Data(#"{"total":"not-an-int"}"#.utf8), forKey: cacheKey)

        let validData = try FixtureLoader.data(named: "search_response.json")
        CDYelpMockURLProtocol.register(stub: .init(data: validData, statusCode: 200), forURLContaining: "businesses/search")
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [CDYelpMockURLProtocol.self]
        let urlSession = CDYelpURLSession(
            session: URLSession(configuration: sessionConfiguration),
            makeDecoder: { JSONDecoder() },
            cache: cache,
            monitors: [],
            adapters: [],
            retryConfig: .disabled
        )

        let response: CDYelpSearchResponse.Business = try await urlSession.perform(buildRequest: { request })
        #expect(response.businesses?.isEmpty == false)

        // The corrupt entry must have been evicted, and the fresh response re-cached.
        #expect(cache.data(forKey: cacheKey) != nil)
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

    @Test func routerInvalidRequestErrorFiresPairedMonitorNotifications() async {
        // Regression test: a CDYelpNetworkError.invalidRequest thrown by CDYelpRouter itself
        // (e.g. a non-finite query parameter) must fire a paired requestDidStart/requestDidComplete,
        // just like an adapter-thrown .invalidRequest already does — otherwise a consumer that only
        // observes errors via CDYelpEventMonitor has a blind spot for this entire error subclass.
        let spy = LocalSpyMonitor()
        let client = CDYelpMockClientFactory.makeClient(eventMonitors: [spy])
        do {
            _ = try await client.searchBusinesses(
                byTerm: nil, location: "SF",
                latitude: .nan, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
            Issue.record("Expected CDYelpNetworkError.invalidRequest to be thrown")
        } catch let CDYelpNetworkError.invalidRequest(underlying) {
            // The underlying value must be the actual NonFiniteQueryValueError CDYelpRouter
            // threw, not another CDYelpNetworkError — CDYelpURLSession must not re-wrap an
            // error that CDYelpRouter.asURLRequest() already wrapped in .invalidRequest.
            #expect(underlying is CDYelpRouter.NonFiniteQueryValueError)
        } catch {
            Issue.record("Expected CDYelpNetworkError.invalidRequest but threw \(error)")
        }
        #expect(spy.startedURLs.count == 1)
        #expect(spy.completedRequests.count == 1)
        #expect(spy.completedRequests.first?.error != nil)
    }

    // MARK: - Business Endpoints

    @Test func searchBusinessesByPhoneNumberReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"total":1,"businesses":[{"id":"biz-1","name":"Test Biz"}]}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/search/phone"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search/phone") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.searchBusinesses(byPhoneNumber: "+14159083801", locale: nil)
        #expect(response.total == 1)
        #expect(response.businesses?.first?.id == "biz-1")
    }

    @Test func searchBusinessesByPhoneNumberReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "businesses/search/phone"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search/phone") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.searchBusinesses(byPhoneNumber: "+14159083801", locale: nil)
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func searchTransactionsReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"total":1,"businesses":[{"id":"biz-1","name":"Test Biz"}]}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "transactions/delivery/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "transactions/delivery/search") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.searchTransactions(
            byType: .foodDelivery, location: "San Francisco", latitude: nil, longitude: nil
        )
        #expect(response.total == 1)
        #expect(response.businesses?.first?.id == "biz-1")
    }

    @Test func searchTransactionsReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "transactions/delivery/search"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "transactions/delivery/search") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.searchTransactions(
                byType: .foodDelivery, location: "San Francisco", latitude: nil, longitude: nil
            )
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func fetchBusinessReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"id":"biz-1","name":"Test Biz"}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/test-business-id"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/test-business-id") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.fetchBusiness(forId: "test-business-id", locale: nil)
        #expect(response.business?.id == "biz-1")
    }

    @Test func fetchBusinessReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "businesses/test-business-id"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/test-business-id") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.fetchBusiness(forId: "test-business-id", locale: nil)
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func searchBusinessesByMatchReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"total":1,"businesses":[{"id":"biz-1","name":"Test Biz"}]}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/matches"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/matches") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.searchBusinesses(
            name: "Test Biz",
            addressOne: "123 Main St",
            addressTwo: nil,
            addressThree: nil,
            city: "San Francisco",
            state: "CA",
            country: "US",
            latitude: nil,
            longitude: nil,
            phone: nil,
            zipCode: nil,
            yelpBusinessId: nil,
            limit: nil,
            matchThresholdType: .none
        )
        #expect(response.total == 1)
        #expect(response.businesses?.first?.id == "biz-1")
    }

    @Test func searchBusinessesByMatchReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "businesses/matches"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/matches") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.searchBusinesses(
                name: "Test Biz",
                addressOne: "123 Main St",
                addressTwo: nil,
                addressThree: nil,
                city: "San Francisco",
                state: "CA",
                country: "US",
                latitude: nil,
                longitude: nil,
                phone: nil,
                zipCode: nil,
                yelpBusinessId: nil,
                limit: nil,
                matchThresholdType: .none
            )
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func autocompleteBusinessesReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"terms":[{"text":"coffee"}],"businesses":[{"id":"biz-1","name":"Test Biz"}],"categories":[]}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "autocomplete"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "autocomplete") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.autocompleteBusinesses(
            byText: "coffee", latitude: 37.7749, longitude: -122.4194, locale: nil
        )
        #expect(response.businesses?.first?.id == "biz-1")
    }

    @Test func autocompleteBusinessesReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "autocomplete"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "autocomplete") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.autocompleteBusinesses(
                byText: "coffee", latitude: 37.7749, longitude: -122.4194, locale: nil
            )
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    // MARK: - Event Endpoints

    @Test func fetchEventReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"id":"evt-1","name":"Test Event","time_start":"2026-08-15T19:00:00-07:00"}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "events/test-event-id"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "events/test-event-id") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.fetchEvent(forId: "test-event-id", locale: nil)
        #expect(response.event?.id == "evt-1")
        #expect(response.event?.timeStart == DateFormatter.events.date(from: "2026-08-15T19:00:00-07:00"))
    }

    @Test func fetchEventReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "events/test-event-id"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "events/test-event-id") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.fetchEvent(forId: "test-event-id", locale: nil)
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func searchEventsReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"total":1,"events":[{"id":"evt-1","name":"Test Event"}]}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "events"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "events") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.searchEvents(
            byLocale: nil, offset: nil, limit: nil, sortBy: nil, sortOn: nil,
            startDate: nil, endDate: nil, categories: nil, isFree: nil,
            location: "San Francisco", latitude: nil, longitude: nil, radius: nil, excludedEvents: nil
        )
        #expect(response.total == 1)
        #expect(response.events?.first?.id == "evt-1")
    }

    @Test func searchEventsReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "events"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "events") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.searchEvents(
                byLocale: nil, offset: nil, limit: nil, sortBy: nil, sortOn: nil,
                startDate: nil, endDate: nil, categories: nil, isFree: nil,
                location: "San Francisco", latitude: nil, longitude: nil, radius: nil, excludedEvents: nil
            )
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func fetchFeaturedEventReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"id":"evt-1","name":"Test Event"}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "events/featured"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "events/featured") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.fetchFeaturedEvent(
            forLocale: nil, location: "San Francisco", latitude: nil, longitude: nil
        )
        #expect(response.event?.id == "evt-1")
    }

    @Test func fetchFeaturedEventReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "events/featured"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "events/featured") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.fetchFeaturedEvent(
                forLocale: nil, location: "San Francisco", latitude: nil, longitude: nil
            )
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    // MARK: - Category Endpoints

    @Test func fetchCategoriesReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"categories":[{"alias":"active","title":"Active Life"}]}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "categories"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "categories") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.fetchCategories(forLocale: nil)
        #expect(response.categories?.first?.alias == "active")
    }

    @Test func fetchCategoriesReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "categories"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "categories") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.fetchCategories(forLocale: nil)
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func fetchCategoryReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"category":{"alias":"active","title":"Active Life"}}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "categories/active"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "categories/active") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.fetchCategory(forAlias: .activeLife, andLocale: nil)
        #expect(response.category?.alias == "active")
    }

    @Test func fetchCategoryReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "categories/active"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "categories/active") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.fetchCategory(forAlias: .activeLife, andLocale: nil)
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    // MARK: - Analytics Endpoints

    @Test func fetchEngagementMetricsReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"data":[{"business_id":"biz-1","metrics":{"page_views":10.0}}]}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/engagement"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/engagement") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.fetchEngagementMetrics(forBusinessIds: ["biz-1"])
        #expect(response.data?.first?.businessId == "biz-1")
    }

    @Test func fetchEngagementMetricsReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "businesses/engagement"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/engagement") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.fetchEngagementMetrics(forBusinessIds: ["biz-1"])
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func fetchEngagementMetricsBypassesCacheDespiteCacheConfigurationEnabled() async throws {
        // Regression test: engagement metrics must never be served from cache — see the
        // fetchOpenings variant of this test above for the full rationale.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data("{}".utf8), statusCode: 200),
            forURLContaining: "businesses/engagement"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/engagement") }

        let client = CDYelpMockClientFactory.makeClient(cacheConfiguration: CDYelpCacheConfiguration(ttl: 300))
        _ = try await client.fetchEngagementMetrics(forBusinessIds: ["biz-1"])

        CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/engagement")

        await #expect(throws: Error.self) {
            _ = try await client.fetchEngagementMetrics(forBusinessIds: ["biz-1"])
        }
    }

    @Test func fetchServiceOfferingsReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"service_offerings":[{"id":"svc-1","name":"Delivery"}]}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "test-business-id/service_offerings"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "test-business-id/service_offerings") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.fetchServiceOfferings(forBusinessId: "test-business-id", locale: nil)
        #expect(response.serviceOfferings?.first?.id == "svc-1")
    }

    @Test func fetchServiceOfferingsReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "test-business-id/service_offerings"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "test-business-id/service_offerings") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.fetchServiceOfferings(forBusinessId: "test-business-id", locale: nil)
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func fetchServiceOfferingsBypassesCacheDespiteCacheConfigurationEnabled() async throws {
        // Regression test: service offerings must never be served from cache — see the
        // fetchOpenings variant of this test above for the full rationale.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data("{}".utf8), statusCode: 200),
            forURLContaining: "test-business-id/service_offerings"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "test-business-id/service_offerings") }

        let client = CDYelpMockClientFactory.makeClient(cacheConfiguration: CDYelpCacheConfiguration(ttl: 300))
        _ = try await client.fetchServiceOfferings(forBusinessId: "test-business-id", locale: nil)

        CDYelpMockURLProtocol.removeStub(forURLContaining: "test-business-id/service_offerings")

        await #expect(throws: Error.self) {
            _ = try await client.fetchServiceOfferings(forBusinessId: "test-business-id", locale: nil)
        }
    }

    @Test func fetchBusinessInsightsReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"insights":[{"business_id":"biz-1","metrics":{"page_views":10.0}}]}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/insights"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/insights") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.fetchBusinessInsights(
            forBusinessIds: ["biz-1"], dateRangeStart: "202601", dateRangeEnd: "202602"
        )
        #expect(response.insights?.first?.businessId == "biz-1")
    }

    @Test func fetchBusinessInsightsReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "businesses/insights"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/insights") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.fetchBusinessInsights(
                forBusinessIds: ["biz-1"], dateRangeStart: "202601", dateRangeEnd: "202602"
            )
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func fetchBusinessInsightsBypassesCacheDespiteCacheConfigurationEnabled() async throws {
        // Regression test: business insights must never be served from cache — see the
        // fetchOpenings variant of this test above for the full rationale.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data("{}".utf8), statusCode: 200),
            forURLContaining: "businesses/insights"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/insights") }

        let client = CDYelpMockClientFactory.makeClient(cacheConfiguration: CDYelpCacheConfiguration(ttl: 300))
        _ = try await client.fetchBusinessInsights(
            forBusinessIds: ["biz-1"], dateRangeStart: "202601", dateRangeEnd: "202602"
        )

        CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/insights")

        await #expect(throws: Error.self) {
            _ = try await client.fetchBusinessInsights(
                forBusinessIds: ["biz-1"], dateRangeStart: "202601", dateRangeEnd: "202602"
            )
        }
    }

    @Test func fetchReviewHighlightsReturnsDecodedResponse() async throws {
        let fixture = Data(#"{"highlights":[{"text":"Great food!","rating":5.0}]}"#.utf8)
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "test-business-id/review_highlights"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "test-business-id/review_highlights") }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.fetchReviewHighlights(forBusinessId: "test-business-id")
        #expect(response.highlights?.first?.text == "Great food!")
    }

    @Test func fetchReviewHighlightsReturns404AsSpecificHttpError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "test-business-id/review_highlights"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "test-business-id/review_highlights") }

        let client = CDYelpMockClientFactory.makeClient()
        do {
            _ = try await client.fetchReviewHighlights(forBusinessId: "test-business-id")
            Issue.record("Expected CDYelpNetworkError.httpError to be thrown")
        } catch let CDYelpNetworkError.httpError(statusCode, _, _) {
            #expect(statusCode == 404)
        } catch {
            Issue.record("Expected CDYelpNetworkError.httpError(404) but threw \(error)")
        }
    }

    @Test func fetchReviewHighlightsBypassesCacheDespiteCacheConfigurationEnabled() async throws {
        // Regression test: review highlights must never be served from cache — see the
        // fetchOpenings variant of this test above for the full rationale.
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data("{}".utf8), statusCode: 200),
            forURLContaining: "test-business-id/review_highlights"
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "test-business-id/review_highlights") }

        let client = CDYelpMockClientFactory.makeClient(cacheConfiguration: CDYelpCacheConfiguration(ttl: 300))
        _ = try await client.fetchReviewHighlights(forBusinessId: "test-business-id")

        CDYelpMockURLProtocol.removeStub(forURLContaining: "test-business-id/review_highlights")

        await #expect(throws: Error.self) {
            _ = try await client.fetchReviewHighlights(forBusinessId: "test-business-id")
        }
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
        if let url = urlRequest.url {
            _startedURLs.append(url)
        }
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
