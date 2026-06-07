# CDYelpFusionKit 5.0 Migration Guide

Guide for upgrading from CDYelpFusionKit 4.0.0 to 5.0.0.

---

## Breaking Changes

**There are no breaking changes in v5.0.0.**

All new `CDYelpAPIClient` init parameters are opt-in with sensible defaults. Existing `CDYelpAPIClient(apiKey:)` call sites compile and behave identically.

---

## New Features

### Response Caching

Pass a `CDYelpCacheConfiguration` to cache responses in memory for a configurable TTL:

```swift
// v4.x — no caching
let client = CDYelpAPIClient(apiKey: "your-api-key")

// v5.0 — opt-in caching (5-minute TTL, 100 entries max)
let client = CDYelpAPIClient(
    apiKey: "your-api-key",
    cacheConfiguration: CDYelpCacheConfiguration(ttl: 300, countLimit: 100)
)

// Invalidate the entire cache at any time
client.clearCache()
```

Caching is disabled by default (`CDYelpCacheConfiguration.disabled`).

---

### Retry Strategy

Pass a `CDYelpRetryConfiguration` to enable automatic retry with exponential backoff:

```swift
// v5.0 — retry up to 3 times starting at 0.5 s
let client = CDYelpAPIClient(
    apiKey: "your-api-key",
    retryConfiguration: CDYelpRetryConfiguration(
        retryLimit: 3,
        initialDelay: 0.5,
        retryableHTTPStatusCodes: [429, 500, 502, 503, 504]
    )
)
```

A `CDYelpRetryConfiguration.default` preset is available for convenience. Retrying is disabled by default (`CDYelpRetryConfiguration.disabled`).

---

### Event Monitoring

Pass one or more `CDYelpEventMonitor` implementations to observe every request/response cycle:

```swift
final class RequestLogger: CDYelpEventMonitor {
    func requestDidStart(urlRequest: URLRequest) {
        print("→ \(urlRequest.url?.absoluteString ?? "")")
    }

    func requestDidComplete(urlRequest: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) {
        print("← \(response?.statusCode ?? 0)")
    }

    func requestWillRetry(urlRequest: URLRequest?, retryCount: Int) {
        print("↩ retry \(retryCount) for \(urlRequest?.url?.absoluteString ?? "")")
    }
}

let client = CDYelpAPIClient(
    apiKey: "your-api-key",
    eventMonitors: [RequestLogger()]
)
```

---

### Request Adapters

Pass one or more `CDYelpRequestAdapter` implementations to mutate every `URLRequest` before it is sent:

```swift
final class CorrelationIDAdapter: CDYelpRequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Correlation-ID")
        return request
    }
}

let client = CDYelpAPIClient(
    apiKey: "your-api-key",
    requestAdapters: [CorrelationIDAdapter()]
)
```

---

### Custom Decoders

Pass a `CDYelpDecoderConfiguration` to override the JSON decoding strategy:

```swift
let client = CDYelpAPIClient(
    apiKey: "your-api-key",
    decoderConfiguration: CDYelpDecoderConfiguration(
        keyDecodingStrategy: .convertFromSnakeCase
    )
)
```

---

### Testing Utilities (`CDYelpFusionKitTesting` product)

A new `CDYelpFusionKitTesting` library product provides `CDYelpMockURLProtocol` and `CDYelpMockClientFactory` for testing code that uses `CDYelpAPIClient` without making real network requests.

**Add the dependency to your test targets only:**

**Swift Package Manager:**
```swift
.testTarget(
    name: "MyAppTests",
    dependencies: ["CDYelpFusionKit", "CDYelpFusionKitTesting"]
)
```

**CocoaPods:**
```ruby
target 'MyAppTests' do
  pod 'CDYelpFusionKit/Testing'
end
```

**Usage:**
```swift
import CDYelpFusionKit
import CDYelpFusionKitTesting
import Testing

struct MyFeatureTests {
    @Test func searchReturnsResults() async throws {
        let fixture = """
        {"businesses": [{"id": "abc", "name": "Test Cafe"}], "total": 1}
        """.data(using: .utf8)!

        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeAllStubs() }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.searchBusinesses(
            byTerm: "coffee", location: "SF",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )
        #expect(response.businesses?.first?.name == "Test Cafe")
    }
}
```

---

## Bug Fixes

### Date Parsing Now Works Correctly

Two date-parsing methods that always returned `nil` in v4.x are now fixed:

- `CDYelpReview.timeCreatedAsDate()` — now uses the correct `"yyyy-MM-dd HH:mm:ss"` format
- `CDYelpSpecialHour.dateAsDate()` — now uses the correct `"yyyy-MM-dd"` format

If your code was working around these always returning `nil`, you can remove those workarounds.

---

## Migration Checklist

- [ ] **No changes required** for existing `CDYelpAPIClient(apiKey:)` usage — all new parameters are opt-in
- [ ] **Opt in to caching** by passing `cacheConfiguration:` if you want in-memory response caching
- [ ] **Opt in to retry** by passing `retryConfiguration:` for automatic exponential-backoff retry
- [ ] **Add testing utilities** by depending on `CDYelpFusionKitTesting` in your test targets
- [ ] **Remove date workarounds** if you patched around `timeCreatedAsDate()` or `dateAsDate()` always returning `nil`
- [ ] **Run your test suite** to confirm no regressions

---

## Support

- [CDYelpFusionKit GitHub Issues](https://github.com/chrisdhaan/CDYelpFusionKit/issues)
- [Usage Guide](Usage.md)
- [Architecture Documentation](ARCHITECTURE.md)
- [Yelp Fusion API Docs](https://www.yelp.com/developers/documentation/v3)
