# CDYelpFusionKit Improvements

## v6.0.0: Native URLSession Rewrite

**Goal:** Drop the Alamofire dependency entirely. Replace it with `URLSession`, `URLComponents`, and `JSONDecoder`. All public types, method signatures, and response models from v5 survive unchanged — only the internal implementation changes. The v5 test suite is the behavioral contract that catches regressions.

### Breaking changes (why this is a major version bump)

1. **`AFError` → `CDYelpNetworkError`** — async/await overloads currently throw `AFError` (an Alamofire type). In v6 they throw `CDYelpNetworkError`, a native Swift error type defined in the library.
2. **Completion-handler overloads removed** — every `public func foo(..., completion:)` is deleted. Callers use async/await only.
3. **Deployment targets raised** — `URLSession.data(for:)` with async/await requires iOS 15 / macOS 12 / tvOS 15 / watchOS 8.

Everything else is source-compatible: `CDYelpCacheConfiguration`, `CDYelpRetryConfiguration`, `CDYelpDecoderConfiguration`, `CDYelpEventMonitor`, `CDYelpRequestAdapter`, `CDYelpMockURLProtocol`, `CDYelpMockClientFactory`, and all response model types are unchanged.

---

### ✅ Step 1 — Raise deployment targets

#### `Package.swift`

Replace the existing `platforms:` array with:

```swift
platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8),
    .visionOS(.v1)
]
```

Also remove the Alamofire dependency:

```swift
// Delete this line from dependencies:
.package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.0")),

// Delete this line from the CDYelpFusionKit target's dependencies:
.product(name: "Alamofire", package: "Alamofire"),
```

#### `CDYelpFusionKit.podspec`

Change all `deployment_target` lines:

```ruby
s.ios.deployment_target = '15.0'
s.osx.deployment_target = '12.0'
s.tvos.deployment_target = '15.0'
s.watchos.deployment_target = '8.0'
s.visionos.deployment_target = '1.0'
```

Remove the Alamofire dependency line:

```ruby
# Delete:
c.dependency 'Alamofire', '~> 5.9'
```

---

### ✅ Step 2 — Create `Source/CDYelpNetworkError.swift`

Create this file from scratch:

```swift
import Foundation

public enum CDYelpNetworkError: Error, Sendable {
    case invalidRequest(underlying: Error)
    case httpError(statusCode: Int, data: Data)
    case decodingFailed(underlying: Error)
    case networkFailure(underlying: Error)
}
```

---

### ✅ Step 3 — Create `Source/Internal/CDYelpURLSession.swift`

Create this file from scratch. It is an internal actor that owns the `URLSession` and implements the full request/response cycle (adapters → cache check → network → retry → cache write → decode). It replaces the Alamofire `Session` and the `cachedRequest` helper that currently lives in `CDYelpAPIClient`.

```swift
import Foundation

actor CDYelpURLSession {
    private let session: URLSession
    private let makeDecoder: () -> JSONDecoder
    private let cache: CDYelpResponseCache?
    private let monitors: [any CDYelpEventMonitor]
    private let adapters: [any CDYelpRequestAdapter]
    private let retryConfig: CDYelpRetryConfiguration

    init(
        session: URLSession,
        makeDecoder: @escaping () -> JSONDecoder,
        cache: CDYelpResponseCache?,
        monitors: [any CDYelpEventMonitor],
        adapters: [any CDYelpRequestAdapter],
        retryConfig: CDYelpRetryConfiguration
    ) {
        self.session = session
        self.makeDecoder = makeDecoder
        self.cache = cache
        self.monitors = monitors
        self.adapters = adapters
        self.retryConfig = retryConfig
    }

    func perform<T: Decodable>(
        _ urlRequest: URLRequest,
        decoder: JSONDecoder? = nil,
        attempt: UInt = 0
    ) async throws -> T {
        var request = urlRequest
        for adapter in adapters {
            request = try adapter.adapt(request)
        }

        let cacheKey = CDYelpCacheKey.key(for: request)
        if let cache, let cached = cache.data(forKey: cacheKey) {
            let dec = decoder ?? makeDecoder()
            return try dec.decode(T.self, from: cached)
        }

        monitors.forEach { $0.requestDidStart(urlRequest: request) }

        let data: Data
        let httpResponse: HTTPURLResponse?
        do {
            let (responseData, response) = try await session.data(for: request)
            data = responseData
            httpResponse = response as? HTTPURLResponse
        } catch {
            monitors.forEach {
                $0.requestDidComplete(urlRequest: request, response: nil, data: nil, error: error)
            }
            let networkError = CDYelpNetworkError.networkFailure(underlying: error)
            if shouldRetry(statusCode: nil, attempt: attempt) {
                monitors.forEach { $0.requestWillRetry(urlRequest: request, retryCount: Int(attempt + 1)) }
                try await Task.sleep(nanoseconds: backoffNanoseconds(attempt: attempt))
                return try await perform(urlRequest, decoder: decoder, attempt: attempt + 1)
            }
            throw networkError
        }

        monitors.forEach {
            $0.requestDidComplete(urlRequest: request, response: httpResponse, data: data, error: nil)
        }

        let statusCode = httpResponse?.statusCode ?? 0
        guard (200 ..< 300).contains(statusCode) else {
            let error = CDYelpNetworkError.httpError(statusCode: statusCode, data: data)
            if shouldRetry(statusCode: statusCode, attempt: attempt) {
                monitors.forEach { $0.requestWillRetry(urlRequest: request, retryCount: Int(attempt + 1)) }
                try await Task.sleep(nanoseconds: backoffNanoseconds(attempt: attempt))
                return try await perform(urlRequest, decoder: decoder, attempt: attempt + 1)
            }
            throw error
        }

        cache?.set(data: data, forKey: cacheKey)

        let dec = decoder ?? makeDecoder()
        do {
            return try dec.decode(T.self, from: data)
        } catch {
            throw CDYelpNetworkError.decodingFailed(underlying: error)
        }
    }

    func cancelAllTasks() {
        session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }

    func clearCache() {
        cache?.removeAll()
    }

    private func shouldRetry(statusCode: Int?, attempt: UInt) -> Bool {
        guard attempt < retryConfig.retryLimit else { return false }
        if let code = statusCode {
            return retryConfig.retryableHTTPStatusCodes.contains(code)
        }
        return true
    }

    private func backoffNanoseconds(attempt: UInt) -> UInt64 {
        let delay = retryConfig.initialDelay * pow(2.0, Double(attempt))
        return UInt64(delay * 1_000_000_000)
    }
}
```

---

### Step 4 — Create `Source/Internal/CDYelpNativeRouter.swift`

Create this file from scratch. It replaces `CDYelpRouter.swift`. It builds `URLRequest` using `URLComponents` / `URLQueryItem` with no Alamofire dependency, and adds the `Authorization` header (which in v5 was injected by Alamofire via `sessionConfiguration.httpAdditionalHeaders`).

**Important:** `aiChat` routes to `https://api.yelp.com/ai/chat/v2` — a hardcoded URL that does **not** use `CDYelpURL.base` (which is `https://api.yelp.com/v3/`). All other endpoints use `CDYelpURL.base + path`.

```swift
import Foundation

enum CDYelpNativeRouter {
    // GET endpoints
    case search(parameters: [String: Any])
    case phone(parameters: [String: Any])
    case transactions(type: String, parameters: [String: Any])
    case business(id: String, parameters: [String: Any])
    case matches(parameters: [String: Any])
    case reviews(id: String, parameters: [String: Any])
    case autocomplete(parameters: [String: Any])
    case event(id: String, parameters: [String: Any])
    case events(parameters: [String: Any])
    case featuredEvent(parameters: [String: Any])
    case allCategories(parameters: [String: Any])
    case categoryDetails(alias: String, parameters: [String: Any])
    case engagement(parameters: [String: Any])
    case serviceOfferings(id: String, parameters: [String: Any])
    case businessInsights(parameters: [String: Any])
    case reviewHighlights(id: String, parameters: [String: Any])
    case openings(businessId: String, parameters: [String: Any])
    // POST endpoints
    case aiChat(request: CDYelpAIChatRequest)
    case jobs(query: String, locale: String?)

    var path: String {
        switch self {
        case .search:
            return "businesses/search"
        case .phone:
            return "businesses/search/phone"
        case let .transactions(type, _):
            return "transactions/\(type)/search"
        case let .business(id, _):
            return "businesses/\(id)"
        case .matches:
            return "businesses/matches"
        case let .reviews(id, _):
            return "businesses/\(id)/reviews"
        case .autocomplete:
            return "autocomplete"
        case let .event(id, _):
            return "events/\(id)"
        case .events:
            return "events"
        case .featuredEvent:
            return "events/featured"
        case .allCategories:
            return "categories"
        case let .categoryDetails(alias, _):
            return "categories/\(alias)"
        case .engagement:
            return "businesses/engagement"
        case let .serviceOfferings(id, _):
            return "businesses/\(id)/service_offerings"
        case .businessInsights:
            return "businesses/insights"
        case let .reviewHighlights(id, _):
            return "businesses/\(id)/review_highlights"
        case let .openings(businessId, _):
            return "bookings/\(businessId)/openings"
        case .aiChat:
            return "ai/chat/v2"
        case .jobs:
            return "jobs"
        }
    }

    func asURLRequest(apiKey: String) throws -> URLRequest {
        // aiChat: hardcoded URL outside /v3/ base
        if case let .aiChat(request) = self {
            guard let url = URL(string: "https://api.yelp.com/ai/chat/v2") else {
                throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(request)
            return urlRequest
        }

        // jobs: POST + JSON body under /v3/ base
        if case let .jobs(query, locale) = self {
            guard let url = URL(string: CDYelpURL.base + path) else {
                throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            var body: [String: String] = ["query": query]
            if let locale { body["locale"] = locale }
            urlRequest.httpBody = try JSONEncoder().encode(body)
            return urlRequest
        }

        // All other cases: GET + URL query parameters
        guard var components = URLComponents(string: CDYelpURL.base + path) else {
            throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
        }
        let params = queryParameters
        if !params.isEmpty {
            components.queryItems = params.map {
                URLQueryItem(name: $0.key, value: String(describing: $0.value))
            }
        }
        guard let url = components.url else {
            throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        return urlRequest
    }

    private var queryParameters: [String: Any] {
        switch self {
        case let .search(p), let .phone(p), let .matches(p),
             let .autocomplete(p), let .events(p), let .featuredEvent(p),
             let .allCategories(p), let .engagement(p), let .businessInsights(p):
            return p
        case .transactions(_, let p), .business(_, let p), .reviews(_, let p),
             .event(_, let p), .categoryDetails(_, let p), .serviceOfferings(_, let p),
             .reviewHighlights(_, let p), .openings(_, let p):
            return p
        case .aiChat, .jobs:
            return [:]
        }
    }
}
```

---

### Step 5 — Modify `Source/Parameters+CDYelpFusionKit.swift`

At the top of the file, **remove**:

```swift
import Alamofire
```

**Add** this typealias immediately after the `import Foundation` line (this replaces Alamofire's `Parameters` typealias so all existing function signatures compile unchanged):

```swift
typealias Parameters = [String: Any]
```

No other changes to this file are needed.

---

### Step 6 — Rewrite `Source/CDYelpAPIClient.swift`

This is the largest change. The rewrite follows these rules:
- Remove `import Alamofire`
- Change `public class CDYelpAPIClient: @unchecked Sendable` → `public final class CDYelpAPIClient: Sendable`
- Remove `// swiftlint:disable:next type_body_length` (no longer needed if the file shrinks enough, but keep it if SwiftLint still complains)
- Delete `makeSession` static func (replaced by `CDYelpURLSession` actor init)
- Delete stored properties: `sessionConfiguration`, `manager`, `eventMonitors`, `requestAdapters`
- Keep stored properties: `apiKey`, `responseCache`, `retryConfiguration`, `decoderConfiguration`
- Add stored property: `private let urlSession: CDYelpURLSession`
- Delete `cachedRequest<T>` private helper (caching now lives in the actor)
- Delete all `public func foo(..., completion:)` methods
- Replace all `@available(iOS 13.0, ...) public func foo(...) async throws` methods with non-annotated `public func foo(...) async throws` (deployment target is now iOS 15+, so `@available` is redundant)
- In each async method body, replace `withCheckedThrowingContinuation` with a direct call to `urlSession.perform(_:)`
- Replace `AFError` references with `CDYelpNetworkError`
- Remove `isAuthenticated()` method (the `precondition(!apiKey.isEmpty)` in `init` enforces this at construction time)
- `clearCache()` delegates to the actor: `Task { await urlSession.clearCache() }`
- `cancelAllPendingAPIRequests()` delegates to the actor: `Task { await urlSession.cancelAllTasks() }`

#### New `init` structure

The public `convenience init` and the internal testing `init` collapse into two `init` methods. The testing `init` signature is **identical to the v5 signature** so `CDYelpMockClientFactory` requires zero changes.

```swift
// Public init — uses URLSessionConfiguration.default
public convenience init(
    apiKey: String,
    cacheConfiguration: CDYelpCacheConfiguration = .disabled,
    retryConfiguration: CDYelpRetryConfiguration = .disabled,
    decoderConfiguration: CDYelpDecoderConfiguration = .default,
    eventMonitors: [any CDYelpEventMonitor] = [],
    requestAdapters: [any CDYelpRequestAdapter] = []
) {
    self.init(
        apiKey: apiKey,
        sessionConfiguration: .default,
        cacheConfiguration: cacheConfiguration,
        retryConfiguration: retryConfiguration,
        decoderConfiguration: decoderConfiguration,
        eventMonitors: eventMonitors,
        requestAdapters: requestAdapters
    )
}

// Internal testing init — accepts injected URLSessionConfiguration
// CDYelpMockClientFactory calls this init unchanged.
public init(
    apiKey: String,
    sessionConfiguration: URLSessionConfiguration,
    cacheConfiguration: CDYelpCacheConfiguration = .disabled,
    retryConfiguration: CDYelpRetryConfiguration = .disabled,
    decoderConfiguration: CDYelpDecoderConfiguration = .default,
    eventMonitors: [any CDYelpEventMonitor] = [],
    requestAdapters: [any CDYelpRequestAdapter] = []
) {
    precondition(!apiKey.isEmpty, "An apiKey is required to query the Yelp Fusion API.")
    self.apiKey = apiKey
    self.decoderConfiguration = decoderConfiguration
    self.retryConfiguration = retryConfiguration
    responseCache = cacheConfiguration.ttl > 0
        ? CDYelpResponseCache(configuration: cacheConfiguration)
        : nil
    urlSession = CDYelpURLSession(
        session: URLSession(configuration: sessionConfiguration),
        makeDecoder: { decoderConfiguration.makeDecoder() },
        cache: responseCache,
        monitors: eventMonitors,
        adapters: requestAdapters,
        retryConfig: retryConfiguration
    )
}
```

#### Pattern for each API method

Every endpoint follows this pattern. No `isAuthenticated()` check, no `completion:` parameter, no `withCheckedThrowingContinuation`:

```swift
public func searchBusinesses(
    byTerm term: String?,
    location: String?,
    latitude: Double?,
    longitude: Double?,
    radius: Int?,
    categories: [CDYelpCategoryAlias]?,
    locale: CDYelpLocale?,
    limit: Int?,
    offset: Int?,
    sortBy: CDYelpBusinessSortType?,
    priceTiers: [CDYelpPriceTier]?,
    openNow: Bool?,
    openAt: Int?,
    attributes: [CDYelpAttributeFilter]?,
    devicePlatform: String? = nil,
    reservationDate: String? = nil,
    reservationTime: String? = nil,
    reservationCovers: Int? = nil,
    matchesPartySize: Bool? = nil,
    jobAlias: String? = nil
) async throws -> CDYelpSearchResponse.Business {
    assert(
        (latitude != nil && longitude != nil) || location != nil,
        "Either a latitude and longitude or a location are required."
    )
    if let radius { assert(radius > 0 && radius <= 40000, "The radius must be 40,000 meters or less.") }
    if let limit { assert(limit > 0 && limit <= 50, "The limit must be 50 or less.") }
    let parameters = Parameters.searchParameters(
        withTerm: term, location: location, latitude: latitude, longitude: longitude,
        radius: radius, categories: categories, locale: locale, limit: limit, offset: offset,
        sortBy: sortBy, priceTiers: priceTiers, openNow: openNow, openAt: openAt,
        attributes: attributes, devicePlatform: devicePlatform, reservationDate: reservationDate,
        reservationTime: reservationTime, reservationCovers: reservationCovers,
        matchesPartySize: matchesPartySize, jobAlias: jobAlias
    )
    let request = try CDYelpNativeRouter.search(parameters: parameters).asURLRequest(apiKey: apiKey)
    return try await urlSession.perform(request)
}
```

#### Special case: endpoints with custom date decoding

`fetchReviews`, `fetchEvent`, `searchEvents`, and `fetchFeaturedEvent` need a custom `JSONDecoder` with `dateDecodingStrategy` set. Pass it to `urlSession.perform(_:decoder:)`:

```swift
public func fetchReviews(
    forBusinessId id: String!,
    locale: CDYelpLocale?,
    offset: Int? = nil,
    limit: Int? = nil,
    sortBy: CDYelpReviewSortType? = nil
) async throws -> CDYelpReviewsResponse {
    assert(id != nil && id.count > 0, "A business id is required.")
    if let offset { assert(offset >= 0 && offset <= 1000, "offset must be between 0 and 1000.") }
    if let limit { assert(limit >= 0 && limit <= 50, "The limit must be between 0 and 50.") }
    let parameters = Parameters.reviewsParameters(withLocale: locale, offset: offset, limit: limit, sortBy: sortBy)
    let request = try CDYelpNativeRouter.reviews(id: id, parameters: parameters).asURLRequest(apiKey: apiKey)
    let decoder = decoderConfiguration.makeDecoder()
    decoder.dateDecodingStrategy = .formatted(DateFormatter.reviews)
    return try await urlSession.perform(request, decoder: decoder)
}
```

Apply the same `decoder` pattern to `fetchEvent`, `searchEvents`, and `fetchFeaturedEvent` (they use `DateFormatter.events`).

#### `clearCache` and `cancelAllPendingAPIRequests`

```swift
public func clearCache() {
    Task { await urlSession.clearCache() }
}

public func cancelAllPendingAPIRequests() {
    Task { await urlSession.cancelAllTasks() }
}
```

#### `fetchAIChat` — note the `requestContext` parameter

The current v5 signature includes `requestContext: [String: String]?`. Preserve it in v6:

```swift
public func fetchAIChat(
    query: String,
    chatId: String? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil,
    requestContext: [String: String]? = nil
) async throws -> CDYelpAIChatResponse {
    precondition(!query.isEmpty, "A query is required.")
    precondition(query.count <= 1000, "Query must be 1000 characters or fewer.")
    let userContext: CDYelpAIChatRequest.UserContext? = (latitude != nil && longitude != nil)
        ? .init(latitude: latitude!, longitude: longitude!)
        : nil
    let chatRequest = CDYelpAIChatRequest(
        query: query, chatId: chatId, userContext: userContext, requestContext: requestContext
    )
    let urlRequest = try CDYelpNativeRouter.aiChat(request: chatRequest).asURLRequest(apiKey: apiKey)
    return try await urlSession.perform(urlRequest)
}
```

---

### Step 7 — Delete these files

Use `git rm` to remove all three:

- `Source/CDYelpRouter.swift`
- `Source/Internal/CDYelpAlamofireEventMonitor.swift`
- `Source/Internal/CDYelpAlamofireRequestAdapter.swift`

---

### Step 8 — `Source/Testing/CDYelpMockClientFactory.swift` — no changes needed

`CDYelpMockClientFactory.makeClient(apiKey:cacheConfiguration:eventMonitors:)` calls the testing `init(apiKey:sessionConfiguration:...)`. That signature is preserved exactly in v6. The `CDYelpMockURLProtocol` intercepts the native `URLSession` — this continues to work because `CDYelpURLSession` wraps a plain `URLSession` and the protocol class is registered on the `URLSessionConfiguration` before the session is created.

No changes to `CDYelpMockURLProtocol.swift` either.

---

### Step 9 — Update router tests

The existing router tests in `Tests/CDYelpFusionKitTests/Router/CDYelpRouterTests.swift` call `CDYelpRouter.X.asURLRequest()`. In v6, update every call site:

| v5 | v6 |
|---|---|
| `CDYelpRouter.search(parameters: params).asURLRequest()` | `try CDYelpNativeRouter.search(parameters: params).asURLRequest(apiKey: "test-key")` |
| `CDYelpRouter.phone(parameters: params).asURLRequest()` | `try CDYelpNativeRouter.phone(parameters: params).asURLRequest(apiKey: "test-key")` |
| *(same pattern for all 19 cases)* | |

The assertions in the tests (correct URL host, path, query parameters, HTTP method) are identical — only the call site changes.

Also: any `import Alamofire` at the top of test files must be removed. Any `AFError` references in test assertions must be replaced with `CDYelpNetworkError`.

---

### Step 10 — CI matrix: remove old simulator versions

In `.github/workflows/ci.yml`, remove any simulator destination entries that only support OS versions below the new minimums:
- iOS below 15
- macOS below 12
- tvOS below 15
- watchOS below 8

visionOS 1.0 already satisfies its minimum.

---

### How the v5 test suite acts as the contract

| Test file | What it verifies | v6 implementation under test |
|---|---|---|
| `CDYelpResponseCacheTests` | TTL expiry, store/retrieve, clear | `CDYelpResponseCache` (unchanged) |
| `CDYelpRetryConfigurationTests` | Retry limit, backoff config | `CDYelpURLSession.shouldRetry` + `backoffNanoseconds` |
| `CDYelpDecoderConfigurationTests` | Key strategy applied | `CDYelpURLSession.perform` decode step |
| `CDYelpEventMonitorTests` | Monitor callbacks fire | `CDYelpURLSession` direct calls to monitors |
| `CDYelpAPIClientTests` | End-to-end decode via mock session | `CDYelpURLSession` + `CDYelpNativeRouter` |
| Model tests | JSON → struct decode | Unchanged — `Decodable` conformances are untouched |
| Router tests | URL path/parameter construction | Rewritten to call `CDYelpNativeRouter.asURLRequest(apiKey:)` |

---

### v6 Completion Checklist

#### Step 1 — Deployment targets
- [x] Update `platforms:` in `Package.swift` to iOS 15 / macOS 12 / tvOS 15 / watchOS 8 / visionOS 1
- [x] Remove Alamofire from `Package.swift` `dependencies` and target `dependencies`
- [x] Update `deployment_target` in `CDYelpFusionKit.podspec` to match
- [x] Remove `c.dependency 'Alamofire', '~> 5.9'` from podspec

#### Step 2 — New file: `Source/CDYelpNetworkError.swift`
- [x] Create file with `CDYelpNetworkError` enum (4 cases: `invalidRequest`, `httpError`, `decodingFailed`, `networkFailure`)

#### Step 3 — New file: `Source/Internal/CDYelpURLSession.swift`
- [x] Create actor with `perform<T>(_:decoder:attempt:)`, `cancelAllTasks()`, `clearCache()`
- [x] Retry calls `requestWillRetry` monitor callback before sleeping

#### Step 4 — New file: `Source/Internal/CDYelpNativeRouter.swift`
- [ ] Create enum with all 19 cases (17 GET + 2 POST)
- [ ] `path` covers all 19 cases
- [ ] `asURLRequest(apiKey:)` handles aiChat (hardcoded URL, no `/v3/`), jobs (POST+JSON under `/v3/`), and all GET cases (URLComponents + query items)
- [ ] Authorization header (`Bearer \(apiKey)`) added in `asURLRequest(apiKey:)` for all cases

#### Step 5 — Modify `Source/Parameters+CDYelpFusionKit.swift`
- [ ] Remove `import Alamofire`
- [ ] Add `typealias Parameters = [String: Any]`

#### Step 6 — Rewrite `Source/CDYelpAPIClient.swift`
- [ ] Remove `import Alamofire`
- [ ] Change class declaration to `public final class CDYelpAPIClient: Sendable`
- [ ] Delete `makeSession` static func
- [ ] Delete stored properties: `sessionConfiguration`, `manager`, `eventMonitors`, `requestAdapters`
- [ ] Add stored property `private let urlSession: CDYelpURLSession`
- [ ] Rewrite `convenience init` and testing `init` (testing `init` signature unchanged)
- [ ] Delete `isAuthenticated()` method
- [ ] Rewrite `clearCache()` and `cancelAllPendingAPIRequests()` to delegate to actor
- [ ] Delete `cachedRequest<T>` private helper
- [ ] Delete all completion-handler overloads
- [ ] Replace all async overloads: remove `@available`, remove `withCheckedThrowingContinuation`, call `urlSession.perform(_:)` directly
- [ ] Pass custom `decoder` to `urlSession.perform(_:decoder:)` for `fetchReviews`, `fetchEvent`, `searchEvents`, `fetchFeaturedEvent`
- [ ] Preserve `requestContext` parameter on `fetchAIChat`

#### Step 7 — Delete files
- [ ] `git rm Source/CDYelpRouter.swift`
- [ ] `git rm Source/Internal/CDYelpAlamofireEventMonitor.swift`
- [ ] `git rm Source/Internal/CDYelpAlamofireRequestAdapter.swift`

#### Step 8 — Testing infrastructure (no changes)
- [ ] Confirm `CDYelpMockClientFactory.swift` compiles unchanged
- [ ] Confirm `CDYelpMockURLProtocol.swift` compiles unchanged

#### Step 9 — Update router tests
- [ ] Replace all `CDYelpRouter.X.asURLRequest()` calls with `try CDYelpNativeRouter.X.asURLRequest(apiKey: "test-key")`
- [ ] Remove any `import Alamofire` from test files
- [ ] Replace any `AFError` references with `CDYelpNetworkError`

#### Step 10 — CI matrix
- [ ] Remove simulator destinations below iOS 15 / macOS 12 / tvOS 15 / watchOS 8 from `.github/workflows/ci.yml`

#### Final verification
- [ ] Run `swift build` — must succeed with zero Alamofire imports remaining
- [ ] Run `swift test` — all tests must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations
- [ ] Run `pod trunk push CDYelpFusionKit.podspec` — lint must pass
