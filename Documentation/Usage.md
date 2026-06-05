# CDYelpFusionKit Usage Guide

A comprehensive guide to using CDYelpFusionKit for Yelp Fusion API integration.

## Basic Setup

### Installation

#### Swift Package Manager

Add CDYelpFusionKit to your `Package.swift` or Xcode project:

```swift
dependencies: [
    .package(url: "https://github.com/chrisdhaan/CDYelpFusionKit.git", .upToNextMajor(from: "5.0.0"))
]
```

Then add it to your target's dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["CDYelpFusionKit"]
)
```

#### CocoaPods

Add to your `Podfile`:

```ruby
pod 'CDYelpFusionKit', '~> 5.0'
```

Then run `pod install`.

#### Carthage (Legacy)

Carthage support has been removed in v4.0.0. Please migrate to SPM or CocoaPods.

---

## Authentication

All Yelp Fusion API requests require an API key. Obtain one from the [Yelp Fusion API Console](https://www.yelp.com/developers/v3/manage_app).

Initialize the client with your API key:

```swift
import CDYelpFusionKit

let client = CDYelpAPIClient(apiKey: "your-api-key-here")
```

The API key is required and must be a non-empty string. An assertion will fail at runtime if the key is empty.

---

## Business Endpoints

### Search Businesses

Search for businesses by term, location, and optional filters:

**Completion Handler:**
```swift
client.searchBusinesses(
    byTerm: "coffee",
    location: "San Francisco",
    latitude: nil,
    longitude: nil,
    radius: nil,
    categories: nil,
    locale: .english_unitedStates,
    limit: 20,
    offset: nil,
    sortBy: .bestMatch,
    priceTiers: nil,
    openNow: nil,
    openAt: nil,
    attributes: nil
) { response in
    guard let businesses = response?.businesses else {
        print("No results found")
        return
    }
    for business in businesses {
        print("\(business.name ?? "Unknown") - \(business.rating ?? 0) stars")
    }
}
```

**Async/Await (iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+):**
```swift
Task {
    do {
        let response = try await client.searchBusinesses(
            byTerm: "coffee",
            location: "San Francisco",
            latitude: nil,
            longitude: nil,
            radius: nil,
            categories: nil,
            locale: .english_unitedStates,
            limit: 20,
            offset: nil,
            sortBy: .bestMatch,
            priceTiers: nil,
            openNow: nil,
            openAt: nil,
            attributes: nil
        )
        let businesses = response.businesses ?? []
        print("Found \(businesses.count) businesses")
    } catch {
        print("Search failed: \(error)")
    }
}
```

### Search by Phone Number

Look up a business by its phone number:

```swift
client.searchBusinesses(byPhoneNumber: "+14157492060") { response in
    guard let business = response?.businesses?.first else {
        print("No business found")
        return
    }
    print("Found: \(business.name ?? "Unknown")")
}
```

### Search by Transaction Type

Search for businesses that support specific transactions (delivery, pickup, reservations):

```swift
client.searchBusinesses(
    byType: "delivery",
    latitude: 37.7749,
    longitude: -122.4194
) { response in
    guard let businesses = response?.businesses else { return }
    print("Found \(businesses.count) businesses with delivery")
}
```

### Fetch Business Details

Get detailed information about a specific business:

```swift
client.fetchBusiness(
    byId: "gary-danko-san-francisco",
    locale: .english_unitedStates
) { response in
    guard let business = response?.business else {
        print("Business not found")
        return
    }
    print("Hours: \(business.hours ?? [])")
    print("Phone: \(business.phone ?? "N/A")")
}
```

### Match Businesses

Find a business by matching provided details (name, address, phone):

```swift
client.fetchBusinesses(
    byMatchType: .default,
    name: "Gary Danko",
    addressOne: "800 North Point Street",
    addressTwo: nil,
    city: "San Francisco",
    state: "CA",
    country: "US",
    latitude: nil,
    longitude: nil,
    phone: nil,
    zipCode: nil,
    yelpBusinessId: nil,
    limit: 1,
    threshold: .normal
) { response in
    guard let business = response?.business else {
        print("No matching business found")
        return
    }
    print("Matched: \(business.name ?? "Unknown")")
}
```

### Fetch Reviews

Get reviews for a specific business:

```swift
client.fetchReviews(
    forBusinessId: "gary-danko-san-francisco",
    locale: .english_unitedStates
) { response in
    guard let reviews = response?.reviews else { return }
    for review in reviews {
        print("\(review.rating ?? 0) stars: \(review.text ?? "")")
    }
}
```

### Autocomplete

Get autocomplete suggestions for business searches:

```swift
client.fetchAutocompleteResults(
    byText: "coff",
    latitude: 37.7749,
    longitude: -122.4194,
    locale: .english_unitedStates
) { response in
    if let terms = response?.terms {
        print("Term suggestions: \(terms.map { $0.text ?? "" })")
    }
    if let categories = response?.categories {
        print("Categories: \(categories.map { $0.title ?? "" })")
    }
    if let businesses = response?.businesses {
        print("Businesses: \(businesses.map { $0.name ?? "" })")
    }
}
```

---

## Event Endpoints

### Search Events

Search for events by location and optional filters:

```swift
client.searchEvents(
    byLocale: .english_unitedStates,
    offset: nil,
    limit: 10,
    sortBy: .popularity,
    sortOn: .timeStart,
    categories: [.music, .foodAndDrink],
    startDate: nil,
    endDate: nil,
    isFree: nil,
    location: "San Francisco",
    latitude: nil,
    longitude: nil,
    radius: nil
) { response in
    guard let events = response?.events else { return }
    for event in events {
        print("Event: \(event.title ?? "Unknown")")
    }
}
```

### Fetch Event Details

Get detailed information about a specific event:

```swift
client.fetchEvent(
    byId: "san-francisco-yelp-elite-week",
    locale: .english_unitedStates
) { response in
    guard let event = response?.event else { return }
    print("Event: \(event.title ?? "Unknown")")
    print("Description: \(event.eventDescription ?? "N/A")")
}
```

### Fetch Featured Event

Get the featured event for a location:

```swift
client.fetchFeaturedEvent(
    byLocale: .english_unitedStates,
    location: "San Francisco",
    latitude: nil,
    longitude: nil
) { response in
    guard let event = response?.event else { return }
    print("Featured event: \(event.title ?? "Unknown")")
}
```

---

## Category Endpoints

### Fetch All Categories

Get all available Yelp business categories:

```swift
client.fetchAllCategories(locale: .english_unitedStates) { response in
    guard let categories = response?.categories else { return }
    for category in categories {
        print("\(category.title ?? "Unknown") (\(category.alias ?? ""))")
    }
}
```

### Fetch Category Details

Get details for a specific category:

```swift
client.fetchCategoryDetails(
    byAlias: "restaurants",
    locale: .english_unitedStates
) { response in
    guard let category = response?.category else { return }
    print("Category: \(category.title ?? "Unknown")")
    print("Alias: \(category.alias ?? "")")
}
```

---

## Async/Await Usage

All API methods have async/await overloads available on iOS 13+, macOS 10.15+, tvOS 13+, and watchOS 6+.

### Basic Pattern

Wrap API calls in a `Task` block:

```swift
Task {
    do {
        let response = try await client.searchBusinesses(...)
        // Use response
    } catch {
        // Handle error
    }
}
```

### With Main Thread Dispatch

Update UI on the main thread:

```swift
Task {
    do {
        let response = try await client.searchBusinesses(
            byTerm: "coffee",
            location: "San Francisco",
            latitude: nil,
            longitude: nil,
            radius: nil,
            categories: nil,
            locale: nil,
            limit: 10,
            offset: nil,
            sortBy: .bestMatch,
            priceTiers: nil,
            openNow: nil,
            openAt: nil,
            attributes: nil
        )
        
        DispatchQueue.main.async {
            // Update UI with response
            self.businesses = response.businesses ?? []
            self.tableView.reloadData()
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### Multiple Concurrent Requests

Use `async let` for concurrent API calls:

```swift
Task {
    async let searchResults = client.searchBusinesses(
        byTerm: "coffee",
        location: "San Francisco",
        latitude: nil,
        longitude: nil,
        radius: nil,
        categories: nil,
        locale: nil,
        limit: 10,
        offset: nil,
        sortBy: .bestMatch,
        priceTiers: nil,
        openNow: nil,
        openAt: nil,
        attributes: nil
    )
    
    async let eventResults = client.searchEvents(
        byLocale: .english_unitedStates,
        offset: nil,
        limit: 5,
        sortBy: .popularity,
        sortOn: .timeStart,
        categories: nil,
        startDate: nil,
        endDate: nil,
        isFree: nil,
        location: "San Francisco",
        latitude: nil,
        longitude: nil,
        radius: nil
    )
    
    do {
        let businesses = try await searchResults.businesses ?? []
        let events = try await eventResults.events ?? []
        print("Found \(businesses.count) businesses and \(events.count) events")
    } catch {
        print("Error: \(error)")
    }
}
```

---

## Error Handling

API methods throw `AFError` from the Alamofire framework when network requests fail.

### Handling Errors

```swift
Task {
    do {
        let response = try await client.searchBusinesses(...)
        // Use response
    } catch {
        if let afError = error as? AFError {
            switch afError {
            case .invalidURL(let url):
                print("Invalid URL: \(url)")
            case .parameterEncodingFailed(let reason):
                print("Parameter encoding failed: \(reason)")
            case .responseValidationFailed(let reason):
                print("Response validation failed: \(reason)")
            default:
                print("Alamofire error: \(afError)")
            }
        } else {
            print("Unknown error: \(error)")
        }
    }
}
```

### Graceful Degradation

Handle missing data gracefully:

```swift
Task {
    do {
        let response = try await client.searchBusinesses(...)
        let businesses = response.businesses ?? []
        if businesses.isEmpty {
            print("No results found")
        }
    } catch {
        print("Search unavailable: \(error.localizedDescription)")
    }
}
```

---

## Advanced Features

### Response Caching

Enable in-memory response caching by passing a `CDYelpCacheConfiguration` to the client initializer. Responses are cached by canonical URL and served from cache on repeat requests within the TTL window.

```swift
let client = CDYelpAPIClient(
    apiKey: "your-api-key",
    cacheConfiguration: CDYelpCacheConfiguration(
        ttl: 300,        // 5 minutes
        countLimit: 100, // max 100 cached responses
        totalCostLimit: 0 // unlimited bytes
    )
)

// First call hits the network
let response = try await client.searchBusinesses(byTerm: "coffee", location: "SF", ...)

// Repeat call within TTL is served from cache — no network request
let cached = try await client.searchBusinesses(byTerm: "coffee", location: "SF", ...)

// Manually invalidate the entire cache
client.clearCache()
```

Caching is disabled by default (`CDYelpCacheConfiguration.disabled`). Cached bytes are only stored after a successful decode, preventing poisoned cache entries from bad responses.

---

### Retry Strategy

Configure automatic retry with exponential backoff for transient failures:

```swift
let client = CDYelpAPIClient(
    apiKey: "your-api-key",
    retryConfiguration: CDYelpRetryConfiguration(
        retryLimit: 3,
        initialDelay: 0.5,                    // seconds (doubles each retry)
        retryableHTTPStatusCodes: [429, 500, 502, 503, 504]
    )
)
```

The default preset (`CDYelpRetryConfiguration.default`) retries 3 times starting at 0.5 s for network errors and common server-side status codes. Retrying is disabled by default (`CDYelpRetryConfiguration.disabled`).

---

### Event Monitoring

Implement `CDYelpEventMonitor` to observe every request/response cycle without subclassing the client — useful for logging, analytics, or debugging:

```swift
final class RequestLogger: CDYelpEventMonitor {
    func requestDidStart(urlRequest: URLRequest) {
        print("→ \(urlRequest.httpMethod ?? "GET") \(urlRequest.url?.absoluteString ?? "")")
    }

    func requestDidComplete(urlRequest: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) {
        let status = response?.statusCode.description ?? "no response"
        print("← \(status) \(urlRequest?.url?.absoluteString ?? "")")
    }

    func requestWillRetry(urlRequest: URLRequest?, error: Error?) {
        print("↩ retrying \(urlRequest?.url?.absoluteString ?? "") after \(error?.localizedDescription ?? "error")")
    }
}

let client = CDYelpAPIClient(
    apiKey: "your-api-key",
    eventMonitors: [RequestLogger()]
)
```

Multiple monitors can be passed in the array; all receive every event.

---

### Request Adapters

Implement `CDYelpRequestAdapter` to mutate every `URLRequest` before it is sent — useful for adding custom headers, request signing, or parameter injection:

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

Multiple adapters can be passed; they are applied in order.

---

### Custom Decoders

Override the JSON decoding strategy used for all responses:

```swift
let client = CDYelpAPIClient(
    apiKey: "your-api-key",
    decoderConfiguration: CDYelpDecoderConfiguration(
        keyDecodingStrategy: .convertFromSnakeCase
    )
)
```

> **Note:** `dateDecodingStrategy` is ignored for the reviews and events endpoints, which use fixed Yelp-specific date formats regardless of this setting.

---

### Testing Utilities

`CDYelpMockURLProtocol` and `CDYelpMockClientFactory` let you write unit tests against the real `CDYelpAPIClient` without making network requests.

**1. Register a stub response** before creating the client, then use `CDYelpMockClientFactory` to get a client whose session routes all requests through your stub:

```swift
import CDYelpFusionKit
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

**2. Stubs are matched by URL substring.** Any request whose URL contains the registered key triggers the stub.

**3. Availability.** The testing utilities are part of the `CDYelpFusionKitTesting` product, which is a separate library target. Add it as a dependency only in your test targets:

```swift
// In Package.swift
.testTarget(
    name: "MyAppTests",
    dependencies: ["CDYelpFusionKit", "CDYelpFusionKitTesting"]
)
```

---

## Enums Reference

### Sort Types

**Business Search Sort:**
- `.bestMatch` — Sorts by relevance (default)
- `.rating` — Sorts by average rating
- `.reviewCount` — Sorts by number of reviews
- `.distance` — Sorts by distance from search location

**Event Sort By:**
- `.ascending` — Ascending order
- `.descending` — Descending order

**Event Sort On:**
- `.popularity` — Sort by popularity
- `.timeStart` — Sort by event start time

### Price Tiers

Search businesses by price range:
- `.oneDollarSign` — $
- `.twoDollarSigns` — $$
- `.threeDollarSigns` — $$$
- `.fourDollarSigns` — $$$$

### Locales

Supported locales for API responses:
- `.english_unitedStates` — en_US
- `.english_canada` — en_CA
- `.english_unitedKingdom` — en_GB
- `.french_france` — fr_FR
- `.german_germany` — de_DE
- `.spanish_spain` — es_ES
- `.japanese_japan` — ja_JP

### Transaction Types

Filter by supported transaction types:
- `.foodDelivery` — delivery
- `.pickup` — pickup
- `.reservation` — restaurant_reservation

### Business Match Threshold

Control matching strictness:
- `.normal` — default (less strict)
- `.strict` — stricter matching
- `.none` — no matching threshold

### Event Categories

Search events by category:
- `.charities`
- `.fashion`
- `.festivalsAndFairs`
- `.film`
- `.foodAndDrink`
- `.kidsAndFamily`
- `.lecturesAndBooks`
- `.music`
- `.nightlife`
- `.other`
- `.performingArts`
- `.sportsAndActiveLife`
- `.visualArts`

### Attribute Filters

Filter businesses by attributes:
- `.hotAndNew` — hot_and_new
- `.reservation` — reservation
- `.deals` — deals
- `.genderNeutralRestrooms` — gender_neutral_restrooms
- `.wheelchairAccessible` — wheelchair_accessible

### Category Aliases

Browse by category alias:
- `.food` — food
- `.restaurants` — restaurants
- `.coffeeAndTea` — coffee
- `.activeLife` — active
- `.gyms` — gyms
- (100+ more available in `CDYelpCategoryAlias`)

### Star Ratings

Filter by star rating:
- `.zero` — 0 stars
- `.one` — 1 star
- `.oneHalf` — 1.5 stars
- `.two` — 2 stars
- `.twoHalf` — 2.5 stars
- `.three` — 3 stars
- `.threeHalf` — 3.5 stars
- `.four` — 4 stars
- `.fourHalf` — 4.5 stars
- `.five` — 5 stars

---

## Platform Notes

### watchOS

watchOS apps have limited capabilities compared to iOS/macOS:

- **No UIImage Rendering:** The framework cannot render images directly on watchOS. Fetch image URLs and handle display in your app.
- **Limited UI:** Use `WatchKit` framework components; avoid `UIKit` image operations.
- **Network Requests:** All API calls work identically to iOS.

Example:

```swift
client.searchBusinesses(
    byTerm: "coffee",
    location: "San Francisco",
    latitude: nil,
    longitude: nil,
    radius: nil,
    categories: nil,
    locale: nil,
    limit: 5,
    offset: nil,
    sortBy: .bestMatch,
    priceTiers: nil,
    openNow: nil,
    openAt: nil,
    attributes: nil
) { response in
    guard let businesses = response?.businesses else { return }
    for business in businesses {
        // Fetch image URL but don't try to render UIImage
        if let imageUrlString = business.imageUrl {
            print("Image URL: \(imageUrlString)")
            // Download and display using WatchKit-compatible methods
        }
    }
}
```

### macOS

macOS support is full-featured:

- All API methods work identically to iOS
- Use `AppKit` or `SwiftUI` for UI
- No platform-specific limitations

### tvOS

tvOS support is full-featured:

- All API methods work identically to iOS
- Use `TVUIKit` or `SwiftUI` for UI
- No platform-specific limitations

### visionOS

visionOS support is available on Apple Vision Pro:

- All API methods work identically to iOS
- Use `SwiftUI` or `RealityKit` for UI
- Minimum deployment target: visionOS 1.0

---

## Troubleshooting

### API Key Issues

**Error: "An apiKey is required"**
- Ensure your API key is non-empty and valid
- Get a key from [Yelp Fusion API Console](https://www.yelp.com/developers/v3/manage_app)

### Network Errors

**Error: "invalidURL"**
- Check that search parameters are valid (e.g., location is not empty)

**Error: "responseValidationFailed"**
- API may be temporarily unavailable
- Check your API key is valid
- Verify the business/event ID exists

### Rate Limiting

The Yelp Fusion API enforces rate limits:
- Check Alamofire's response headers for rate limit information
- Implement retry logic with exponential backoff for production apps

---

## Additional Resources

- [Yelp Fusion API Documentation](https://www.yelp.com/developers/documentation/v3)
- [CDYelpFusionKit GitHub Repository](https://github.com/chrisdhaan/CDYelpFusionKit)
- [Swift Package Manager Documentation](https://www.swift.org/package-manager/)
- [Alamofire Documentation](https://github.com/Alamofire/Alamofire)
