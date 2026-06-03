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

    @Test func cacheKeyIsStable() throws {
        var request = try URLRequest(url: #require(URL(string: "https://api.yelp.com/v3/businesses/search?term=coffee")))
        request.httpMethod = "GET"
        let key1 = CDYelpCacheKey.key(for: request)
        let key2 = CDYelpCacheKey.key(for: request)
        #expect(key1 == key2)
    }
}
