@testable import CDYelpFusionKit
import Foundation
import Testing

struct CDYelpResponseCacheTests {
    @Test func storesAndRetrieves() {
        let config = CDYelpCacheConfiguration(ttl: 60, countLimit: 10)
        let cache = CDYelpResponseCache(configuration: config)
        let data = "hello".data(using: .utf8)!

        cache.set(data: data, forKey: "key1")
        #expect(cache.data(forKey: "key1") == data)
    }

    @Test func expiredEntryReturnsNil() async throws {
        let config = CDYelpCacheConfiguration(ttl: 0.1, countLimit: 10)
        let cache = CDYelpResponseCache(configuration: config)
        let data = "hello".data(using: .utf8)!

        cache.set(data: data, forKey: "key1")
        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(cache.data(forKey: "key1") == nil)
    }

    @Test func removeAllClearsCache() {
        let config = CDYelpCacheConfiguration(ttl: 60, countLimit: 10)
        let cache = CDYelpResponseCache(configuration: config)
        let data = "hello".data(using: .utf8)!

        cache.set(data: data, forKey: "key1")
        cache.removeAll()
        #expect(cache.data(forKey: "key1") == nil)
    }

    @Test func disabledConfigurationStoresNothing() {
        let cache = CDYelpResponseCache(configuration: .disabled)
        let data = "hello".data(using: .utf8)!

        cache.set(data: data, forKey: "key1")
        #expect(cache.data(forKey: "key1") == nil)
    }

    @Test func cacheKeyIsStableViaRouter() throws {
        let request1 = try CDYelpRouter.allCategories(parameters: [:]).asURLRequest(apiKey: "test-key")
        let request2 = try CDYelpRouter.allCategories(parameters: [:]).asURLRequest(apiKey: "test-key")
        #expect(CDYelpCacheKey.key(for: request1) == CDYelpCacheKey.key(for: request2))
    }

    @Test func cacheKeyIsStableWithMultipleParameters() throws {
        let params: [String: Any] = ["term": "coffee", "location": "San Francisco", "limit": 20]
        let request1 = try CDYelpRouter.search(parameters: params).asURLRequest(apiKey: "test-key")
        let request2 = try CDYelpRouter.search(parameters: params).asURLRequest(apiKey: "test-key")
        #expect(CDYelpCacheKey.key(for: request1) == CDYelpCacheKey.key(for: request2))
    }

    @Test func removeEvictsOnlyTargetedKey() {
        let config = CDYelpCacheConfiguration(ttl: 60, countLimit: 10)
        let cache = CDYelpResponseCache(configuration: config)
        let data = "hello".data(using: .utf8)!

        cache.set(data: data, forKey: "key1")
        cache.set(data: data, forKey: "key2")
        cache.remove(forKey: "key1")

        #expect(cache.data(forKey: "key1") == nil)
        #expect(cache.data(forKey: "key2") == data)
    }

    @Test func expiredEntryDoesNotEvictConcurrentlyWrittenFreshEntry() async throws {
        // Regression test for the TOCTOU fix: the old read-check-delete sequence called
        // cache.removeObject(forKey:) whenever it found an expired entry. If a concurrent
        // writer replaced that same key in the gap between the expiry check and the
        // removeObject call, the fresh entry it just wrote would be deleted out from under
        // it. The fix removed the removeObject call entirely, so an expired read is now a
        // pure miss that never touches the cache. Rather than racing real threads against a
        // nanosecond-wide window (unreliable in a unit test), attach an NSCacheDelegate and
        // assert directly that reading an expired entry triggers zero evictions.
        let config = CDYelpCacheConfiguration(ttl: 0.05, countLimit: 10)
        let cache = CDYelpResponseCache(configuration: config)
        let recorder = EvictionRecorder()

        try cache.set(data: #require("stale".data(using: .utf8)), forKey: "key1")
        try await Task.sleep(nanoseconds: 100_000_000)

        // Attach the delegate only after priming the entry, so the setup write above isn't recorded.
        cache.cache.delegate = recorder

        #expect(cache.data(forKey: "key1") == nil)
        #expect(recorder.evictionCount == 0)

        // Detach the delegate before `cache` goes out of scope: NSCache invokes its delegate
        // for any objects still present when it deallocates, and by then `recorder` may already
        // be gone, which crashes rather than no-oping.
        cache.cache.delegate = nil
    }
}

private final class EvictionRecorder: NSObject, NSCacheDelegate {
    private(set) var evictionCount = 0

    func cache(_: NSCache<AnyObject, AnyObject>, willEvictObject _: Any) {
        evictionCount += 1
    }
}
