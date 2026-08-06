# CDYelpFusionKit Architecture

Technical documentation describing the internal design and structure of CDYelpFusionKit.

## Dependency Graph

```
CDYelpFusionKit
    ↓
URLSession (Apple Foundation)
    ↓
Network stack (OS-level)
```

CDYelpFusionKit is dependency-free. It uses Apple's `URLSession` directly via an internal `CDYelpURLSession` Swift actor, eliminating the Alamofire dependency introduced in earlier versions.

---

## Request Lifecycle

### Step-by-Step Flow

#### 1. API Client Method Call

```swift
let client = CDYelpAPIClient(apiKey: "key")
let response = try await client.searchBusinesses(byTerm: "coffee", location: "San Francisco", ...)
```

The `CDYelpAPIClient` instance is created once and reused for multiple requests.

#### 2. Parameter Assembly

The API method builds parameters into a dictionary:

```swift
var parameters: [String: Any] = [:]
if let term = term {
    parameters["term"] = term
}
if let location = location {
    parameters["location"] = location
}
// ... additional parameters
```

Parameters are validated and filtered by `Parameters+CDYelpFusionKit.swift`.

#### 3. Router Enum Creation

A `CDYelpRouter` enum case is created with the parameters:

```swift
let router = CDYelpRouter.search(parameters: parameters)
```

Each router case encodes:
- The Yelp API endpoint path
- HTTP method (GET for most endpoints, POST for `aiChat` and `jobs`)
- Query parameters (GET) or JSON body (POST)

#### 4. URL Request Conversion

The router's `asURLRequest(apiKey:)` method constructs a `URLRequest`:

```swift
// Inside CDYelpRouter.asURLRequest(apiKey:)
var urlComponents = URLComponents(string: baseURL + path)
urlComponents?.queryItems = queryParams.map {
    URLQueryItem(name: $0.key, value: String(describing: $0.value))
}
// Cache keys use a sorted canonical form via CDYelpCacheKey.key(for:);
// the URL itself is not sorted.

var request = URLRequest(url: urlComponents!.url!)
request.httpMethod = "GET"
// applyStandardHeaders sets all four headers below on every request, plus
// Content-Type when a body is present (POST endpoints only).
request.allHTTPHeaderFields = [
    "User-Agent": CDYelpFusionKitUserAgent,
    "Authorization": "Bearer \(apiKey)",
    "Accept": "application/json",
    "Accept-Language": defaultAcceptLanguage
]
return request
```

#### 5. Adapter Chain

Before the request is sent, each registered `CDYelpRequestAdapter` mutates the `URLRequest` in order:

```swift
for adapter in adapters {
    request = try adapter.adapt(request)
}
```

This is where custom headers, correlation IDs, or request signing can be injected.

#### 6. Cache Lookup

The cache key is derived from the canonical URL (query parameters sorted alphabetically). If a cached response exists within its TTL, it is decoded and returned immediately — no network request is made. If the cached bytes fail to decode (e.g. after a model shape change in an app update), the entry is evicted and execution falls through to a live network fetch below, rather than throwing — a stale, corrupt cache entry should not fail the caller when the network can serve a fresh response right now.

```swift
let cacheKey = CDYelpCacheKey.key(for: request)
if let cache, let cached = cache.data(forKey: cacheKey) {
    if let decoded = try? decoder.decode(T.self, from: cached) {
        return decoded
    }
    cache.remove(forKey: cacheKey)
    // ... falls through to the live network fetch below
}
```

#### 7. URLSession Dispatch

If no cache hit, the request is dispatched via `URLSession.data(for:)`:

```swift
let (data, response) = try await session.data(for: request)
```

Monitors are notified at the start of the request and again when it completes:

```swift
for monitor in monitors {
    monitor.requestDidStart(urlRequest: request)
}
// ... dispatch ...
for monitor in monitors {
    monitor.requestDidComplete(urlRequest: request, response: httpResponse, data: data, error: nil)
}
```

#### 8. HTTP Status Validation

The response status code is checked. Non-2xx responses throw `CDYelpNetworkError.httpError(statusCode:data:headers:)`. Retryable status codes (e.g. 429, 500–504) trigger the retry path.

#### 9. Retry

When a retryable failure occurs (network error or retryable status code), the actor waits for the backoff delay and loops back to the top of an explicit `while true` loop. `retryOrThrow` takes `attempt` as `inout` and increments it itself (so every call site doesn't repeat the increment) before returning to allow a retry, or notifies monitors and throws if the failure is terminal:

```swift
try await retryOrThrow(error, request: request, attempt: &attempt, response: httpResponse, data: data)
continue
```

The backoff delay prefers a server-provided `Retry-After` response header (seconds or HTTP-date form) when present, falling back to exponential backoff (`initialDelay * 2^attempt`, capped at 300s) otherwise. The sleep itself is wrapped in `trackedSleep(nanoseconds:)` rather than a bare `Task.sleep` — see the Cancellation details under `CDYelpURLSession` in Key Types below.

Monitors receive a `requestWillRetry` notification before each retry.

#### 10. JSON Decoding

On a successful 2xx response, the data is decoded into the expected type:

```swift
let dec = decoder ?? makeDecoder()
return try dec.decode(T.self, from: data)
```

Decoding failures throw `CDYelpNetworkError.decodingFailed(underlying:)`.

The successfully decoded raw `Data` is then stored in the cache (if caching is enabled), keyed by canonical URL.

---

## Key Types

### CDYelpAPIClient

`public final class CDYelpAPIClient: Sendable`

The public entry point. Holds the API key, a `CDYelpURLSession` actor, and the five opt-in configuration objects. All 19 endpoint methods are pure `async throws` functions — no completion-handler variants exist in v6.

```swift
public final class CDYelpAPIClient: Sendable {
    private let apiKey: String
    private let urlSession: CDYelpURLSession

    public init(
        apiKey: String,
        cacheConfiguration: CDYelpCacheConfiguration = .disabled,
        retryConfiguration: CDYelpRetryConfiguration = .disabled,
        decoderConfiguration: CDYelpDecoderConfiguration = .default,
        eventMonitors: [any CDYelpEventMonitor] = [],
        requestAdapters: [any CDYelpRequestAdapter] = []
    )
}
```

### CDYelpURLSession

`actor CDYelpURLSession`

Internal Swift actor that owns the `URLSession` and orchestrates the full pipeline: adapter chain → cache → network → retry → decode. Being an actor ensures its mutable state (the `CDYelpResponseCache` instance) is protected from concurrent access without additional locks.

Cancellation has two parts, both awaited by `cancelAllTasks()` so cancellation is guaranteed to be in effect by the time it returns:
- In-flight network calls: cancelled via `await session.tasks`, then `task.cancel()` on each data/upload/download task.
- In-flight retry-backoff sleeps: tracked in `retrySleepTasks: [UUID: Task<Void, Error>]` (populated by `trackedSleep(nanoseconds:)`) and cancelled explicitly. A plain `Task.sleep` wouldn't observe `cancelAllTasks()`, and — because it runs in an unstructured `Task` for tracking purposes — wouldn't observe the ambient caller's `Task.cancel()` either without `trackedSleep` forwarding it via `withTaskCancellationHandler`.

### CDYelpRouter

`enum CDYelpRouter` (internal)

19-case enum mapping each API endpoint to its URL path, HTTP method, and parameters. `asURLRequest(apiKey:)` constructs the `URLRequest`, injecting the Bearer token header. The `apiKey` parameter is explicit rather than stored on the router.

### CDYelpNetworkError

`public enum CDYelpNetworkError: Error`

Four-case native Swift error type thrown by all async API methods:

| Case | Meaning |
|------|---------|
| `.invalidRequest(underlying:)` | URL could not be constructed from the given parameters |
| `.networkFailure(underlying:)` | URLSession threw an error (no connectivity, timeout, etc.) |
| `.httpError(statusCode:data:headers:)` | Server returned a non-2xx status code |
| `.decodingFailed(underlying:)` | `JSONDecoder` failed to parse the response body |

---

## Authentication

### Bearer Token Pattern

All Yelp Fusion API requests require authentication via HTTP Bearer token:

```
Authorization: Bearer YOUR_API_KEY
```

The API key is passed as an explicit `apiKey:` parameter to `CDYelpRouter.asURLRequest(apiKey:)`, ensuring it is injected at request-construction time and never stored on the router enum itself.

### Security Notes

- The API key is **not logged or exposed** in request bodies
- The API key is transmitted via HTTPS only
- Never commit API keys to source control; use environment variables or secure configuration files
- Consider rotating API keys periodically via the Yelp Developer Console

---

## Model Hierarchy

### Type Structure

CDYelpFusionKit uses nested structs to represent complex API responses:

```
CDYelpSearchResponse
├── businesses: [CDYelpBusiness.BusinessSearch]
├── total: Int
├── region: CDYelpRegion
└── ...
```

### BusinessSearch vs Detailed

The `CDYelpBusiness` type has multiple variants to represent different API endpoints:

#### CDYelpBusiness.BusinessSearch

Used in `/businesses/search` endpoint:

```swift
public struct BusinessSearch: Decodable {
    public let id: String?
    public let name: String?
    public let rating: Double?
    public let price: String?
    public let isOpen: Bool?
    public let imageUrl: String?
    // ... ~20 fields
}
```

Contains essential fields for search results (ID, name, rating, price, open status).

#### CDYelpBusiness.Detailed

Used in `/businesses/{id}` endpoint:

```swift
public struct Detailed: Decodable {
    public let id: String?
    public let name: String?
    public let rating: Double?
    // ... all BusinessSearch fields plus:
    public let phone: String?
    public let hours: [CDYelpHour]?
    public let specialHours: [CDYelpSpecialHour]?
    public let categories: [CDYelpCategory]?
    public let location: CDYelpLocation?
    // ... ~40 total fields
}
```

Includes additional fields like phone, hours, and full location details.

### Why Nested Structs?

Nesting prevents namespace pollution — without nesting, we would need:
- `CDYelpBusinessSearch`
- `CDYelpBusinessDetailed`
- `CDYelpBusinessMatch`

Instead, we have clean namespacing:
- `CDYelpBusiness.BusinessSearch`
- `CDYelpBusiness.Detailed`
- `CDYelpBusiness.Match`

### Codable Conformance

All models conform to `Decodable` (not `Codable`) because:
- The library only **receives** JSON from Yelp (decoding)
- The library doesn't **send** models as JSON (encoding is not needed)
- This avoids unnecessary `Encodable` conformance boilerplate

---

## Enum Design

### CDYelpEnums.swift Structure

All public enum types are defined in a single file (`CDYelpEnums.swift`) containing 12+ enums:

```swift
// Sort types
public enum CDYelpBusinessSortType: String {
    case bestMatch = "best_match"
    case rating = "rating"
    case reviewCount = "review_count"
    case distance = "distance"
}

// Price tiers
public enum CDYelpPriceTier: String {
    case oneDollarSign = "1"
    case twoDollarSigns = "2"
    case threeDollarSigns = "3"
    case fourDollarSigns = "4"
}

// Locales
public enum CDYelpLocale: String {
    case english_unitedStates = "en_US"
    case english_canada = "en_CA"
    // ... 20+ locales
}

// ... and more
```

### RawValue Strategy

All enums use `String` raw values because they directly map to Yelp API query parameters:

```swift
public enum CDYelpBusinessSortType: String {
    case bestMatch = "best_match"
}

// In request building:
parameters["sort_by"] = CDYelpBusinessSortType.bestMatch.rawValue  // "best_match"
```

This avoids conversion logic — the enum value is used directly in the API request.

---

## Resource Files

### CDColor

`Source/CDColor.swift` and `Source/CDColor+CDYelpFusionKit.swift` provide color constants for Yelp branding:

```swift
public extension CDColor {
    class func yelpFiveStarRed() -> CDColor {
        return CDColor(red: 211.0 / 255.0, green: 35.0 / 255.0, blue: 35.0 / 255.0, alpha: 1.0)
    }
}
```

Available on iOS, tvOS, and visionOS (UIKit-based platforms). macOS uses `NSColor`.

### CDImage

`Source/CDImage.swift` and `Source/CDImage+CDYelpFusionKit.swift` provide star rating images:

```swift
public extension CDImage {
    class func yelpStars(numberOfStars: CDYelpStars!, forSize size: CDYelpStarsSize!) -> CDImage? {
        // Returns a pre-rendered star rating image (e.g., 4.5 stars as image)
    }
}
```

Stars are rendered at multiple sizes (`small`, `regular`, `large`, `extraLarge`).

### Asset Catalog

`Resources/Images.xcassets` contains:
- Star rating images (0-5 stars, in 0.5 increments except for 0, at 4 sizes = 40 images)
- Yelp logo variations (light, dark, monochrome)
- Brand colors are hardcoded RGB literals in `CDColor+CDYelpFusionKit.swift`, not asset catalog colorsets

---

## Error Handling

### CDYelpNetworkError

All async API methods throw `CDYelpNetworkError`:

```swift
Task {
    do {
        let response = try await client.searchBusinesses(...)
    } catch let error as CDYelpNetworkError {
        switch error {
        case .invalidRequest(let underlying):
            // Bad parameters: underlying contains the construction error
        case .networkFailure(let underlying):
            // No connectivity, timeout, etc.
        case .httpError(let statusCode, let data, let headers):
            // Non-2xx response; data contains the raw body, headers the response headers
        case .decodingFailed(let underlying):
            // JSON parse error
        }
    }
}
```

### Error Propagation

Errors surface directly from `async throws` — there is no `nil`-on-error pattern. Callers must either catch errors or propagate them with `try`.

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `.invalidRequest(underlying:)` | Search parameters contain invalid characters | Validate input strings |
| `.httpError(statusCode: 401, _, _)` | Invalid API key | Check key in Yelp Developer Console |
| `.httpError(statusCode: 429, _, _)` | Rate limit exceeded | Enable `CDYelpRetryConfiguration` |
| `.httpError(statusCode: 404, _, _)` | Business or event ID not found | Verify the ID exists |
| `.networkFailure` | No connectivity or timeout | Check network; retry with backoff |
| `.decodingFailed` | API schema changed | Update CDYelpFusionKit |

---

## Thread Safety

### Actor-Based Isolation

`CDYelpURLSession` is a Swift actor. All access to internal mutable state (data tasks, cache) is serialized automatically by the actor runtime — no manual locking is needed.

### Sendable Conformance

`CDYelpAPIClient` is `public final class CDYelpAPIClient: Sendable`. This is safe because:
- `apiKey` is an immutable `let`
- `urlSession` is a `CDYelpURLSession` actor (actors are `Sendable`)
- No other mutable state is accessible from concurrent tasks

### Best Practices

- Create a single `CDYelpAPIClient` instance and reuse it (don't create per-request)
- Safe to call from any thread or async context
- No need for explicit synchronization in user code

---

## Performance Considerations

### Request Batching

Multiple concurrent requests don't require multiple API client instances:

```swift
async let search1 = client.searchBusinesses(...)
async let search2 = client.searchBusinesses(...)
async let search3 = client.searchBusinesses(...)

let (result1, result2, result3) = try await (search1, search2, search3)
```

URLSession automatically manages connection pooling and HTTP/2 multiplexing.

### Memory Management

- Response models are value types (structs) — cheap to copy
- Decodable deserialization uses Swift's built-in JSON decoder (optimized)
- Models are not retained by the client; each call returns fresh decoded objects

### Caching

CDYelpFusionKit provides opt-in in-memory response caching via `CDYelpCacheConfiguration`. The cache is backed by `CDYelpResponseCache` (an `NSCache` wrapper with TTL tracking).

Cache keys are built by `CDYelpCacheKey.key(for:)`, which normalises URL query parameters to a sorted canonical form so that parameter dictionary ordering does not produce cache misses.

Bytes are only stored after a successful decode, preventing a bad response from poisoning the cache for the TTL window.

---

## Platform-Specific Behavior

### iOS / tvOS / visionOS

All functionality available. Full UI rendering support via UIKit/SwiftUI.

### macOS

All functionality available. Uses `AppKit` (NSColor, NSImage) instead of UIKit.

### watchOS

All functionality available for network requests. UI rendering is more limited than iOS, but not absent:

- `CDImage` is a `UIImage` typealias on watchOS (`Package.swift` links UIKit for this platform), so the framework's own star rating images render normally via `CDImage.yelpStars(numberOfStars:forSize:)`
- Remote business photos (`imageUrl`) still need to be downloaded and displayed by your app, same as on any platform
- All API methods work identically to iOS

---

## Testing Architecture

### Unit Tests

Tests use Swift Testing framework (`import Testing`) with fixtures:

```swift
@Suite struct CDYelpBusinessTests {
    @Test func businessSearchDecodesFromJSON() throws {
        let json = """
        { "id": "test", "name": "Test Business" }
        """
        let business = try JSONDecoder().decode(
            CDYelpBusiness.BusinessSearch.self,
            from: json.data(using: .utf8)!
        )
        #expect(business.id == "test")
    }
}
```

### Router Tests

Router tests validate URL construction without network access:

```swift
@Suite struct CDYelpRouterTests {
    @Test func searchRouterProducesGetRequest() throws {
        let router = CDYelpRouter.search(parameters: ["term": "coffee"])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.httpMethod == "GET")
        #expect(request.url?.host == "api.yelp.com")
    }
}
```

### Integration Testing

`CDYelpMockURLProtocol` and `CDYelpMockClientFactory` (part of the `CDYelpFusionKitTesting` target) enable end-to-end integration tests against the real `CDYelpAPIClient` without network access:

```swift
CDYelpMockURLProtocol.register(
    stub: .init(data: fixtureData, statusCode: 200),
    forURLContaining: "businesses/search"
)
defer { CDYelpMockURLProtocol.removeStub(forURLContaining: "businesses/search") }

let client = CDYelpMockClientFactory.makeClient()
let response = try await client.searchBusinesses(...)
```

JSON fixtures live in `Tests/CDYelpFusionKitTests/Fixtures/` and are loaded via `FixtureLoader`.

---

## Documentation Generation

### DocC Integration

API documentation is generated via Swift's native DocC system:

```bash
bash scripts/generate-docs.sh
```

Generated docs are published to GitHub Pages at [chrisdhaan.github.io/CDYelpFusionKit](https://chrisdhaan.github.io/CDYelpFusionKit).

### Documentation Patterns

All public API includes triple-slash `///` documentation comments:

```swift
/// Searches for businesses using the Yelp Fusion Search API.
/// - Parameter term: Business type or name (e.g., "coffee", "restaurants").
/// - Parameter location: Location string (e.g., "San Francisco").
/// - Returns: A ``CDYelpSearchResponse`` containing matching businesses.
/// - Throws: ``CDYelpNetworkError`` if the request fails.
public func searchBusinesses(...) async throws -> CDYelpSearchResponse
```
