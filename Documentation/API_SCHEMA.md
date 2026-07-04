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
1. [Business Search — ✅ Implemented](#1-business-search--implemented)
2. [Phone Search — ✅ Implemented](#2-phone-search--implemented)
3. [Business Match — ✅ Implemented](#3-business-match--implemented)
4. [Business Details — ✅ Implemented](#4-business-details--implemented)
5. [Food Delivery Search — ✅ Implemented](#5-food-delivery-search--implemented)
6. [Yelp AI Chat — ✅ Implemented](#6-yelp-ai-chat--implemented)
7. [Engagement Metrics — ✅ Implemented](#7-engagement-metrics--implemented)
8. [Service Offerings — ✅ Implemented](#8-service-offerings--implemented)
9. [Business Insights — ✅ Implemented](#9-business-insights--implemented)

### Reviews
10. [Reviews — ✅ Implemented](#10-reviews--implemented)
11. [Review Highlights — ✅ Implemented](#11-review-highlights--implemented)

### Events
12. [Event Search — ✅ Implemented](#12-event-search--implemented)
13. [Event Details — ✅ Implemented](#13-event-details--implemented)
14. [Featured Event — ✅ Implemented](#14-featured-event--implemented)

### Categories
15. [All Categories — ✅ Implemented](#15-all-categories--implemented)
16. [Category Details — ✅ Implemented](#16-category-details--implemented)

### Home Services
17. [Home Services — ✅ Implemented](#17-home-services--implemented)

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
23. [Reservations — ✅ Implemented](#23-reservations--implemented)

---

## Businesses

---

### 1. Business Search — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_business_search  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/search`  
**Swift method:** `CDYelpAPIClient.searchBusinesses(byTerm:location:latitude:longitude:radius:categories:locale:limit:offset:sortBy:priceTiers:openNow:openAt:attributes:devicePlatform:reservationDate:reservationTime:reservationCovers:matchesPartySize:jobAlias:)`  
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
| `device_platform` | string | No | ✅ | Values: `android`, `ios`, `mobile-generic` |
| `reservation_date` | string | No | ✅ | Format: `YYYY-MM-DD` |
| `reservation_time` | string | No | ✅ | Format: `HH:MM` |
| `reservation_covers` | integer | No | ✅ | Party size 1–10 |
| `matches_party_size_param` | boolean | No | ✅ | Filters results to those matching party size |
| `job_alias` | string | No | ✅ | Filters by home-service job type alias |

Schema is correct. No changes needed.

---

### 2. Phone Search — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_business_phone_search  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/search/phone`  
**Swift method:** `CDYelpAPIClient.searchBusinesses(byPhoneNumber:locale:)`  
**Response type:** `CDYelpSearchResponse.Phone`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `phone` | string | Yes | ✅ | Must start with `+` and include country code |
| `locale` | string | No | ✅ | |

Schema is correct. No changes needed.

---

### 3. Business Match — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_business_match  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/matches`  
**Swift method:** `CDYelpAPIClient.searchBusinesses(name:addressOne:addressTwo:addressThree:city:state:country:latitude:longitude:phone:zipCode:yelpBusinessId:limit:matchThresholdType:)`  
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

### 4. Business Details — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_business_info  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/{business_id_or_alias}`  
**Swift method:** `CDYelpAPIClient.fetchBusiness(forId:locale:devicePlatform:)`  
**Response type:** `CDYelpBusinessResponse` (wraps `CDYelpBusiness.Detailed`)

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `business_id_or_alias` | string | Yes | ✅ | Path parameter; asserted non-empty |
| `locale` | string | No | ✅ | |
| `device_platform` | string | No | ✅ | Values: `android`, `ios`, `mobile-generic` |

Schema is correct. No changes needed.

---

### 5. Food Delivery Search — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_transaction_search  
**HTTP method:** `GET`  
**Path:** `/v3/transactions/{transaction_type}/search`  
**Swift method:** `CDYelpAPIClient.searchTransactions(byType:location:latitude:longitude:term:categories:priceTiers:)`  
**Response type:** `CDYelpSearchResponse.Transaction`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `transaction_type` | string | Yes | ✅ | Path param; `CDYelpTransactionType` raw value |
| `latitude` | number | Conditional | ✅ | |
| `longitude` | number | Conditional | ✅ | |
| `location` | string | Conditional | ✅ | |
| `term` | string | No | ✅ | Business name or cuisine type filter |
| `categories` | array | No | ✅ | Comma-joined `CDYelpCategoryAlias` raw values |
| `price` | array | No | ✅ | Price tier filter; `CDYelpPriceTier` raw values |

Schema is correct. No changes needed.

---

### 6. Yelp AI Chat — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v2_ai_chat  
**HTTP method:** `POST`  
**Path:** `/ai/chat/v2`  
**Base URL:** `https://api.yelp.com` (no `/v3/` prefix)  
**Swift method:** `CDYelpAPIClient.fetchAIChat(query:chatId:latitude:longitude:requestContext:)`  
**Request type:** `CDYelpAIChatRequest`  
**Response type:** `CDYelpAIChatResponse`

#### Request body (JSON)

| Field | Type | Required | Implemented | Notes |
|-------|------|----------|-------------|-------|
| `query` | string | Yes | ✅ | Max 1000 characters; asserted in client |
| `chat_id` | string | No | ✅ | Conversation ID for multi-turn chat |
| `user_context` | object | No | ✅ | `{ "latitude": Double, "longitude": Double }` |
| `request_context` | object | No | ✅ | Key-value context for response format control |

#### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `chat_id` | string | Conversation ID; pass back to continue the chat |
| `response` | string | Natural language response text |
| `businesses` | array | Relevant `CDYelpBusiness.BusinessSearch` results |
| `error` | object | `CDYelpError` if the request failed |

Schema is correct. No changes needed.

---

### 7. Engagement Metrics — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_get_businesses_engagement  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/engagement`  
**Swift method:** `CDYelpAPIClient.fetchEngagementMetrics(forBusinessIds:dateRangeStart:dateRangeEnd:)`  
**Response type:** `CDYelpEngagementResponse`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `business_ids` | array of strings | Yes | ✅ | 1–20 items; comma-joined; asserted in client |
| `date_range_start` | date | No | ✅ | Start of date range |
| `date_range_end` | date | No | ✅ | End of date range |

Schema is correct. No changes needed.

---

### 8. Service Offerings — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_business_service_offerings  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/{business_id_or_alias}/service_offerings`  
**Swift method:** `CDYelpAPIClient.fetchServiceOfferings(forBusinessId:locale:)`  
**Response type:** `CDYelpServiceOfferingsResponse`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `business_id_or_alias` | string | Yes | ✅ | Path parameter; asserted non-empty |
| `locale` | string | No | ✅ | |

Schema is correct. No changes needed.

---

### 9. Business Insights — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_businesses_insights  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/insights`  
**Swift method:** `CDYelpAPIClient.fetchBusinessInsights(forBusinessIds:dateRangeStart:dateRangeEnd:)`  
**Response type:** `CDYelpBusinessInsightsResponse`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `business_ids` | array of strings | Yes | ✅ | 1–20 items; comma-joined; asserted in client |
| `date_range_start` | string | Yes | ✅ | Format: `YYYYMM`; asserted non-empty |
| `date_range_end` | string | Yes | ✅ | Format: `YYYYMM`; asserted non-empty |

Schema is correct. No changes needed.

---

## Reviews

---

### 10. Reviews — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_business_reviews  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/{business_id_or_alias}/reviews`  
**Swift method:** `CDYelpAPIClient.fetchReviews(forBusinessId:locale:offset:limit:sortBy:)`  
**Response type:** `CDYelpReviewsResponse`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `business_id_or_alias` | string | Yes | ✅ | Path parameter |
| `locale` | string | No | ✅ | |
| `offset` | integer | No | ✅ | 0–1000 |
| `limit` | integer | No | ✅ | 0–50; asserted in client |
| `sort_by` | string | No | ✅ | `CDYelpReviewSortType` raw value |

Schema is correct. No changes needed.

---

### 11. Review Highlights — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_business_review_highlights  
**HTTP method:** `GET`  
**Path:** `/v3/businesses/{business_id_or_alias}/review_highlights`  
**Swift method:** `CDYelpAPIClient.fetchReviewHighlights(forBusinessId:count:locale:devicePlatform:)`  
**Response type:** `CDYelpReviewHighlightsResponse`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `business_id_or_alias` | string | Yes | ✅ | Path parameter; asserted non-empty |
| `count` | integer | No | ✅ | 1–5; asserted in client |
| `locale` | string | No | ✅ | |
| `device_platform` | string | No | ✅ | Values: `android`, `ios`, `mobile-generic` |

Schema is correct. No changes needed.

---

## Events

---

### 12. Event Search — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_events_search  
**HTTP method:** `GET`  
**Path:** `/v3/events`  
**Swift method:** `CDYelpAPIClient.searchEvents(byLocale:offset:limit:sortBy:sortOn:startDate:endDate:categories:isFree:location:latitude:longitude:radius:excludedEvents:)`  
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
**Swift method:** `CDYelpAPIClient.fetchEvent(forId:locale:)`  
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
**Swift method:** `CDYelpAPIClient.fetchFeaturedEvent(forLocale:location:latitude:longitude:)`  
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
**Swift method:** `CDYelpAPIClient.fetchCategories(forLocale:)`  
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
**Swift method:** `CDYelpAPIClient.fetchCategory(forAlias:andLocale:)`  
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

### 17. Home Services — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_get_jobs  
**HTTP method:** `POST`  
**Path:** `/v3/jobs`  
**Swift method:** `CDYelpAPIClient.fetchJobs(forQuery:locale:)`  
**Response type:** `CDYelpJobsResponse`

#### Request body (JSON)

| Field | Type | Required | Implemented | Notes |
|-------|------|----------|-------------|-------|
| `query` | string | Yes | ✅ | 1–1000 characters; asserted in client |
| `locale` | string | No | ✅ | `CDYelpLocale` raw value |

Schema is correct. No changes needed.

---

## Autocomplete

---

### 18. Autocomplete — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_autocomplete  
**HTTP method:** `GET`  
**Path:** `/v3/autocomplete`  
**Swift method:** `CDYelpAPIClient.autocompleteBusinesses(byText:latitude:longitude:locale:)`  
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
public func fetchLead(forId id: String) async throws -> CDYelpLeadResponse {
    precondition(!id.isEmpty, "A lead ID is required.")
    let request = try CDYelpRouter.lead(id: id).asURLRequest(apiKey: apiKey)
    return try await urlSession.perform(request)
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
public func addBusinessesToWebhookAllowList(_ businessIds: [String]) async throws -> CDYelpWebhookAllowListResponse {
    precondition(!businessIds.isEmpty && businessIds.count <= 100,
                 "Between 1 and 100 business IDs are required.")
    let request = try CDYelpRouter.addToWebhookAllowList(businessIds: businessIds).asURLRequest(apiKey: apiKey)
    return try await urlSession.perform(request)
}
```

---

## Reservations

---

### 23. Reservations — ✅ Implemented

**API reference:** https://docs.developer.yelp.com/reference/v3_openings  
**HTTP method:** `GET`  
**Path:** `/v3/bookings/{business_id_or_alias}/openings`  
**Swift method:** `CDYelpAPIClient.fetchOpenings(forBusinessId:covers:date:time:getCoversRange:)`  
**Response type:** `CDYelpOpeningsResponse`

#### Request parameters

| Parameter | Type | Required | Implemented | Notes |
|-----------|------|----------|-------------|-------|
| `business_id_or_alias` | string | Yes | ✅ | Path parameter; asserted non-empty |
| `covers` | integer | Yes | ✅ | Party size 1–10; asserted in client |
| `date` | string | Yes | ✅ | Format `YYYY-MM-DD`; asserted non-empty |
| `time` | string | Yes | ✅ | Format `HH:MM`; asserted non-empty |
| `get_covers_range` | boolean | No | ✅ | Include `CDYelpCoversRange` in response |

#### Response fields

| Field | Swift type | Notes |
|-------|-----------|-------|
| `reservation_times` | `[CDYelpReservationDay]?` | Array of dates with available time slots; covers 4 days |
| `reservation_times[].date` | `String?` | Format `YYYY-MM-DD` |
| `reservation_times[].times` | `[CDYelpReservationTime]?` | Available slots for that date |
| `reservation_times[].times[].time` | `String?` | Format `HH:MM` |
| `reservation_times[].times[].credit_card_required` | `Bool?` | Credit card required to hold reservation |
| `covers_range.min_party_size` | `Int?` | Only present when `get_covers_range=true` |
| `covers_range.max_party_size` | `Int?` | Only present when `get_covers_range=true` |

Schema is correct. No changes needed.

---

## Summary

| # | Endpoint | Status |
|---|----------|--------|
| 1 | Business Search | ✅ Correct |
| 2 | Phone Search | ✅ Correct |
| 3 | Business Match | ✅ Correct |
| 4 | Business Details | ✅ Correct |
| 5 | Food Delivery Search | ✅ Correct |
| 6 | Yelp AI Chat | ✅ Correct |
| 7 | Engagement Metrics | ✅ Correct |
| 8 | Service Offerings | ✅ Correct |
| 9 | Business Insights | ✅ Correct |
| 10 | Reviews | ✅ Correct |
| 11 | Review Highlights | ✅ Correct |
| 12 | Event Search | ✅ Correct |
| 13 | Event Details | ✅ Correct |
| 14 | Featured Event | ✅ Correct |
| 15 | All Categories | ✅ Correct |
| 16 | Category Details | ✅ Correct |
| 17 | Home Services | ✅ Correct |
| 18 | Autocomplete | ✅ Correct |
| 19 | OAuth Authorization | ❌ Not applicable (API key auth only) |
| 20 | Data Ingestion | 🔒 Not implemented (partner contract required) |
| 21 | Leads | 🔒 Not implemented (OAuth + advertising required) |
| 22 | Webhooks | ❌ Not implemented (deprecated) |
| 23 | Reservations | ✅ Correct |
