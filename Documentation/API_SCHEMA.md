# CDYelpFusionKit API Schema

This document maps every endpoint in the [Yelp Fusion REST API](https://docs.developer.yelp.com/reference) to its implementation status in CDYelpFusionKit. For fully-implemented endpoints the schema is verified against the live API docs. For unimplemented endpoints, a detailed implementation plan is provided.

**Status legend**

| Symbol | Meaning |
|--------|---------|
| ✅ | Fully implemented; schema verified against current API docs |
| ⚠️ | Implemented with schema gaps (missing parameters) |
| ❌ | Not implemented |
| 🔒 | Not implemented; requires partner/enterprise access or elevated plan |

---

## Table of Contents

### Businesses
1. [Business Search — ⚠️ Implemented (schema gaps)](#1-business-search--implemented-schema-gaps)
2. [Phone Search — ⚠️ Implemented (schema gaps)](#2-phone-search--implemented-schema-gaps)
3. [Business Match — ✅ Implemented](#3-business-match--implemented)
4. [Business Details — ⚠️ Implemented (schema gaps)](#4-business-details--implemented-schema-gaps)
5. [Food Delivery Search — ⚠️ Implemented (schema gaps)](#5-food-delivery-search--implemented-schema-gaps)
6. [Yelp AI Chat — ❌ Not Implemented](#6-yelp-ai-chat--not-implemented)
7. [Engagement Metrics — 🔒 Not Implemented (special permissions)](#7-engagement-metrics--not-implemented-special-permissions)
8. [Service Offerings — 🔒 Not Implemented (special permissions)](#8-service-offerings--not-implemented-special-permissions)
9. [Business Insights — 🔒 Not Implemented (special permissions)](#9-business-insights--not-implemented-special-permissions)

### Reviews
10. [Reviews — ⚠️ Implemented (schema gaps)](#10-reviews--implemented-schema-gaps)
11. [Review Highlights — 🔒 Not Implemented (Premium Plan)](#11-review-highlights--not-implemented-premium-plan)

### Events
12. [Event Search — ✅ Implemented](#12-event-search--implemented)
13. [Event Details — ✅ Implemented](#13-event-details--implemented)
14. [Featured Event — ✅ Implemented](#14-featured-event--implemented)

### Categories
15. [All Categories — ✅ Implemented](#15-all-categories--implemented)
16. [Category Details — ✅ Implemented](#16-category-details--implemented)

### Home Services
17. [Home Services — ❌ Not Implemented](#17-home-services--not-implemented)

### Autocomplete
18. [Autocomplete — ✅ Implemented](#18-autocomplete--implemented)

### OAuth
19. [OAuth Authorization — ❌ Not Applicable](#19-oauth-authorization--not-applicable)

### Data Ingestion
20. [Data Ingestion — 🔒 Not Implemented (partner only)](#20-data-ingestion--not-implemented-partner-only)

### Leads
21. [Leads — 🔒 Not Implemented (OAuth + advertising required)](#21-leads--not-implemented-oauth--advertising-required)

### Webhooks
22. [Webhooks (deprecated) — ❌ Not Implemented](#22-webhooks-deprecated--not-implemented)

### Reservations
23. [Reservations — ❌ Not Implemented](#23-reservations--not-implemented)

---

## Businesses

---

### 1. Business Search — ⚠️ Implemented (schema gaps)

**API reference:** https://docs.developer.yelp.com/reference/v3_business_search  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/search`  
**Swift method:** `CDYelpAPIClient.searchBusinesses(byTerm:location:latitude:longitude:radius:categories:locale:limit:offset:sortBy:priceTiers:openNow:openAt:attributes:)`  
**Response type:** `CDYelpSearchResponse.Business`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `term` | string | No | ✅ | |
| `location` | string | Conditional | ✅ | Required unless lat/lng provided |
| `latitude` | number | Conditional | ✅ | Required unless location provided |
| `longitude` | number | Conditional | ✅ | Required unless location provided |
| `radius` | integer | No | ✅ | Max 40,000 m; asserted in client |
| `categories` | array | No | ✅ | Comma-joined `CDYelpCategoryAlias` raw values |
| `locale` | string | No | ✅ | `CDYelpLocale` raw value |
| `limit` | integer | No | ✅ | 0–50; asserted in client |
| `offset` | integer | No | ✅ | 0–1000 |
| `sort_by` | string | No | ✅ | `CDYelpBusinessSortType` raw value |
| `price` | array | No | ✅ | Comma-joined `CDYelpPriceTier` raw values |
| `open_now` | boolean | No | ✅ | |
| `open_at` | integer | No | ✅ | Unix timestamp |
| `attributes` | array | No | ✅ | Comma-joined `CDYelpAttributeFilter` raw values |
| `device_platform` | string | No | ❌ | Missing; values: `android`, `ios`, `mobile-generic` |
| `reservation_date` | string | No | ❌ | Missing; format: `YYYY-MM-DD` |
| `reservation_time` | string | No | ❌ | Missing; format: `HH:MM` |
| `reservation_covers` | integer | No | ❌ | Missing; party size 1–10 |
| `matches_party_size_param` | boolean | No | ❌ | Missing; filters results to those matching party size |
| `job_alias` | string | No | ❌ | Missing; filters by home-service job type alias |

#### Schema gaps — fix instructions

Add 6 optional parameters to the search method without breaking existing callers.

**Step 1 — `Source/Parameters+CDYelpFusionKit.swift`**

Extend `searchParameters(...)` signature with 6 new trailing parameters and append them to `parameters` in the body:

```swift
static func searchParameters(
    withTerm term: String?,
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
    devicePlatform: String?,        // NEW — "android" | "ios" | "mobile-generic"
    reservationDate: String?,       // NEW — "YYYY-MM-DD"
    reservationTime: String?,       // NEW — "HH:MM"
    reservationCovers: Int?,        // NEW — 1..10
    matchesPartySize: Bool?,        // NEW
    jobAlias: String?               // NEW
) -> Parameters {
    // ... all existing parameter-building code unchanged ...

    // Append after the existing attributes block:
    if let devicePlatform = devicePlatform {
        parameters["device_platform"] = devicePlatform
    }
    if let reservationDate = reservationDate {
        parameters["reservation_date"] = reservationDate
    }
    if let reservationTime = reservationTime {
        parameters["reservation_time"] = reservationTime
    }
    if let reservationCovers = reservationCovers {
        parameters["reservation_covers"] = reservationCovers
    }
    if let matchesPartySize = matchesPartySize {
        parameters["matches_party_size_param"] = matchesPartySize
    }
    if let jobAlias = jobAlias {
        parameters["job_alias"] = jobAlias
    }
    return parameters
}
```

**Step 2 — `Source/CDYelpAPIClient.swift` (callback overload)**

Add the same 6 parameters (all `= nil` defaulted) to `searchBusinesses(byTerm:...)` and pass them through to `searchParameters(...)`.

**Step 3 — `Source/CDYelpAPIClient.swift` (async overload)**

Add the same 6 parameters to the async `searchBusinesses(byTerm:...)` and forward them to the callback overload.

No new model types, router changes, or test changes are needed.

---

### 2. Phone Search — ⚠️ Implemented (schema gaps)

**API reference:** https://docs.developer.yelp.com/reference/v3_business_phone_search  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/search/phone`  
**Swift method:** `CDYelpAPIClient.searchBusinesses(byPhoneNumber:completion:)`  
**Response type:** `CDYelpSearchResponse.Phone`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `phone` | string | Yes | ✅ | Must start with `+` and include country code |
| `locale` | string | No | ❌ | API accepts locale but it is not sent |

#### Schema gaps — fix instructions

**Step 1 — `Source/Parameters+CDYelpFusionKit.swift`**

Extend `phoneParameters(withPhoneNumber:)` to accept and forward `locale`:

```swift
static func phoneParameters(withPhoneNumber phoneNumber: String!,
                             locale: CDYelpLocale?) -> Parameters {
    var parameters: Parameters = [:]
    parameters["phone"] = phoneNumber
    if let locale = locale, locale.rawValue != "" {
        parameters["locale"] = locale.rawValue
    }
    return parameters
}
```

**Step 2 — `Source/CDYelpAPIClient.swift` (callback overload)**

Add `locale: CDYelpLocale?` parameter to `searchBusinesses(byPhoneNumber:completion:)` and pass it to `phoneParameters(withPhoneNumber:locale:)`.

**Step 3 — `Source/CDYelpAPIClient.swift` (async overload)**

Add `locale: CDYelpLocale?` to `searchBusinesses(byPhoneNumber:)` async overload and forward it.

---

### 3. Business Match — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_business_match  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/matches`  
**Swift method:** `CDYelpAPIClient.searchBusinesses(name:addressOne:addressTwo:addressThree:city:state:country:latitude:longitude:phone:zipCode:yelpBusinessId:limit:matchThresholdType:completion:)`  
**Response type:** `CDYelpSearchResponse.BusinessMatch`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `name` | string | Yes | ✅ | Max 64 chars; asserted |
| `address1` | string | Yes | ✅ | Max 64 chars; asserted |
| `address2` | string | No | ✅ | |
| `address3` | string | No | ✅ | |
| `city` | string | Yes | ✅ | Max 64 chars; asserted |
| `state` | string | Yes | ✅ | ISO 3166-2; max 3 chars; asserted |
| `country` | string | Yes | ✅ | ISO 3166-1 alpha-2; max 2 chars; asserted |
| `postal_code` | string | No | ✅ | |
| `latitude` | number | No | ✅ | –90 to +90; asserted |
| `longitude` | number | No | ✅ | –180 to +180; asserted |
| `phone` | string | No | ✅ | Max 32 chars; asserted |
| `yelp_business_id` | string | No | ✅ | |
| `limit` | integer | No | ✅ | 1–10; asserted |
| `match_threshold` | string | No | ✅ | `CDYelpBusinessMatchThresholdType` raw value |

Schema is correct. No changes needed.

---

### 4. Business Details — ⚠️ Implemented (schema gaps)

**API reference:** https://docs.developer.yelp.com/reference/v3_business_info  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/{business_id_or_alias}`  
**Swift method:** `CDYelpAPIClient.fetchBusiness(forId:locale:completion:)`  
**Response type:** `CDYelpBusinessResponse` (wraps `CDYelpBusiness.Detailed`)

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `business_id_or_alias` | string | Yes | ✅ | Path parameter; asserted non-empty |
| `locale` | string | No | ✅ | |
| `device_platform` | string | No | ❌ | Missing; values: `android`, `ios`, `mobile-generic` |

#### Schema gaps — fix instructions

**Step 1 — `Source/Parameters+CDYelpFusionKit.swift`**

Extend `businessParameters(withLocale:)` to accept `devicePlatform`:

```swift
static func businessParameters(withLocale locale: CDYelpLocale?,
                                devicePlatform: String?) -> Parameters {
    var parameters: Parameters = [:]
    if let locale = locale, locale.rawValue != "" {
        parameters["locale"] = locale.rawValue
    }
    if let devicePlatform = devicePlatform {
        parameters["device_platform"] = devicePlatform
    }
    return parameters
}
```

**Step 2 — `Source/CDYelpAPIClient.swift`**

Add `devicePlatform: String? = nil` to `fetchBusiness(forId:locale:completion:)` and `fetchBusiness(forId:locale:)` (async), passing it through to `businessParameters(withLocale:devicePlatform:)`.

---

### 5. Food Delivery Search — ⚠️ Implemented (schema gaps)

**API reference:** https://docs.developer.yelp.com/reference/v3_transaction_search  
**HTTP method:** `GET`  
**Path:** `/v3/transactions/{transaction_type}/search`  
**Swift method:** `CDYelpAPIClient.searchTransactions(byType:location:latitude:longitude:completion:)`  
**Response type:** `CDYelpSearchResponse.Transaction`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `transaction_type` | string | Yes | ✅ | Path param; `CDYelpTransactionType` raw value |
| `latitude` | number | Conditional | ✅ | |
| `longitude` | number | Conditional | ✅ | |
| `location` | string | Conditional | ✅ | |
| `term` | string | No | ❌ | Missing; business name or cuisine type filter |
| `categories` | array | No | ❌ | Missing; comma-joined category aliases |
| `price` | array | No | ❌ | Missing; price tier filter (1–4) |

#### Schema gaps — fix instructions

**Step 1 — `Source/Parameters+CDYelpFusionKit.swift`**

Extend `transactionsParameters(...)`:

```swift
static func transactionsParameters(withLocation location: String?,
                                    latitude: Double?,
                                    longitude: Double?,
                                    term: String?,
                                    categories: [CDYelpCategoryAlias]?,
                                    priceTiers: [CDYelpPriceTier]?) -> Parameters {
    var parameters: Parameters = [:]
    if let location = location, location != "" {
        parameters["location"] = location
    }
    if let latitude = latitude { parameters["latitude"] = latitude }
    if let longitude = longitude { parameters["longitude"] = longitude }
    if let term = term, term != "" { parameters["term"] = term }
    if let categories = categories, !categories.isEmpty {
        parameters["categories"] = categories.map { $0.rawValue }.joined(separator: ",")
    }
    if let priceTiers = priceTiers, !priceTiers.isEmpty {
        parameters["price"] = priceTiers.map { $0.rawValue }.joined(separator: ",")
    }
    return parameters
}
```

**Step 2 — `Source/CDYelpAPIClient.swift`**

Add `term: String? = nil`, `categories: [CDYelpCategoryAlias]? = nil`, `priceTiers: [CDYelpPriceTier]? = nil` to both overloads of `searchTransactions(byType:...)` and forward them to `transactionsParameters(...)`.

---

### 6. Yelp AI Chat — ❌ Not Implemented

**API reference:** https://docs.developer.yelp.com/reference/v2_ai_chat  
**HTTP method:** `POST`  
**Path:** `/ai/chat/v2`  
**Base URL:** `https://api.yelp.com` (same as other endpoints)

#### Request body (JSON)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `query` | string | Yes | Natural language query; max 1000 characters |
| `chat_id` | string | No | Conversation ID for multi-turn chat; omit or `null` to start a new conversation |
| `user_context` | object | No | `{ "latitude": Double, "longitude": Double }` |
| `request_context` | object | No | Controls response format and content generation behavior |

#### Implementation plan

This endpoint uses POST with a JSON body, which differs from the existing GET + query-string pattern in CDYelpRouter. Follow the steps below exactly.

**Step 1 — Create `Source/CDYelpAIChatRequest.swift`**

```swift
public struct CDYelpAIChatRequest: Encodable, Sendable {
    public let query: String
    public let chatId: String?
    public let userContext: UserContext?
    public let requestContext: [String: String]?

    public struct UserContext: Encodable, Sendable {
        public let latitude: Double
        public let longitude: Double
    }

    enum CodingKeys: String, CodingKey {
        case query
        case chatId = "chat_id"
        case userContext = "user_context"
        case requestContext = "request_context"
    }

    public init(query: String,
                chatId: String? = nil,
                userContext: UserContext? = nil,
                requestContext: [String: String]? = nil) {
        self.query = query
        self.chatId = chatId
        self.userContext = userContext
        self.requestContext = requestContext
    }
}
```

**Step 2 — Create `Source/CDYelpAIChatResponse.swift`**

The Yelp docs do not publish the full response schema. Model the known outer envelope and leave an extension point for future fields:

```swift
public struct CDYelpAIChatResponse: Decodable, Sendable {
    public let chatId: String?
    public let response: String?
    public let businesses: [CDYelpBusiness.BusinessSearch]?
    public let error: CDYelpError?

    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case response
        case businesses
        case error
    }
}
```

**Step 3 — `Source/CDYelpRouter.swift`**

Add a new case for the AI chat endpoint. Because this is a POST with a JSON body, it needs its own `asURLRequest()` branch:

```swift
// Add to the enum:
case aiChat(request: CDYelpAIChatRequest)

// Add to var method:
case .aiChat:
    return .post

// Add to var path:
case .aiChat:
    return "ai/chat/v2"

// In asURLRequest(), add a new branch before the existing switch:
case let .aiChat(request):
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    urlRequest.httpMethod = method.rawValue
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.httpBody = try JSONEncoder().encode(request)
    return urlRequest
```

Note: The existing `asURLRequest()` uses a single `switch` that applies `URLEncoding.default` to all cases. Extract the AI chat case **before** that switch using a guard or early return so it does not reach the URL-encoding branch.

**Step 4 — `Source/CDYelpAPIClient.swift`**

Add callback and async overloads:

```swift
// Callback overload
public func fetchAIChat(query: String,
                        chatId: String? = nil,
                        latitude: Double? = nil,
                        longitude: Double? = nil,
                        completion: @escaping (CDYelpAIChatResponse?) -> Void) {
    precondition(!query.isEmpty, "A query is required.")
    precondition(query.count <= 1000, "Query must be 1000 characters or fewer.")

    guard isAuthenticated() else { return }

    let userContext: CDYelpAIChatRequest.UserContext? = (latitude != nil && longitude != nil)
        ? .init(latitude: latitude!, longitude: longitude!)
        : nil
    let request = CDYelpAIChatRequest(query: query, chatId: chatId, userContext: userContext)

    manager
        .request(CDYelpRouter.aiChat(request: request))
        .validate()
        .responseDecodable { (response: DataResponse<CDYelpAIChatResponse, AFError>) in
            switch response.result {
            case let .success(chatResponse): completion(chatResponse)
            case .failure: completion(nil)
            }
        }
}

// Async overload (iOS 13+)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func fetchAIChat(query: String,
                        chatId: String? = nil,
                        latitude: Double? = nil,
                        longitude: Double? = nil) async throws -> CDYelpAIChatResponse {
    try await withCheckedThrowingContinuation { continuation in
        fetchAIChat(query: query, chatId: chatId, latitude: latitude, longitude: longitude) { response in
            guard let response = response else {
                continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                return
            }
            continuation.resume(returning: response)
        }
    }
}
```

---

### 7. Engagement Metrics — 🔒 Not Implemented (special permissions)

**API reference:** https://docs.developer.yelp.com/reference/v3_get_businesses_engagement  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/engagement`  
**Access:** Requires special permissions enabled on your Yelp Places API key.

#### Request parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `business_ids` | array of strings | Yes | Business IDs or aliases; max 20 items |
| `date_range_start` | date | No | Start of date range; defaults to start of most recent available week |
| `date_range_end` | date | No | End of date range; defaults to end of most recent available week |

#### Implementation plan

This endpoint is gated behind special permissions. Implementation is identical in structure to the other endpoints but requires the caller to have the appropriate API key scope.

**Step 1 — Create `Source/CDYelpEngagementResponse.swift`**

The Yelp docs do not publish the full response schema. Use a flexible placeholder:

```swift
public struct CDYelpEngagementResponse: Decodable, Sendable {
    public let data: [CDYelpEngagementData]?
    public let error: CDYelpError?
}

public struct CDYelpEngagementData: Decodable, Sendable {
    public let businessId: String?
    public let metrics: [String: Double]?

    enum CodingKeys: String, CodingKey {
        case businessId = "business_id"
        case metrics
    }
}
```

**Step 2 — `Source/CDYelpRouter.swift`**

```swift
case engagement(parameters: Parameters)

// method: .get
// path: "businesses/engagement"
// encoding: URLEncoding.default (same as all other GET cases)
```

**Step 3 — `Source/Parameters+CDYelpFusionKit.swift`**

```swift
static func engagementParameters(withBusinessIds businessIds: [String],
                                   dateRangeStart: String?,
                                   dateRangeEnd: String?) -> Parameters {
    var parameters: Parameters = [:]
    parameters["business_ids"] = businessIds.joined(separator: ",")
    if let start = dateRangeStart { parameters["date_range_start"] = start }
    if let end = dateRangeEnd { parameters["date_range_end"] = end }
    return parameters
}
```

**Step 4 — `Source/CDYelpAPIClient.swift`**

```swift
public func fetchEngagementMetrics(forBusinessIds businessIds: [String],
                                    dateRangeStart: String? = nil,
                                    dateRangeEnd: String? = nil,
                                    completion: @escaping (CDYelpEngagementResponse?) -> Void) {
    precondition(!businessIds.isEmpty && businessIds.count <= 20,
                 "Between 1 and 20 business IDs are required.")
    guard isAuthenticated() else { return }

    let parameters = Parameters.engagementParameters(
        withBusinessIds: businessIds,
        dateRangeStart: dateRangeStart,
        dateRangeEnd: dateRangeEnd
    )
    manager
        .request(CDYelpRouter.engagement(parameters: parameters))
        .validate()
        .responseDecodable { (response: DataResponse<CDYelpEngagementResponse, AFError>) in
            switch response.result {
            case let .success(r): completion(r)
            case .failure: completion(nil)
            }
        }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func fetchEngagementMetrics(forBusinessIds businessIds: [String],
                                    dateRangeStart: String? = nil,
                                    dateRangeEnd: String? = nil) async throws -> CDYelpEngagementResponse {
    try await withCheckedThrowingContinuation { continuation in
        fetchEngagementMetrics(forBusinessIds: businessIds,
                               dateRangeStart: dateRangeStart,
                               dateRangeEnd: dateRangeEnd) { response in
            guard let response = response else {
                continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                return
            }
            continuation.resume(returning: response)
        }
    }
}
```

---

### 8. Service Offerings — 🔒 Not Implemented (special permissions)

**API reference:** https://docs.developer.yelp.com/reference/v3_business_service_offerings  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/{business_id_or_alias}/service_offerings`  
**Access:** Requires special permissions enabled on your Yelp Places API key.

#### Request parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `business_id_or_alias` | string | Yes | Path parameter |
| `locale` | string | No | Locale code |

#### Implementation plan

**Step 1 — Create `Source/CDYelpServiceOfferingsResponse.swift`**

```swift
public struct CDYelpServiceOfferingsResponse: Decodable, Sendable {
    public let serviceOfferings: [CDYelpServiceOffering]?
    public let error: CDYelpError?

    enum CodingKeys: String, CodingKey {
        case serviceOfferings = "service_offerings"
        case error
    }
}

public struct CDYelpServiceOffering: Decodable, Sendable {
    public let id: String?
    public let name: String?
    public let description: String?
    public let url: String?
}
```

**Step 2 — `Source/CDYelpRouter.swift`**

```swift
case serviceOfferings(id: String, parameters: Parameters)

// method: .get
// path: "businesses/\(id)/service_offerings"
// encoding: URLEncoding.default
```

**Step 3 — `Source/CDYelpAPIClient.swift`**

```swift
public func fetchServiceOfferings(forBusinessId id: String,
                                   locale: CDYelpLocale? = nil,
                                   completion: @escaping (CDYelpServiceOfferingsResponse?) -> Void) {
    precondition(!id.isEmpty, "A business ID is required.")
    guard isAuthenticated() else { return }

    let parameters = Parameters.businessParameters(withLocale: locale)
    manager
        .request(CDYelpRouter.serviceOfferings(id: id, parameters: parameters))
        .validate()
        .responseDecodable { (response: DataResponse<CDYelpServiceOfferingsResponse, AFError>) in
            switch response.result {
            case let .success(r): completion(r)
            case .failure: completion(nil)
            }
        }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func fetchServiceOfferings(forBusinessId id: String,
                                   locale: CDYelpLocale? = nil) async throws -> CDYelpServiceOfferingsResponse {
    try await withCheckedThrowingContinuation { continuation in
        fetchServiceOfferings(forBusinessId: id, locale: locale) { response in
            guard let response = response else {
                continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                return
            }
            continuation.resume(returning: response)
        }
    }
}
```

---

### 9. Business Insights — 🔒 Not Implemented (special permissions)

**API reference:** https://docs.developer.yelp.com/reference/v3_businesses_insights  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/insights`  
**Access:** Requires Yelp Insights API access on your API key.

#### Request parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `business_ids` | array of strings | Yes | Business IDs or aliases; max 20 |
| `date_range_start` | string | Yes | Format: `YYYYMM` |
| `date_range_end` | string | Yes | Format: `YYYYMM` |

#### Implementation plan

**Step 1 — Create `Source/CDYelpBusinessInsightsResponse.swift`**

```swift
public struct CDYelpBusinessInsightsResponse: Decodable, Sendable {
    public let insights: [CDYelpBusinessInsight]?
    public let error: CDYelpError?
}

public struct CDYelpBusinessInsight: Decodable, Sendable {
    public let businessId: String?
    public let metrics: [String: Double]?

    enum CodingKeys: String, CodingKey {
        case businessId = "business_id"
        case metrics
    }
}
```

**Step 2 — `Source/CDYelpRouter.swift`**

```swift
case businessInsights(parameters: Parameters)

// method: .get
// path: "businesses/insights"
// encoding: URLEncoding.default
```

**Step 3 — `Source/Parameters+CDYelpFusionKit.swift`**

```swift
static func businessInsightsParameters(withBusinessIds businessIds: [String],
                                        dateRangeStart: String,
                                        dateRangeEnd: String) -> Parameters {
    var parameters: Parameters = [:]
    parameters["business_ids"] = businessIds.joined(separator: ",")
    parameters["date_range_start"] = dateRangeStart
    parameters["date_range_end"] = dateRangeEnd
    return parameters
}
```

**Step 4 — `Source/CDYelpAPIClient.swift`**

```swift
public func fetchBusinessInsights(forBusinessIds businessIds: [String],
                                   dateRangeStart: String,
                                   dateRangeEnd: String,
                                   completion: @escaping (CDYelpBusinessInsightsResponse?) -> Void) {
    precondition(!businessIds.isEmpty && businessIds.count <= 20,
                 "Between 1 and 20 business IDs are required.")
    precondition(!dateRangeStart.isEmpty && !dateRangeEnd.isEmpty,
                 "dateRangeStart and dateRangeEnd are required (format: YYYYMM).")
    guard isAuthenticated() else { return }

    let parameters = Parameters.businessInsightsParameters(
        withBusinessIds: businessIds,
        dateRangeStart: dateRangeStart,
        dateRangeEnd: dateRangeEnd
    )
    manager
        .request(CDYelpRouter.businessInsights(parameters: parameters))
        .validate()
        .responseDecodable { (response: DataResponse<CDYelpBusinessInsightsResponse, AFError>) in
            switch response.result {
            case let .success(r): completion(r)
            case .failure: completion(nil)
            }
        }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func fetchBusinessInsights(forBusinessIds businessIds: [String],
                                   dateRangeStart: String,
                                   dateRangeEnd: String) async throws -> CDYelpBusinessInsightsResponse {
    try await withCheckedThrowingContinuation { continuation in
        fetchBusinessInsights(forBusinessIds: businessIds,
                              dateRangeStart: dateRangeStart,
                              dateRangeEnd: dateRangeEnd) { response in
            guard let response = response else {
                continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                return
            }
            continuation.resume(returning: response)
        }
    }
}
```

---

## Reviews

---

### 10. Reviews — ⚠️ Implemented (schema gaps)

**API reference:** https://docs.developer.yelp.com/reference/v3_business_reviews  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/{business_id_or_alias}/reviews`  
**Swift method:** `CDYelpAPIClient.fetchReviews(forBusinessId:locale:completion:)`  
**Response type:** `CDYelpReviewsResponse`  
**Access:** Requires Enhanced Plan or Premium Plan.

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `business_id_or_alias` | string | Yes | ✅ | Path parameter |
| `locale` | string | No | ✅ | |
| `offset` | integer | No | ❌ | Missing; 0–1000 |
| `limit` | integer | No | ❌ | Missing; 0–50; defaults to 20 |
| `sort_by` | string | No | ❌ | Missing; defaults to `yelp_sort` |

#### Schema gaps — fix instructions

**Step 1 — `Source/Parameters+CDYelpFusionKit.swift`**

Extend `reviewsParameters(withLocale:)`:

```swift
static func reviewsParameters(withLocale locale: CDYelpLocale?,
                               offset: Int?,
                               limit: Int?,
                               sortBy: String?) -> Parameters {
    var parameters: Parameters = [:]
    if let locale = locale, locale.rawValue != "" {
        parameters["locale"] = locale.rawValue
    }
    if let offset = offset { parameters["offset"] = offset }
    if let limit = limit { parameters["limit"] = limit }
    if let sortBy = sortBy, !sortBy.isEmpty { parameters["sort_by"] = sortBy }
    return parameters
}
```

**Step 2 — `Source/CDYelpAPIClient.swift`**

Add `offset: Int? = nil`, `limit: Int? = nil`, `sortBy: String? = nil` to both overloads of `fetchReviews(forBusinessId:locale:...)` and forward them to `reviewsParameters(...)`. Add a `limit` assertion: `assert(limit == nil || (limit! >= 0 && limit! <= 50), "limit must be 0–50")`.

---

### 11. Review Highlights — 🔒 Not Implemented (Premium Plan)

**API reference:** https://docs.developer.yelp.com/reference/v3_business_review_highlights  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/{business_id_or_alias}/review_highlights`  
**Access:** Requires Premium Plan permission on the Yelp Fusion Places API.

#### Request parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `business_id_or_alias` | string | Yes | Path parameter |
| `count` | integer | No | Highlights to return; default 3, max 5 |
| `locale` | string | No | Locale code |
| `device_platform` | string | No | `android`, `ios`, `mobile-generic` |

#### Implementation plan

**Step 1 — Create `Source/CDYelpReviewHighlightsResponse.swift`**

```swift
public struct CDYelpReviewHighlightsResponse: Decodable, Sendable {
    public let highlights: [CDYelpReviewHighlight]?
    public let error: CDYelpError?
}

public struct CDYelpReviewHighlight: Decodable, Sendable {
    public let text: String?
    public let rating: Double?
    public let feedbackCount: Int?
    public let language: String?

    enum CodingKeys: String, CodingKey {
        case text
        case rating
        case feedbackCount = "feedback_count"
        case language
    }
}
```

**Step 2 — `Source/CDYelpRouter.swift`**

```swift
case reviewHighlights(id: String, parameters: Parameters)

// method: .get
// path: "businesses/\(id)/review_highlights"
// encoding: URLEncoding.default
```

**Step 3 — `Source/Parameters+CDYelpFusionKit.swift`**

```swift
static func reviewHighlightsParameters(count: Int?,
                                        locale: CDYelpLocale?,
                                        devicePlatform: String?) -> Parameters {
    var parameters: Parameters = [:]
    if let count = count { parameters["count"] = count }
    if let locale = locale, locale.rawValue != "" { parameters["locale"] = locale.rawValue }
    if let devicePlatform = devicePlatform { parameters["device_platform"] = devicePlatform }
    return parameters
}
```

**Step 4 — `Source/CDYelpAPIClient.swift`**

```swift
public func fetchReviewHighlights(forBusinessId id: String,
                                   count: Int? = nil,
                                   locale: CDYelpLocale? = nil,
                                   devicePlatform: String? = nil,
                                   completion: @escaping (CDYelpReviewHighlightsResponse?) -> Void) {
    precondition(!id.isEmpty, "A business ID is required.")
    if let count = count {
        precondition(count >= 1 && count <= 5, "count must be between 1 and 5.")
    }
    guard isAuthenticated() else { return }

    let parameters = Parameters.reviewHighlightsParameters(
        count: count,
        locale: locale,
        devicePlatform: devicePlatform
    )
    manager
        .request(CDYelpRouter.reviewHighlights(id: id, parameters: parameters))
        .validate()
        .responseDecodable { (response: DataResponse<CDYelpReviewHighlightsResponse, AFError>) in
            switch response.result {
            case let .success(r): completion(r)
            case .failure: completion(nil)
            }
        }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func fetchReviewHighlights(forBusinessId id: String,
                                   count: Int? = nil,
                                   locale: CDYelpLocale? = nil,
                                   devicePlatform: String? = nil) async throws -> CDYelpReviewHighlightsResponse {
    try await withCheckedThrowingContinuation { continuation in
        fetchReviewHighlights(forBusinessId: id, count: count, locale: locale, devicePlatform: devicePlatform) { response in
            guard let response = response else {
                continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                return
            }
            continuation.resume(returning: response)
        }
    }
}
```

---

## Events

---

### 12. Event Search — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_events_search  
**HTTP method:** `GET`  
**Path:** `/v3/events`  
**Swift method:** `CDYelpAPIClient.searchEvents(byLocale:offset:limit:sortBy:sortOn:startDate:endDate:categories:isFree:location:latitude:longitude:radius:excludedEvents:completion:)`  
**Response type:** `CDYelpEventsResponse`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `locale` | string | No | ✅ | |
| `offset` | integer | No | ✅ | 0–1000 |
| `limit` | integer | No | ✅ | 0–50; asserted |
| `sort_by` | string | No | ✅ | `CDYelpEventSortByType` raw value |
| `sort_on` | string | No | ✅ | `CDYelpEventSortOnType` raw value |
| `start_date` | integer | No | ✅ | Unix timestamp from `Date` |
| `end_date` | integer | No | ✅ | Unix timestamp from `Date` |
| `categories` | array | No | ✅ | `CDYelpEventCategoryFilter` raw values |
| `is_free` | boolean | No | ✅ | |
| `location` | string | Conditional | ✅ | |
| `latitude` | number | Conditional | ✅ | |
| `longitude` | number | Conditional | ✅ | |
| `radius` | integer | No | ✅ | Max 40,000 m; asserted |
| `excluded_events` | array | No | ✅ | |

Schema is correct. No changes needed.

---

### 13. Event Details — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_event  
**HTTP method:** `GET`  
**Path:** `/v3/events/{event_id}`  
**Swift method:** `CDYelpAPIClient.fetchEvent(forId:locale:completion:)`  
**Response type:** `CDYelpEventResponse`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `event_id` | string | Yes | ✅ | Path parameter; asserted non-empty |
| `locale` | string | No | ✅ | |

Schema is correct. No changes needed.

---

### 14. Featured Event — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_featured_event  
**HTTP method:** `GET`  
**Path:** `/v3/events/featured`  
**Swift method:** `CDYelpAPIClient.fetchFeaturedEvent(forLocale:location:latitude:longitude:completion:)`  
**Response type:** `CDYelpEventResponse`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `location` | string | Conditional | ✅ | |
| `latitude` | number | Conditional | ✅ | |
| `longitude` | number | Conditional | ✅ | |
| `locale` | string | No | ✅ | |

Schema is correct. No changes needed.

---

## Categories

---

### 15. All Categories — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_all_categories  
**HTTP method:** `GET`  
**Path:** `/v3/categories`  
**Swift method:** `CDYelpAPIClient.fetchCategories(forLocale:completion:)`  
**Response type:** `CDYelpCategoriesResponse`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `locale` | string | No | ✅ | Filters categories to those available in the locale and translates names |

Schema is correct. No changes needed.

---

### 16. Category Details — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_categories  
**HTTP method:** `GET`  
**Path:** `/v3/categories/{alias}`  
**Swift method:** `CDYelpAPIClient.fetchCategory(forAlias:andLocale:completion:)`  
**Response type:** `CDYelpCategoryResponse`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `alias` | string | Yes | ✅ | Path parameter; `CDYelpCategoryAlias` raw value |
| `locale` | string | No | ✅ | |

Schema is correct. No changes needed.

---

## Home Services

---

### 17. Home Services — ❌ Not Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_get_jobs  
**HTTP method:** `POST`  
**Path:** `/v3/jobs`

#### Request body (JSON)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `query` | string | Yes | Natural language description of the home service need; max 1000 characters |
| `locale` | string | No | Locale code; defaults to `en_US` |

#### Implementation plan

This is a POST with a JSON body, same pattern as Yelp AI Chat (§6).

**Step 1 — Create `Source/CDYelpJobsResponse.swift`**

```swift
public struct CDYelpJobsResponse: Decodable, Sendable {
    public let jobs: [CDYelpJob]?
    public let error: CDYelpError?
}

public struct CDYelpJob: Decodable, Sendable {
    public let id: String?
    public let name: String?
    public let alias: String?
    public let description: String?
}
```

**Step 2 — `Source/CDYelpRouter.swift`**

Add a POST + JSON body case (same pattern as `aiChat`):

```swift
case jobs(query: String, locale: String?)

// method: .post
// path: "jobs"

// In asURLRequest(), handle before the URL-encoding switch:
case let .jobs(query, locale):
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    urlRequest.httpMethod = method.rawValue
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    var body: [String: String] = ["query": query]
    if let locale = locale { body["locale"] = locale }
    urlRequest.httpBody = try JSONEncoder().encode(body)
    return urlRequest
```

**Step 3 — `Source/CDYelpAPIClient.swift`**

```swift
public func fetchJobs(forQuery query: String,
                      locale: CDYelpLocale? = nil,
                      completion: @escaping (CDYelpJobsResponse?) -> Void) {
    precondition(!query.isEmpty && query.count <= 1000,
                 "A query of 1–1000 characters is required.")
    guard isAuthenticated() else { return }

    manager
        .request(CDYelpRouter.jobs(query: query, locale: locale?.rawValue))
        .validate()
        .responseDecodable { (response: DataResponse<CDYelpJobsResponse, AFError>) in
            switch response.result {
            case let .success(r): completion(r)
            case .failure: completion(nil)
            }
        }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func fetchJobs(forQuery query: String,
                      locale: CDYelpLocale? = nil) async throws -> CDYelpJobsResponse {
    try await withCheckedThrowingContinuation { continuation in
        fetchJobs(forQuery: query, locale: locale) { response in
            guard let response = response else {
                continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                return
            }
            continuation.resume(returning: response)
        }
    }
}
```

---

## Autocomplete

---

### 18. Autocomplete — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_autocomplete  
**HTTP method:** `GET`  
**Path:** `/v3/autocomplete`  
**Swift method:** `CDYelpAPIClient.autocompleteBusinesses(byText:latitude:longitude:locale:completion:)`  
**Response type:** `CDYelpAutoCompleteResponse`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `text` | string | Yes | ✅ | Asserted non-empty |
| `latitude` | number | Conditional | ✅ | Asserted present together with longitude |
| `longitude` | number | Conditional | ✅ | |
| `locale` | string | No | ✅ | |

Schema is correct. No changes needed.

---

## OAuth

---

### 19. OAuth Authorization — ❌ Not Applicable

**API reference:** https://docs.developer.yelp.com/reference/oauth2_token  
**HTTP method:** `POST`  
**Path:** `/oauth2/token`

This endpoint is used to exchange an authorization code for an OAuth 2.0 access token for business owner authorization flows (e.g., the Leads API). CDYelpFusionKit authenticates via a static API key (Bearer token) set at initialization time and does not participate in the OAuth authorization code flow. No implementation is planned unless the Leads API (§21) or another OAuth-gated endpoint is added.

If OAuth support is added in the future, it would live outside `CDYelpAPIClient` (it does not require an API key; it uses `client_id` + `client_secret`) and would need a separate client or utility class.

---

## Data Ingestion

---

### 20. Data Ingestion — 🔒 Not Implemented (partner only)

**API reference:** https://docs.developer.yelp.com/reference/create_business_update_v1  
**HTTP method:** `POST`  
**Base URL:** `https://partner-api.yelp.com` (different from the standard `https://api.yelp.com`)  
**Path:** `/v1/ingest/create`  
**Authentication:** HTTP Basic auth (base64-encoded `client_id:client_secret`)  
**Access:** Contract-dependent partner API. Available businesses and updatable fields are determined by the partner agreement.

#### Request body (JSON — top level)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `matching_criteria` | object | Yes | Address, name, country, city, state, postal_code (required); phone, lat/lng, yelp_business_id (optional) |
| `options` | object | No | Flags such as `create_if_missing` |
| `update` | object | No | 50+ updatable fields (hours, phone, url, categories, parking, etc.) |
| `partner_business_id` | string | No | Partner's own identifier; max 100 chars |

Because this endpoint uses a different base URL, different authentication scheme, and a contract-dependent field set, it is not a suitable target for inclusion in the standard `CDYelpAPIClient`. It would require a separate `CDYelpPartnerAPIClient` class. Implementation is deferred until partner access is confirmed.

---

## Leads

---

### 21. Leads — 🔒 Not Implemented (OAuth + advertising required)

**API reference:** https://docs.developer.yelp.com/reference/get-lead  
**HTTP method:** `GET`  
**Path:** `/v3/leads/{ID}`  
**Access:** Requires OAuth 2.0 access token (not API key) and the business must be actively advertising on Yelp.

#### Request parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ID` | string | Yes | Path parameter; the Yelp Lead ID |

#### Implementation plan

This endpoint requires OAuth (see §19). Before implementing, OAuth token support must be added to the framework. Once OAuth is available:

**Step 1 — Create `Source/CDYelpLeadResponse.swift`**

```swift
public struct CDYelpLeadResponse: Decodable, Sendable {
    public let id: String?
    public let businessId: String?
    public let createdAt: String?
    public let status: String?
    public let details: [String: String]?
    public let error: CDYelpError?

    enum CodingKeys: String, CodingKey {
        case id
        case businessId = "business_id"
        case createdAt = "created_at"
        case status
        case details
        case error
    }
}
```

**Step 2 — `Source/CDYelpRouter.swift`**

```swift
case lead(id: String)

// method: .get
// path: "leads/\(id)"
// no query parameters
```

**Step 3 — `Source/CDYelpAPIClient.swift`**

The existing client must carry an OAuth access token (not just the API key) for this call. Add a second initializer or a separate method to pass the token:

```swift
public func fetchLead(forId id: String,
                      completion: @escaping (CDYelpLeadResponse?) -> Void) {
    precondition(!id.isEmpty, "A lead ID is required.")
    guard isAuthenticated() else { return }

    manager
        .request(CDYelpRouter.lead(id: id))
        .validate()
        .responseDecodable { (response: DataResponse<CDYelpLeadResponse, AFError>) in
            switch response.result {
            case let .success(r): completion(r)
            case .failure: completion(nil)
            }
        }
}
```

---

## Webhooks

---

### 22. Webhooks (deprecated) — ❌ Not Implemented

**API reference:** https://docs.developer.yelp.com/reference/add_businesses_to_allow_list  
**Status:** **Deprecated** — Yelp documentation instructs developers to migrate to the Business Subscriptions API.  
**HTTP method:** `POST`  
**Path:** `/v3/webhooks/whitelists/businesses/add`

#### Request body (JSON)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `business_ids` | array of strings | Yes | 1–100 Yelp Business IDs |

#### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `whitelist_business_ids_count` | integer | Number of businesses in the allow list after addition |

#### Implementation plan

Because this endpoint is deprecated, implementation is not recommended. If the Business Subscriptions API reference becomes public, a replacement implementation plan should be authored at that time.

If implementation of the deprecated endpoint is required for compatibility, follow this pattern:

**Step 1 — Create `Source/CDYelpWebhookAllowListResponse.swift`**

```swift
public struct CDYelpWebhookAllowListResponse: Decodable, Sendable {
    public let whitelistBusinessIdsCount: Int?
    public let error: CDYelpError?

    enum CodingKeys: String, CodingKey {
        case whitelistBusinessIdsCount = "whitelist_business_ids_count"
        case error
    }
}
```

**Step 2 — `Source/CDYelpRouter.swift`**

Add a POST + JSON body case:

```swift
case addToWebhookAllowList(businessIds: [String])

// method: .post
// path: "webhooks/whitelists/businesses/add"

// In asURLRequest(), before the URL-encoding switch:
case let .addToWebhookAllowList(businessIds):
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    urlRequest.httpMethod = method.rawValue
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let body = ["business_ids": businessIds]
    urlRequest.httpBody = try JSONEncoder().encode(body)
    return urlRequest
```

**Step 3 — `Source/CDYelpAPIClient.swift`**

```swift
public func addBusinessesToWebhookAllowList(_ businessIds: [String],
                                             completion: @escaping (CDYelpWebhookAllowListResponse?) -> Void) {
    precondition(!businessIds.isEmpty && businessIds.count <= 100,
                 "Between 1 and 100 business IDs are required.")
    guard isAuthenticated() else { return }

    manager
        .request(CDYelpRouter.addToWebhookAllowList(businessIds: businessIds))
        .validate()
        .responseDecodable { (response: DataResponse<CDYelpWebhookAllowListResponse, AFError>) in
            switch response.result {
            case let .success(r): completion(r)
            case .failure: completion(nil)
            }
        }
}
```

---

## Reservations

---

### 23. Reservations — ❌ Not Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_openings  
**HTTP method:** `GET`  
**Path:** `/v3/bookings/{business_id_or_alias}/openings`

#### Request parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `business_id_or_alias` | string | Yes | Path parameter |
| `covers` | integer | Yes | Party size; 1–10 |
| `date` | string | Yes | Reservation date; format `YYYY-MM-DD` |
| `time` | string | Yes | Requested time; format `HH:MM` |
| `get_covers_range` | boolean | No | Include min/max party size range in response |

#### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `reservation_times` | array | Collection of dates with available time slots |
| `reservation_times[].date` | string | Date; format `YYYY-MM-DD` |
| `reservation_times[].times` | array | Available time slots for that date |
| `reservation_times[].times[].time` | string | Time slot; format `HH:MM` |
| `reservation_times[].times[].credit_card_required` | boolean | Whether a credit card is required to hold the reservation |
| `covers_range.min_party_size` | integer | Minimum party size the restaurant accepts (only present if `get_covers_range=true`) |
| `covers_range.max_party_size` | integer | Maximum party size (only present if `get_covers_range=true`) |

**Note:** The API returns times across 4 days — the day before, the requested day, and 2 days after.

#### Implementation plan

**Step 1 — Create `Source/CDYelpOpeningsResponse.swift`**

```swift
public struct CDYelpOpeningsResponse: Decodable, Sendable {
    public let reservationTimes: [CDYelpReservationDay]?
    public let coversRange: CDYelpCoversRange?
    public let error: CDYelpError?

    enum CodingKeys: String, CodingKey {
        case reservationTimes = "reservation_times"
        case coversRange = "covers_range"
        case error
    }
}

public struct CDYelpReservationDay: Decodable, Sendable {
    public let date: String?
    public let times: [CDYelpReservationTime]?
}

public struct CDYelpReservationTime: Decodable, Sendable {
    public let time: String?
    public let creditCardRequired: Bool?

    enum CodingKeys: String, CodingKey {
        case time
        case creditCardRequired = "credit_card_required"
    }
}

public struct CDYelpCoversRange: Decodable, Sendable {
    public let minPartySize: Int?
    public let maxPartySize: Int?

    enum CodingKeys: String, CodingKey {
        case minPartySize = "min_party_size"
        case maxPartySize = "max_party_size"
    }
}
```

**Step 2 — `Source/CDYelpRouter.swift`**

```swift
case openings(businessId: String, parameters: Parameters)

// method: .get
// path: "bookings/\(businessId)/openings"
// encoding: URLEncoding.default
```

**Step 3 — `Source/Parameters+CDYelpFusionKit.swift`**

```swift
static func openingsParameters(covers: Int,
                                date: String,
                                time: String,
                                getCoversRange: Bool?) -> Parameters {
    var parameters: Parameters = [:]
    parameters["covers"] = covers
    parameters["date"] = date
    parameters["time"] = time
    if let getCoversRange = getCoversRange {
        parameters["get_covers_range"] = getCoversRange
    }
    return parameters
}
```

**Step 4 — `Source/CDYelpAPIClient.swift`**

```swift
public func fetchOpenings(forBusinessId id: String,
                           covers: Int,
                           date: String,
                           time: String,
                           getCoversRange: Bool? = nil,
                           completion: @escaping (CDYelpOpeningsResponse?) -> Void) {
    precondition(!id.isEmpty, "A business ID is required.")
    precondition(covers >= 1 && covers <= 10, "covers must be between 1 and 10.")
    precondition(!date.isEmpty, "A date is required (format: YYYY-MM-DD).")
    precondition(!time.isEmpty, "A time is required (format: HH:MM).")
    guard isAuthenticated() else { return }

    let parameters = Parameters.openingsParameters(
        covers: covers,
        date: date,
        time: time,
        getCoversRange: getCoversRange
    )
    manager
        .request(CDYelpRouter.openings(businessId: id, parameters: parameters))
        .validate()
        .responseDecodable { (response: DataResponse<CDYelpOpeningsResponse, AFError>) in
            switch response.result {
            case let .success(r): completion(r)
            case .failure: completion(nil)
            }
        }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func fetchOpenings(forBusinessId id: String,
                           covers: Int,
                           date: String,
                           time: String,
                           getCoversRange: Bool? = nil) async throws -> CDYelpOpeningsResponse {
    try await withCheckedThrowingContinuation { continuation in
        fetchOpenings(forBusinessId: id,
                      covers: covers,
                      date: date,
                      time: time,
                      getCoversRange: getCoversRange) { response in
            guard let response = response else {
                continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                return
            }
            continuation.resume(returning: response)
        }
    }
}
```

---

## Summary

| # | Endpoint | Status |
|---|----------|--------|
| 1 | Business Search | ⚠️ Schema gaps (6 missing params) |
| 2 | Phone Search | ⚠️ Schema gaps (missing `locale`) |
| 3 | Business Match | ✅ Correct |
| 4 | Business Details | ⚠️ Schema gaps (missing `device_platform`) |
| 5 | Food Delivery Search | ⚠️ Schema gaps (missing `term`, `categories`, `price`) |
| 6 | Yelp AI Chat | ❌ Not implemented |
| 7 | Engagement Metrics | 🔒 Not implemented (special permissions) |
| 8 | Service Offerings | 🔒 Not implemented (special permissions) |
| 9 | Business Insights | 🔒 Not implemented (special permissions) |
| 10 | Reviews | ⚠️ Schema gaps (missing `offset`, `limit`, `sort_by`) |
| 11 | Review Highlights | 🔒 Not implemented (Premium Plan) |
| 12 | Event Search | ✅ Correct |
| 13 | Event Details | ✅ Correct |
| 14 | Featured Event | ✅ Correct |
| 15 | All Categories | ✅ Correct |
| 16 | Category Details | ✅ Correct |
| 17 | Home Services | ❌ Not implemented |
| 18 | Autocomplete | ✅ Correct |
| 19 | OAuth Authorization | ❌ Not applicable (API key auth only) |
| 20 | Data Ingestion | 🔒 Not implemented (partner contract required) |
| 21 | Leads | 🔒 Not implemented (OAuth + advertising required) |
| 22 | Webhooks | ❌ Not implemented (deprecated) |
| 23 | Reservations | ❌ Not implemented |
