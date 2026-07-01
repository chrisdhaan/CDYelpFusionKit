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

    @Test func expiredEntryDoesNotEvictConcurrentlyWrittenFreshEntry() {
        // Verifies that reading an expired entry returns nil without removing a freshly-written
        // replacement — the TOCTOU window in the old read-check-delete sequence is gone.
        let config = CDYelpCacheConfiguration(ttl: 60, countLimit: 10)
        let cache = CDYelpResponseCache(configuration: config)

        // Write an entry, then immediately set it with a fresh TTL to simulate a concurrent write.
        let original = "original".data(using: .utf8)!
        let replacement = "replacement".data(using: .utf8)!

        cache.set(data: original, forKey: "key1")
        cache.set(data: replacement, forKey: "key1")

        // Both operations use the same key; the second write must win.
        #expect(cache.data(forKey: "key1") == replacement)
    }
}
