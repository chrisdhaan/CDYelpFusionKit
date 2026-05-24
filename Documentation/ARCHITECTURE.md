# CDYelpFusionKit Architecture

Technical documentation describing the internal design and structure of CDYelpFusionKit.

## Dependency Graph

```
CDYelpFusionKit
    ↓
Alamofire (≥ 5.9.0)
    ↓
URLSession (Apple Foundation)
    ↓
Network stack (OS-level)
```

### Relationship to Alamofire

CDYelpFusionKit wraps Alamofire to provide:
- **Request routing** — `CDYelpRouter` enum implements Alamofire's `URLRequestConvertible` protocol
- **Response decoding** — Uses Alamofire's `responseDecodable()` to automatically parse JSON into typed models
- **Authentication** — Adds Bearer token authentication via `HTTPHeaders`
- **Session management** — Shares a single `Alamofire.Session` for all API requests

Alamofire itself manages:
- HTTP connection pooling
- SSL/TLS certificate validation
- Request retry logic (not used by CDYelpFusionKit by default)
- Response serialization (used for Decodable models)

### URLSession

Alamofire is built on top of Apple's `URLSession`, which handles:
- Low-level networking
- DNS resolution and connection establishment
- HTTP/2 multiplexing (when available)
- Background session support

---

## Request Lifecycle

### Step-by-Step Flow

#### 1. API Client Method Call

```swift
let client = CDYelpAPIClient(apiKey: "key")
client.searchBusinesses(byTerm: "coffee", location: "San Francisco", ...) { response in
    // Handle response
}
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

Each router case contains:
- The Yelp API endpoint path
- HTTP method (GET for all current endpoints)
- Request headers (including Bearer token)
- Query parameters

#### 4. URL Request Conversion

The router's `asURLRequest()` method (conforming to Alamofire's `URLRequestConvertible`) constructs a `URLRequest`:

```swift
// Inside CDYelpRouter.asURLRequest()
var urlComponents = URLComponents(string: baseURL + path)
urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0, value: String(describing: $1)) }

var request = URLRequest(url: urlComponents.url!)
request.httpMethod = "GET"
request.allHTTPHeaderFields = [
    "Authorization": "Bearer \(apiKey)",
    "Accept": "application/json"
]
return request
```

#### 5. Alamofire Request Execution

The `CDYelpAPIClient` passes the request to Alamofire's `Session`:

```swift
manager.request(router)
    .responseDecodable(of: CDYelpSearchResponse.self) { response in
        switch response.result {
        case .success(let value):
            completion(value)
        case .failure(let error):
            print("error: \(error)")
            completion(nil)
        }
    }
```

Alamofire:
- Constructs the actual HTTP request
- Manages the network connection
- Sends the request to `api.yelp.com`
- Receives the HTTP response

#### 6. JSON Deserialization

When the response arrives, Alamofire automatically decodes the JSON body into a Swift model:

```swift
// Alamofire calls JSONDecoder internally
let decoder = JSONDecoder()
let response = try decoder.decode(CDYelpSearchResponse.self, from: data)
```

The `CDYelpSearchResponse` struct (and all nested models) conform to `Decodable`, allowing Swift's built-in JSON decoder to parse the response.

#### 7. Completion Handler Execution

The decoded response (or error) is passed back to the caller:

```swift
completion(response)  // CDYelpSearchResponse or nil on error
```

### Async/Await Alternative

Async/await overloads use `withCheckedThrowingContinuation` to bridge the completion-handler-based Alamofire API:

```swift
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func searchBusinesses(...) async throws -> CDYelpSearchResponse {
    try await withCheckedThrowingContinuation { continuation in
        manager.request(router)
            .responseDecodable(of: CDYelpSearchResponse.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
    }
}
```

---

## Authentication

### Bearer Token Pattern

All Yelp Fusion API requests require authentication via HTTP Bearer token:

```
Authorization: Bearer YOUR_API_KEY
```

### Implementation in CDYelpAPIClient

The API key is stored as a private property and injected into every request:

```swift
public class CDYelpAPIClient {
    private let apiKey: String
    private let manager: Session
    
    public init(apiKey: String) {
        precondition(!apiKey.isEmpty, "An apiKey is required...")
        self.apiKey = apiKey
        
        // Create a custom Session with default headers
        var headers = HTTPHeaders.default
        headers["Authorization"] = "Bearer \(apiKey)"
        
        let configuration = URLSessionConfiguration.default
        self.manager = Session(
            configuration: configuration,
            httpHeaders: headers
        )
    }
}
```

### Request Headers

Every request includes:
- `Authorization: Bearer <apiKey>` — Required for authentication
- `Accept: application/json` — Tells Yelp API to return JSON
- Standard `User-Agent` and `Accept-Encoding` headers (added by Alamofire)

### Security Notes

- The API key is **not logged or exposed** in request bodies
- The API key is transmitted via HTTPS only (enforced by the router)
- Never commit API keys to source control; use environment variables or secure configuration
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

### Nested Response Models

Response objects nest their contained models:

```swift
public struct CDYelpSearchResponse: Decodable {
    public let businesses: [CDYelpBusiness.BusinessSearch]?
    public let total: Int?
    public let region: CDYelpRegion?
}

public struct CDYelpBusinessResponse: Decodable {
    public let business: CDYelpBusiness.Detailed?
}
```

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

### Historical Rationale

The single-file approach was adopted for two reasons:

1. **Reduced import complexity** — Users import once: `import CDYelpFusionKit`
2. **Simplified maintenance** — All enum variants in one place for consistency checks

### Future Split Plan

A future major version (v5.0) could split enums into logical files:

```
Source/
├── Enums/
│   ├── CDYelpSortEnums.swift
│   ├── CDYelpFilterEnums.swift
│   ├── CDYelpLocaleEnums.swift
│   ├── CDYelpCategoryEnums.swift
│   └── CDYelpAttributeEnums.swift
└── CDYelpEnums.swift (re-exports all for backward compatibility)
```

This would:
- Improve code organization
- Make git diffs cleaner for enum-specific changes
- Maintain backward compatibility via re-exports

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
public extension UIColor {
    class var yelpRed: UIColor {
        return UIColor(red: 0.835, green: 0.000, blue: 0.000, alpha: 1.0)
    }
}
```

Available on iOS, tvOS, and visionOS (UIKit-based platforms). macOS uses `NSColor`.

### CDImage

`Source/CDImage.swift` and `Source/CDImage+CDYelpFusionKit.swift` provide star rating images:

```swift
public extension UIImage {
    class func yelpStars(rating: CDYelpStars, size: CDYelpStarsSize) -> UIImage? {
        // Returns pre-rendered star rating image (e.g., 4.5 stars as image)
    }
}
```

Stars are rendered at multiple sizes (`small`, `regular`, `large`, `extraLarge`).

### Asset Catalog

`Resources/Assets.xcassets` contains:
- Star rating images (0-5 stars, in 0.5 increments, at 4 sizes = 44 images)
- Yelp logo variations (light, dark, monochrome)
- Brand colors (pre-configured in the asset catalog for SwiftUI/Storyboard compatibility)

The asset catalog is included in the SPM package via `resources` in `Package.swift`:

```swift
.target(
    name: "CDYelpFusionKit",
    resources: [.process("PrivacyInfo.xcprivacy")]
)
```

### Usage Example

Rendering star ratings in a UITableViewCell:

```swift
if let stars = business.rating {
    let starEnum = CDYelpStars(rating: stars)  // Converts 4.5 → .fourHalf
    let starImage = UIImage.yelpStars(rating: starEnum, size: .regular)
    self.starImageView.image = starImage
}
```

---

## Error Handling

### Error Types

The library uses Alamofire's `AFError` enum for all network-related errors:

```swift
public enum AFError: Error {
    case invalidURL(url: URLConvertible)
    case parameterEncodingFailed(reason: ParameterEncodingFailureReason)
    case responseValidationFailed(reason: ResponseValidationFailureReason)
    case responseSerializationFailed(reason: ResponseSerializationFailureReason)
    // ... more cases
}
```

### Error Propagation (Completion Handlers)

Completion-handler-based methods return the response or `nil` on error:

```swift
public func searchBusinesses(..., completion: @escaping (CDYelpSearchResponse?) -> Void) {
    manager.request(...)
        .responseDecodable(of: CDYelpSearchResponse.self) { response in
            switch response.result {
            case .success(let value):
                completion(value)
            case .failure(let error):
                // Error is silently dropped; completion called with nil
                completion(nil)
            }
        }
}
```

This pattern maintains backward compatibility — callers check for nil rather than handling errors.

### Error Propagation (Async/Await)

Async/await overloads throw `AFError` for proper error handling:

```swift
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func searchBusinesses(...) async throws -> CDYelpSearchResponse {
    try await withCheckedThrowingContinuation { continuation in
        manager.request(...)
            .responseDecodable(of: CDYelpSearchResponse.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
    }
}
```

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `invalidURL` | Search parameters contain invalid characters | Validate input strings |
| `responseSerializationFailed` | API returned non-JSON response | Check API status; verify endpoint exists |
| `responseValidationFailed` | HTTP status is not 2xx | Check API key validity; check rate limits |
| Network timeout | Request took too long | Check network connectivity; retry with backoff |

---

## Thread Safety

### Alamofire.Session Thread Safety

Alamofire's `Session` is thread-safe and can be safely accessed from multiple threads/queues. CDYelpFusionKit's `manager` property is shared across all API methods and requires no synchronization.

### Sendable Conformance

For Swift 6 strict concurrency:

```swift
public class CDYelpAPIClient: @unchecked Sendable {
    // manager is thread-safe (Alamofire.Session is Sendable)
}
```

The `@unchecked Sendable` conformance is justified because:
- `manager` (Alamofire.Session) is thread-safe
- `apiKey` is immutable (never modified after init)
- No other mutable state is accessed from concurrent tasks

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

Alamofire's session automatically manages connection pooling and multiplexing.

### Memory Management

- Response models are value types (structs) — they're cheap to copy
- Decodable deserialization is fast (Swift's built-in JSON decoder is optimized)
- Models are not cached; each request returns a fresh decoded object
- Completion handlers should use weak captures to avoid retain cycles:

```swift
client.searchBusinesses(...) { [weak self] response in
    self?.updateUI(response)
}
```

### Caching

CDYelpFusionKit does **not** implement response caching. Implement caching at the application level if needed:

```swift
var cachedSearchResults: [String: CDYelpSearchResponse] = [:]

func searchOrUseCached(term: String) async throws -> CDYelpSearchResponse {
    if let cached = cachedSearchResults[term] {
        return cached
    }
    let result = try await client.searchBusinesses(byTerm: term, ...)
    cachedSearchResults[term] = result
    return result
}
```

---

## Platform-Specific Behavior

### iOS / tvOS / visionOS

All functionality available. Full UI rendering support via UIKit/SwiftUI.

### macOS

All functionality available. Uses `AppKit` (NSColor, NSImage) instead of UIKit.

### watchOS

All functionality available for network requests. Limited UI rendering:

- No access to `UIImage` (WatchKit does not support UIKit)
- Use image URLs directly; render via `AsyncImage` or WatchKit image views
- All API methods work identically to iOS

---

## Future Architecture Changes

### Potential Improvements

1. **Middleware/Interceptor Pattern** — Add request/response interceptors for logging, metrics, or request modification
2. **Response Caching Layer** — Built-in cache with TTL support
3. **Retry Strategy** — Configurable exponential backoff for transient failures
4. **Custom Decoders** — Allow users to provide custom JSON decoding strategies
5. **Testing Utilities** — Mock networking for unit tests

These would be introduced in v5.0.0 without breaking the public API.

### Backward Compatibility

CDYelpFusionKit commits to semantic versioning:
- **Patch versions** — Bug fixes only
- **Minor versions** — New features, backward-compatible
- **Major versions** — Breaking changes allowed (e.g., v3.x → v4.0)

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
        let request = try router.asURLRequest()
        #expect(request.httpMethod == "GET")
        #expect(request.url?.host == "api.yelp.com")
    }
}
```

### Integration Testing

Integration tests (not in the repo) would use actual API calls and a test API key.

---

## Documentation Generation

### DocC Integration

API documentation is generated via Swift's native DocC system:

```bash
swift package --disable-sandbox generate-documentation \
  --target CDYelpFusionKit \
  --output-path docs \
  --transform-for-static-hosting \
  --hosting-base-path CDYelpFusionKit
```

Generated docs are published to GitHub Pages at [chrisdhaan.github.io/CDYelpFusionKit](https://chrisdhaan.github.io/CDYelpFusionKit).

### Documentation Patterns

All public API includes triple-slash `///` documentation comments:

```swift
/// Searches for businesses using the Yelp Fusion Search API.
/// - Parameter term: Business type or name (e.g., "coffee", "restaurants").
/// - Parameter location: Location string (e.g., "San Francisco").
/// - Returns: A ``CDYelpSearchResponse`` containing matching businesses.
/// - Throws: ``AFError`` if the request fails.
public func searchBusinesses(...) async throws -> CDYelpSearchResponse
```

DocC cross-references use backtick syntax (e.g., `` ``CDYelpSearchResponse`` ``).
