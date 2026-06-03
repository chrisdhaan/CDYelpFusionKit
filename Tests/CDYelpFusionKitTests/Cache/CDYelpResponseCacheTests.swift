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
        let request1 = try CDYelpRouter.allCategories(parameters: [:]).asURLRequest()
        let request2 = try CDYelpRouter.allCategories(parameters: [:]).asURLRequest()
        #expect(CDYelpCacheKey.key(for: request1) == CDYelpCacheKey.key(for: request2))
    }

    @Test func cacheKeyIsStableWithMultipleParameters() throws {
        let params: [String: Any] = ["term": "coffee", "location": "San Francisco", "limit": 20]
        let request1 = try CDYelpRouter.search(parameters: params).asURLRequest()
        let request2 = try CDYelpRouter.search(parameters: params).asURLRequest()
        #expect(CDYelpCacheKey.key(for: request1) == CDYelpCacheKey.key(for: request2))
    }
}
