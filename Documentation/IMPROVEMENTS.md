# CDYelpFusionKit Improvements

## v5.1.0: API Schema Completeness

Additive, non-breaking updates that bring the Swift types into full alignment with the current Yelp Fusion API v3 schema. All existing call sites remain unchanged. Each update is independent and can be implemented and reviewed in isolation.

---

### ✅ Schema Update 1: `CDYelpTransactionType` — Add `pickup` and `restaurantReservation`

**Goal:** The Yelp Fusion API transaction search endpoint supports three transaction types — `delivery`, `pickup`, and `restaurant_reservation` — but the Swift enum only defines `delivery`. This means callers cannot search for pickup-only or reservation-only businesses.

#### Changes to Existing Files

##### `Source/CDYelpEnums.swift`

Find `CDYelpTransactionType` (currently the last enum in the file, around line 1732). It reads:

```swift
public enum CDYelpTransactionType: String, Sendable {
    case foodDelivery = "delivery"
}
```

Replace it with:

```swift
public enum CDYelpTransactionType: String, Sendable {
    case foodDelivery = "delivery"
    case pickup
    case restaurantReservation = "restaurant_reservation"
}
```

Update the doc comment above the enum to reflect all three supported types:

```swift
///
/// A list of the transaction types the Yelp Fusion API supports.
///
```

##### `Source/CDYelpAPIClient.swift`

Find the doc comment above `searchTransactions(byType:location:latitude:longitude:completion:)`. Update the description line from:

> Currently, this endpoint only supports food delivery in the US.

to:

> This endpoint supports food delivery, pickup, and restaurant reservations. Delivery and pickup are only supported in the US.

#### New Test File

##### `Tests/CDYelpFusionKitTests/Enums/CDYelpTransactionTypeTests.swift`

```swift
@testable import CDYelpFusionKit
import Testing

@Suite struct CDYelpTransactionTypeTests {
    @Test func foodDeliveryRawValue() {
        #expect(CDYelpTransactionType.foodDelivery.rawValue == "delivery")
    }

    @Test func pickupRawValue() {
        #expect(CDYelpTransactionType.pickup.rawValue == "pickup")
    }

    @Test func restaurantReservationRawValue() {
        #expect(CDYelpTransactionType.restaurantReservation.rawValue == "restaurant_reservation")
    }
}
```

#### Completion Checklist

- [ ] Add `.pickup` and `.restaurantReservation` to `CDYelpTransactionType` in `Source/CDYelpEnums.swift`
- [ ] Update doc comment on `CDYelpTransactionType`
- [ ] Update description in `searchTransactions` doc comment in `Source/CDYelpAPIClient.swift`
- [ ] Create `Tests/CDYelpFusionKitTests/Enums/CDYelpTransactionTypeTests.swift`
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 2: `CDYelpAttributeFilter` — Add Missing Filter Values

**Goal:** The `CDYelpAttributeFilter` enum currently defines 8 values from an older snapshot of the Yelp API. The Yelp Fusion API has since added parking and dietary preference filters. Without these, callers cannot filter search results by parking availability or dietary options.

#### Changes to Existing Files

##### `Source/CDYelpEnums.swift`

Find `CDYelpAttributeFilter` (lines 34–43). It currently reads:

```swift
public enum CDYelpAttributeFilter: String, Sendable {
    case hotAndNew = "hot_and_new"
    case requestAQuote = "request_a_quote"
    case reservation
    case waitlistReservation = "waitlist_reservation"
    case deals
    case genderNeutralRestrooms = "gender_neutral_restrooms"
    case openToAll = "open_to_all"
    case wheelchairAccessible = "wheelchair_accessible"
}
```

Replace it with the following, grouping the new cases with inline comments:

```swift
public enum CDYelpAttributeFilter: String, Sendable {
    case hotAndNew = "hot_and_new"
    case requestAQuote = "request_a_quote"
    case reservation
    case waitlistReservation = "waitlist_reservation"
    case deals
    case genderNeutralRestrooms = "gender_neutral_restrooms"
    case openToAll = "open_to_all"
    case wheelchairAccessible = "wheelchair_accessible"
    // Parking
    case parkingGarage = "parking_garage"
    case parkingLot = "parking_lot"
    case parkingStreet = "parking_street"
    case parkingValet = "parking_valet"
    case parkingBike = "parking_bike"
    case parkingValidated = "parking_validated"
    // Dietary
    case likedByVegetarians = "liked_by_vegetarians"
    case veganOfferings = "vegan_offerings"
    case glutenFreeOfferings = "gluten_free_offerings"
    case outdoorSeating = "outdoor_seating"
}
```

#### New Test File

##### `Tests/CDYelpFusionKitTests/Enums/CDYelpAttributeFilterTests.swift`

```swift
@testable import CDYelpFusionKit
import Testing

@Suite struct CDYelpAttributeFilterTests {
    @Test func parkingRawValues() {
        #expect(CDYelpAttributeFilter.parkingGarage.rawValue == "parking_garage")
        #expect(CDYelpAttributeFilter.parkingLot.rawValue == "parking_lot")
        #expect(CDYelpAttributeFilter.parkingStreet.rawValue == "parking_street")
        #expect(CDYelpAttributeFilter.parkingValet.rawValue == "parking_valet")
        #expect(CDYelpAttributeFilter.parkingBike.rawValue == "parking_bike")
        #expect(CDYelpAttributeFilter.parkingValidated.rawValue == "parking_validated")
    }

    @Test func dietaryRawValues() {
        #expect(CDYelpAttributeFilter.likedByVegetarians.rawValue == "liked_by_vegetarians")
        #expect(CDYelpAttributeFilter.veganOfferings.rawValue == "vegan_offerings")
        #expect(CDYelpAttributeFilter.glutenFreeOfferings.rawValue == "gluten_free_offerings")
        #expect(CDYelpAttributeFilter.outdoorSeating.rawValue == "outdoor_seating")
    }
}
```

#### Completion Checklist

- [ ] Add parking and dietary cases to `CDYelpAttributeFilter` in `Source/CDYelpEnums.swift`
- [ ] Create `Tests/CDYelpFusionKitTests/Enums/CDYelpAttributeFilterTests.swift`
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 3: `fetchReviews` — Add `limit` and `sortBy` Parameters

**Goal:** The Yelp Fusion reviews endpoint accepts three parameters the library does not expose: `offset` (pagination), `limit` (0–50, defaults to 20), and `sort_by` (review sort order). Without these, callers cannot paginate, control result count, or choose sort order.

#### New Types

A new sort type enum is needed. Add it to `Source/CDYelpEnums.swift` immediately after `CDYelpEventSortOnType` and before `CDYelpLocale`:

```swift
///
/// A list of the review sort types the Yelp Fusion API supports.
///
public enum CDYelpReviewSortType: String, Sendable {
    case yelpSort = "yelp_sort"
    case rating
    case timeCreated = "time_created"
}
```

#### Changes to Existing Files

##### `Source/Parameters+CDYelpFusionKit.swift`

Find `reviewsParameters(withLocale:)`. It currently reads:

```swift
static func reviewsParameters(withLocale locale: CDYelpLocale?) -> Parameters {
    var parameters: Parameters = [:]
    if let locale = locale, locale.rawValue != "" {
        parameters["locale"] = locale.rawValue
    }
    return parameters
}
```

Replace it with:

```swift
static func reviewsParameters(withLocale locale: CDYelpLocale?,
                              offset: Int?,
                              limit: Int?,
                              sortBy: CDYelpReviewSortType?) -> Parameters {
    var parameters: Parameters = [:]
    if let locale = locale, locale.rawValue != "" {
        parameters["locale"] = locale.rawValue
    }
    if let offset = offset { parameters["offset"] = offset }
    if let limit = limit { parameters["limit"] = limit }
    if let sortBy = sortBy { parameters["sort_by"] = sortBy.rawValue }
    return parameters
}
```

##### `Source/CDYelpAPIClient.swift` — Completion-handler overload

Find `fetchReviews(forBusinessId:locale:completion:)`. Update its signature and body:

```swift
public func fetchReviews(forBusinessId id: String!,
                         locale: CDYelpLocale?,
                         offset: Int? = nil,
                         limit: Int? = nil,
                         sortBy: CDYelpReviewSortType? = nil,
                         completion: @escaping (CDYelpReviewsResponse?) -> Void)
```

Inside the method body, update the `reviewsParameters` call:

```swift
let parameters = Parameters.reviewsParameters(withLocale: locale,
                                              offset: offset,
                                              limit: limit,
                                              sortBy: sortBy)
```

Add assertions before the `isAuthenticated()` check:

```swift
if let offset = offset {
    assert(offset >= 0 && offset <= 1000, "offset must be between 0 and 1000.")
}
if let limit = limit {
    assert(limit >= 0 && limit <= 50, "The limit must be between 0 and 50.")
}
```

Update the doc comment to document the three new parameters:
```
///   - offset: (Optional) A number the list of returned reviews should be offset by. **The maximum value is 1000**.
///   - limit: (Optional) The number of reviews to return. **The maximum value is 50**.
///   - sortBy: (Optional) The sort order for reviews. Defaults to `.yelpSort`.
```

##### `Source/CDYelpAPIClient.swift` — Async overload

Find `fetchReviews(forBusinessId:locale:)` in the `// MARK: - Async/Await Overloads` section. Apply identical signature and body changes, using `= nil` defaults so existing call sites are unaffected.

#### New Test File

##### `Tests/CDYelpFusionKitTests/Enums/CDYelpReviewSortTypeTests.swift`

```swift
@testable import CDYelpFusionKit
import Testing

@Suite struct CDYelpReviewSortTypeTests {
    @Test func yelpSortRawValue() {
        #expect(CDYelpReviewSortType.yelpSort.rawValue == "yelp_sort")
    }

    @Test func ratingRawValue() {
        #expect(CDYelpReviewSortType.rating.rawValue == "rating")
    }

    @Test func timeCreatedRawValue() {
        #expect(CDYelpReviewSortType.timeCreated.rawValue == "time_created")
    }
}
```

#### Completion Checklist

- [ ] Add `CDYelpReviewSortType` enum to `Source/CDYelpEnums.swift`
- [ ] Update `reviewsParameters` in `Source/Parameters+CDYelpFusionKit.swift` to accept `limit` and `sortBy`
- [ ] Update completion-handler `fetchReviews` signature and body in `Source/CDYelpAPIClient.swift` (add `offset`, `limit`, `sortBy`)
- [ ] Update async `fetchReviews` signature and body in `Source/CDYelpAPIClient.swift` (add `offset`, `limit`, `sortBy`)
- [ ] Create `Tests/CDYelpFusionKitTests/Enums/CDYelpReviewSortTypeTests.swift`
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 4: `CDYelpReview` — Add `language` Field

**Goal:** The Yelp Fusion reviews endpoint returns a `language` field on each review object indicating the language the review is written in (e.g. `"en"`, `"fr"`). This field is currently not decoded.

#### Changes to Existing Files

##### `Source/CDYelpReview.swift`

Add `language` as an optional `String` property. The full struct after the change should read:

```swift
public struct CDYelpReview: Decodable, Sendable {
    public let id: String?
    public let text: String?
    public let url: String?
    public let rating: Int?
    public let timeCreated: String?
    public let user: CDYelpUser?
    public let language: String?

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case url
        case rating
        case timeCreated = "time_created"
        case user
        case language
    }

    public func urlAsUrl() -> URL? {
        if let url = url, let asUrl = URL(string: url) {
            return asUrl
        }
        return nil
    }

    public func timeCreatedAsDate() -> Date? {
        timeCreated.flatMap { DateFormatter.reviews.date(from: $0) }
    }
}
```

#### Update Existing Test Fixture

##### `Tests/CDYelpFusionKitTests/Fixtures/reviews_response.json`

Add `"language": "en"` to the review object in the fixture so the decode test exercises the new field:

```json
{
  "total": 1,
  "possible_languages": ["en"],
  "reviews": [
    {
      "id": "xAG4O7l-t1ubbwVAlaPNNA",
      "url": "https://www.yelp.com/biz/gary-danko-san-francisco?hrid=xAG4O7l-t1ubbwVAlaPNNA",
      "text": "Went back again to this place since the last time I was here in 2020.",
      "rating": 5,
      "time_created": "2020-11-18 22:30:48",
      "language": "en",
      "user": {
        "id": "U4INQZOPSKyl0bHR4YRVYA",
        "profile_url": "https://www.yelp.com/user_details?userid=U4INQZOPSKyl0bHR4YRVYA",
        "image_url": "https://s3-media3.fl.yelpcdn.com/photo/iwoAD12zkONZxJ94ChAaMg/o.jpg",
        "name": "Liz A."
      }
    }
  ]
}
```

#### New Test File

##### `Tests/CDYelpFusionKitTests/Model/CDYelpReviewTests.swift`

```swift
@testable import CDYelpFusionKit
import Foundation
import Testing

@Suite struct CDYelpReviewTests {
    @Test func decodesLanguageField() throws {
        let json = """
        {
          "id": "abc123",
          "text": "Great place!",
          "url": "https://www.yelp.com/biz/foo",
          "rating": 5,
          "time_created": "2020-11-18 22:30:48",
          "language": "en",
          "user": null
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let review = try decoder.decode(CDYelpReview.self, from: json)
        #expect(review.language == "en")
    }

    @Test func languageIsNilWhenAbsent() throws {
        let json = """
        {
          "id": "abc123",
          "text": "Great place!",
          "url": "https://www.yelp.com/biz/foo",
          "rating": 5,
          "time_created": "2020-11-18 22:30:48",
          "user": null
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let review = try decoder.decode(CDYelpReview.self, from: json)
        #expect(review.language == nil)
    }
}
```

#### Completion Checklist

- [ ] Add `language: String?` property and `CodingKey` to `CDYelpReview` in `Source/CDYelpReview.swift`
- [ ] Add `"language": "en"` to the review object in `Tests/CDYelpFusionKitTests/Fixtures/reviews_response.json`
- [ ] Create `Tests/CDYelpFusionKitTests/Model/CDYelpReviewTests.swift`
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 5: Business Search — Add Missing Request Parameters

**Goal:** Six optional parameters accepted by `GET /v3/businesses/search` are not forwarded by the library: `device_platform`, `reservation_date`, `reservation_time`, `reservation_covers`, `matches_party_size_param`, and `job_alias`.

#### Changes to Existing Files

##### `Source/Parameters+CDYelpFusionKit.swift`

Find `searchParameters(withTerm:location:latitude:longitude:radius:categories:locale:limit:offset:sortBy:priceTiers:openNow:openAt:attributes:)`. It currently has 14 parameters and ends with `attributes: [CDYelpAttributeFilter]?) -> Parameters {`. Replace the entire function signature and add the new parameter handling after the existing `attributes` block:

New signature (20 parameters — add 6 new trailing ones):

```swift
static func searchParameters(withTerm term: String?,
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
                             devicePlatform: String?,
                             reservationDate: String?,
                             reservationTime: String?,
                             reservationCovers: Int?,
                             matchesPartySize: Bool?,
                             jobAlias: String?) -> Parameters
```

In the function body, append the following 6 blocks immediately after the existing `attributes` block (before `return parameters`):

```swift
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
```

##### `Source/CDYelpAPIClient.swift` — Completion-handler overload

Find `searchBusinesses(byTerm:location:latitude:longitude:radius:categories:locale:limit:offset:sortBy:priceTiers:openNow:openAt:attributes:completion:)`. Add the same 6 parameters (all `= nil` defaulted) to the end of the signature, before `completion:`:

```swift
devicePlatform: String? = nil,
reservationDate: String? = nil,
reservationTime: String? = nil,
reservationCovers: Int? = nil,
matchesPartySize: Bool? = nil,
jobAlias: String? = nil,
```

Pass them through to `searchParameters(...)` by adding 6 matching arguments to the `Parameters.searchParameters(...)` call inside the method body:

```swift
devicePlatform: devicePlatform,
reservationDate: reservationDate,
reservationTime: reservationTime,
reservationCovers: reservationCovers,
matchesPartySize: matchesPartySize,
jobAlias: jobAlias
```

##### `Source/CDYelpAPIClient.swift` — Async overload

Find the async `searchBusinesses(byTerm:...)` overload in the `// MARK: - Async/Await Overloads` section. Add the same 6 `= nil`-defaulted parameters and forward them to the callback overload.

#### Completion Checklist

- [ ] Add 6 new trailing parameters to `searchParameters` in `Source/Parameters+CDYelpFusionKit.swift`
- [ ] Append 6 new parameter blocks to the `searchParameters` body (after the `attributes` block)
- [ ] Add 6 `= nil`-defaulted parameters to the completion-handler `searchBusinesses(byTerm:...)` in `Source/CDYelpAPIClient.swift` and pass them through to `searchParameters`
- [ ] Add the same 6 parameters to the async `searchBusinesses(byTerm:...)` overload and forward them
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 6: Phone Search — Add `locale` Parameter

**Goal:** `GET /v3/businesses/search/phone` accepts a `locale` parameter that the library ignores.

#### Changes to Existing Files

##### `Source/Parameters+CDYelpFusionKit.swift`

Find `phoneParameters(withPhoneNumber:)`. It currently reads:

```swift
static func phoneParameters(withPhoneNumber phoneNumber: String!) -> Parameters {
    var parameters: Parameters = [:]
    parameters["phone"] = phoneNumber
    return parameters
}
```

Replace it with:

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

##### `Source/CDYelpAPIClient.swift` — Completion-handler overload

Find `searchBusinesses(byPhoneNumber:completion:)`. Add `locale: CDYelpLocale? = nil` before `completion:` and pass it to `phoneParameters(withPhoneNumber:locale:)`.

##### `Source/CDYelpAPIClient.swift` — Async overload

Find the async `searchBusinesses(byPhoneNumber:)` overload. Add `locale: CDYelpLocale? = nil` and forward it to the callback overload.

#### Completion Checklist

- [ ] Update `phoneParameters(withPhoneNumber:)` in `Source/Parameters+CDYelpFusionKit.swift` to accept and forward `locale: CDYelpLocale?`
- [ ] Add `locale: CDYelpLocale? = nil` to the completion-handler `searchBusinesses(byPhoneNumber:completion:)` in `Source/CDYelpAPIClient.swift` and pass to `phoneParameters`
- [ ] Add `locale: CDYelpLocale? = nil` to the async `searchBusinesses(byPhoneNumber:)` overload and forward
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 7: Business Details — Add `device_platform` Parameter

**Goal:** `GET /v3/businesses/{id}` accepts a `device_platform` parameter that the library ignores.

#### Changes to Existing Files

##### `Source/Parameters+CDYelpFusionKit.swift`

Find `businessParameters(withLocale:)`. It currently reads:

```swift
static func businessParameters(withLocale locale: CDYelpLocale?) -> Parameters {
    var parameters: Parameters = [:]
    if let locale = locale,
       locale.rawValue != ""
    {
        parameters["locale"] = locale.rawValue
    }
    return parameters
}
```

Replace it with:

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

##### `Source/CDYelpAPIClient.swift` — Completion-handler overload

Find `fetchBusiness(forId:locale:completion:)`. Add `devicePlatform: String? = nil` before `completion:` and pass it to `businessParameters(withLocale:devicePlatform:)`.

##### `Source/CDYelpAPIClient.swift` — Async overload

Find the async `fetchBusiness(forId:locale:)` overload. Add `devicePlatform: String? = nil` and forward it to the callback overload.

#### Completion Checklist

- [ ] Update `businessParameters(withLocale:)` in `Source/Parameters+CDYelpFusionKit.swift` to accept `devicePlatform: String?`
- [ ] Add `devicePlatform: String? = nil` to the completion-handler `fetchBusiness(forId:locale:completion:)` in `Source/CDYelpAPIClient.swift` and pass to `businessParameters(withLocale:devicePlatform:)`
- [ ] Add `devicePlatform: String? = nil` to the async `fetchBusiness(forId:locale:)` overload and forward
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 8: Food Delivery Search — Add `term`, `categories`, and `price` Parameters

**Goal:** `GET /v3/transactions/{type}/search` accepts `term`, `categories`, and `price` parameters that the library does not expose.

#### Changes to Existing Files

##### `Source/Parameters+CDYelpFusionKit.swift`

Find `transactionsParameters(withLocation:latitude:longitude:)`. It currently reads:

```swift
static func transactionsParameters(withLocation location: String?,
                                   latitude: Double?,
                                   longitude: Double?) -> Parameters
{
    var parameters: Parameters = [:]
    if let location = location,
       location != ""
    {
        parameters["location"] = location
    }
    if let latitude = latitude {
        parameters["latitude"] = latitude
    }
    if let longitude = longitude {
        parameters["longitude"] = longitude
    }
    return parameters
}
```

Replace it with:

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

##### `Source/CDYelpAPIClient.swift` — Completion-handler overload

Find `searchTransactions(byType:location:latitude:longitude:completion:)`. Add `term: String? = nil`, `categories: [CDYelpCategoryAlias]? = nil`, `priceTiers: [CDYelpPriceTier]? = nil` before `completion:` and forward them to `transactionsParameters(...)`.

##### `Source/CDYelpAPIClient.swift` — Async overload

Find the async `searchTransactions(byType:...)` overload. Add the same 3 `= nil`-defaulted parameters and forward them to the callback overload.

#### Completion Checklist

- [ ] Replace `transactionsParameters` in `Source/Parameters+CDYelpFusionKit.swift` with the new 6-parameter version
- [ ] Add `term: String? = nil`, `categories: [CDYelpCategoryAlias]? = nil`, `priceTiers: [CDYelpPriceTier]? = nil` to the completion-handler `searchTransactions(byType:...)` in `Source/CDYelpAPIClient.swift` and pass through
- [ ] Add the same 3 parameters to the async `searchTransactions(byType:...)` overload and forward
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 9: Yelp AI Chat — New Endpoint

**Goal:** Implement `POST /ai/chat/v2`. This is a POST endpoint with a JSON body (unlike all existing GET endpoints) that supports natural language queries about local businesses with optional multi-turn conversation via `chat_id`.

#### New Files

##### `Source/CDYelpAIChatRequest.swift`

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

##### `Source/CDYelpAIChatResponse.swift`

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

#### Changes to Existing Files

##### `Source/CDYelpRouter.swift`

Add a new case to the enum:

```swift
case aiChat(request: CDYelpAIChatRequest)
```

Add to `var method`:

```swift
case .aiChat:
    return .post
```

Add to `var path`:

```swift
case .aiChat:
    return "ai/chat/v2"
```

In `asURLRequest()`, add a new branch **before** the existing URL-encoding switch. The existing switch applies `URLEncoding.default` to all cases — the AI chat case must be extracted before it reaches that point:

```swift
// Handle POST + JSON body cases before URL-encoding switch
if case let .aiChat(request) = self {
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    urlRequest.httpMethod = method.rawValue
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.httpBody = try JSONEncoder().encode(request)
    return urlRequest
}
```

##### `Source/CDYelpAPIClient.swift`

Add callback overload:

```swift
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
```

Add async overload (place in `// MARK: - Async/Await Overloads` section):

```swift
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

#### Completion Checklist

- [ ] Create `Source/CDYelpAIChatRequest.swift`
- [ ] Create `Source/CDYelpAIChatResponse.swift`
- [ ] Add `case aiChat(request: CDYelpAIChatRequest)` to `CDYelpRouter` with `.post` method and `"ai/chat/v2"` path
- [ ] Add JSON body branch in `CDYelpRouter.asURLRequest()` before the URL-encoding switch
- [ ] Add callback `fetchAIChat(query:chatId:latitude:longitude:completion:)` to `CDYelpAPIClient`
- [ ] Add async `fetchAIChat(query:chatId:latitude:longitude:)` overload
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 10: Engagement Metrics — New Endpoint (🔒 special permissions required)

**Goal:** Implement `GET /v3/businesses/engagement`. This endpoint requires special permissions on the API key but the library should expose the method so callers with access can use it.

#### New Files

##### `Source/CDYelpEngagementResponse.swift`

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

#### Changes to Existing Files

##### `Source/CDYelpRouter.swift`

Add to the enum:

```swift
case engagement(parameters: Parameters)
```

Add to `var method`: `.get`
Add to `var path`: `"businesses/engagement"`
This case uses `URLEncoding.default` — no special handling needed in `asURLRequest()`.

##### `Source/Parameters+CDYelpFusionKit.swift`

Add a new parameters function:

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

##### `Source/CDYelpAPIClient.swift`

Add callback overload:

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
```

Add async overload:

```swift
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

#### Completion Checklist

- [ ] Create `Source/CDYelpEngagementResponse.swift`
- [ ] Add `case engagement(parameters: Parameters)` to `CDYelpRouter` with `.get` method and `"businesses/engagement"` path
- [ ] Add `engagementParameters(withBusinessIds:dateRangeStart:dateRangeEnd:)` to `Source/Parameters+CDYelpFusionKit.swift`
- [ ] Add callback `fetchEngagementMetrics(forBusinessIds:dateRangeStart:dateRangeEnd:completion:)` to `CDYelpAPIClient` with `precondition` that `businessIds.count` is 1–20
- [ ] Add async overload
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 11: Service Offerings — New Endpoint (🔒 special permissions required)

**Goal:** Implement `GET /v3/businesses/{id}/service_offerings`. Requires special permissions but should be available to callers who have them.

#### New Files

##### `Source/CDYelpServiceOfferingsResponse.swift`

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

#### Changes to Existing Files

##### `Source/CDYelpRouter.swift`

Add to the enum:

```swift
case serviceOfferings(id: String, parameters: Parameters)
```

Add to `var method`: `.get`
Add to `var path`: `"businesses/\(id)/service_offerings"`
This case uses `URLEncoding.default`.

##### `Source/CDYelpAPIClient.swift`

Add callback overload:

```swift
public func fetchServiceOfferings(forBusinessId id: String,
                                   locale: CDYelpLocale? = nil,
                                   completion: @escaping (CDYelpServiceOfferingsResponse?) -> Void) {
    precondition(!id.isEmpty, "A business ID is required.")
    guard isAuthenticated() else { return }

    let parameters = Parameters.businessParameters(withLocale: locale, devicePlatform: nil)
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
```

Add async overload:

```swift
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

**Note:** `businessParameters(withLocale:devicePlatform:)` is the updated signature from Schema Update 7. Implement Update 7 before or alongside this update.

#### Completion Checklist

- [ ] Create `Source/CDYelpServiceOfferingsResponse.swift`
- [ ] Add `case serviceOfferings(id: String, parameters: Parameters)` to `CDYelpRouter` with `.get` method and `"businesses/\(id)/service_offerings"` path
- [ ] Add callback `fetchServiceOfferings(forBusinessId:locale:completion:)` to `CDYelpAPIClient`
- [ ] Add async overload
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 12: Business Insights — New Endpoint (🔒 special permissions required)

**Goal:** Implement `GET /v3/businesses/insights`. Requires Yelp Insights API access.

#### New Files

##### `Source/CDYelpBusinessInsightsResponse.swift`

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

#### Changes to Existing Files

##### `Source/CDYelpRouter.swift`

Add to the enum:

```swift
case businessInsights(parameters: Parameters)
```

Add to `var method`: `.get`
Add to `var path`: `"businesses/insights"`
This case uses `URLEncoding.default`.

##### `Source/Parameters+CDYelpFusionKit.swift`

Add a new parameters function:

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

##### `Source/CDYelpAPIClient.swift`

Add callback overload:

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
```

Add async overload:

```swift
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

#### Completion Checklist

- [ ] Create `Source/CDYelpBusinessInsightsResponse.swift`
- [ ] Add `case businessInsights(parameters: Parameters)` to `CDYelpRouter` with `.get` method and `"businesses/insights"` path
- [ ] Add `businessInsightsParameters(withBusinessIds:dateRangeStart:dateRangeEnd:)` to `Source/Parameters+CDYelpFusionKit.swift`
- [ ] Add callback `fetchBusinessInsights(forBusinessIds:dateRangeStart:dateRangeEnd:completion:)` to `CDYelpAPIClient` with `precondition` that `businessIds.count` is 1–20 and both date strings are non-empty
- [ ] Add async overload
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 13: Review Highlights — New Endpoint (🔒 Premium Plan required)

**Goal:** Implement `GET /v3/businesses/{id}/review_highlights`. Requires Premium Plan access.

#### New Files

##### `Source/CDYelpReviewHighlightsResponse.swift`

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

#### Changes to Existing Files

##### `Source/CDYelpRouter.swift`

Add to the enum:

```swift
case reviewHighlights(id: String, parameters: Parameters)
```

Add to `var method`: `.get`
Add to `var path`: `"businesses/\(id)/review_highlights"`
This case uses `URLEncoding.default`.

##### `Source/Parameters+CDYelpFusionKit.swift`

Add a new parameters function:

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

##### `Source/CDYelpAPIClient.swift`

Add callback overload:

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
```

Add async overload:

```swift
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func fetchReviewHighlights(forBusinessId id: String,
                                   count: Int? = nil,
                                   locale: CDYelpLocale? = nil,
                                   devicePlatform: String? = nil) async throws -> CDYelpReviewHighlightsResponse {
    try await withCheckedThrowingContinuation { continuation in
        fetchReviewHighlights(forBusinessId: id,
                              count: count,
                              locale: locale,
                              devicePlatform: devicePlatform) { response in
            guard let response = response else {
                continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                return
            }
            continuation.resume(returning: response)
        }
    }
}
```

#### Completion Checklist

- [ ] Create `Source/CDYelpReviewHighlightsResponse.swift`
- [ ] Add `case reviewHighlights(id: String, parameters: Parameters)` to `CDYelpRouter` with `.get` method and `"businesses/\(id)/review_highlights"` path
- [ ] Add `reviewHighlightsParameters(count:locale:devicePlatform:)` to `Source/Parameters+CDYelpFusionKit.swift`
- [ ] Add callback `fetchReviewHighlights(forBusinessId:count:locale:devicePlatform:completion:)` to `CDYelpAPIClient` with a `precondition` that `count` is 1–5
- [ ] Add async overload
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### ✅ Schema Update 14: Home Services — New Endpoint

**Goal:** Implement `POST /v3/jobs`. POST with a JSON body (same pattern as Yelp AI Chat, Schema Update 9).

#### New Files

##### `Source/CDYelpJobsResponse.swift`

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

#### Changes to Existing Files

##### `Source/CDYelpRouter.swift`

Add to the enum:

```swift
case jobs(query: String, locale: String?)
```

Add to `var method`: `.post`
Add to `var path`: `"jobs"`

In `asURLRequest()`, add a branch for this case in the same POST+JSON block as `aiChat` (before the URL-encoding switch):

```swift
if case let .jobs(query, locale) = self {
    var urlRequest = URLRequest(url: url.appendingPathComponent(path))
    urlRequest.httpMethod = method.rawValue
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    var body: [String: String] = ["query": query]
    if let locale = locale { body["locale"] = locale }
    urlRequest.httpBody = try JSONEncoder().encode(body)
    return urlRequest
}
```

If `aiChat` was already added in Schema Update 9, combine both cases in a single early-return block or use a helper; either approach is acceptable.

##### `Source/CDYelpAPIClient.swift`

Add callback overload:

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
```

Add async overload:

```swift
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

#### Completion Checklist

- [ ] Create `Source/CDYelpJobsResponse.swift`
- [ ] Add `case jobs(query: String, locale: String?)` to `CDYelpRouter` with `.post` method and `"jobs"` path
- [ ] Add JSON body branch in `CDYelpRouter.asURLRequest()` for the `jobs` case (before the URL-encoding switch)
- [ ] Add callback `fetchJobs(forQuery:locale:completion:)` to `CDYelpAPIClient` with `precondition` that query is 1–1000 characters
- [ ] Add async overload
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

### Schema Update 15: Reservations — New Endpoint

**Goal:** Implement `GET /v3/bookings/{id}/openings`. Returns available reservation time slots for a business for a given date and party size. The API returns times across 4 days — the day before, the requested day, and 2 days after.

#### New Files

##### `Source/CDYelpOpeningsResponse.swift`

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

#### Changes to Existing Files

##### `Source/CDYelpRouter.swift`

Add to the enum:

```swift
case openings(businessId: String, parameters: Parameters)
```

Add to `var method`: `.get`
Add to `var path`: `"bookings/\(businessId)/openings"`
This case uses `URLEncoding.default`.

##### `Source/Parameters+CDYelpFusionKit.swift`

Add a new parameters function:

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

##### `Source/CDYelpAPIClient.swift`

Add callback overload:

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
```

Add async overload:

```swift
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

#### Completion Checklist

- [ ] Create `Source/CDYelpOpeningsResponse.swift` (4 structs: `CDYelpOpeningsResponse`, `CDYelpReservationDay`, `CDYelpReservationTime`, `CDYelpCoversRange`)
- [ ] Add `case openings(businessId: String, parameters: Parameters)` to `CDYelpRouter` with `.get` method and `"bookings/\(businessId)/openings"` path
- [ ] Add `openingsParameters(covers:date:time:getCoversRange:)` to `Source/Parameters+CDYelpFusionKit.swift`
- [ ] Add callback `fetchOpenings(forBusinessId:covers:date:time:getCoversRange:completion:)` to `CDYelpAPIClient` with `precondition` checks for non-empty `id`, `date`, `time`, and `covers` in 1–10
- [ ] Add async overload
- [ ] Run `swift build` — must succeed
- [ ] Run `swift test` — must pass
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations

---

## v6.0.0: Native URLSession Rewrite

**Goal:** Drop the Alamofire dependency entirely. Replace it with URLSession, URLComponents, and JSONDecoder. The five configuration structs and public protocols from v5 survive unchanged — only the internal implementation changes. The v5 test suite is the behavioral contract that catches regressions.

### Strategy

All of v5's *public surface* is preserved with one intentional exception: the async/await overloads currently throw `AFError` (an Alamofire type). In v6, `AFError` is replaced by `CDYelpNetworkError`, a native Swift error type defined in the library. This is the primary reason v6 is a major version bump.

Everything else — `CDYelpCacheConfiguration`, `CDYelpRetryConfiguration`, `CDYelpDecoderConfiguration`, `CDYelpEventMonitor`, `CDYelpRequestAdapter`, `CDYelpMockURLProtocol`, `CDYelpMockClientFactory` — compiles and behaves identically.

### Deployment Target Increase

`URLSession.data(for:)` with native `async/await` requires iOS 15, macOS 12, tvOS 15, watchOS 8. v6 raises the minimums accordingly. visionOS 1 already satisfies this.

Update `Package.swift`:

```swift
platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8),
    .visionOS(.v1)
]
```

Update `CDYelpFusionKit.podspec` deployment targets to match.

Update the CI matrix in `.github/workflows/ci.yml` to drop simulator versions that only support older OS versions.

### New Files to Create

#### `Source/CDYelpNetworkError.swift`

The public error type that replaces `AFError` in all thrown signatures.

```swift
import Foundation

/// Errors thrown by CDYelpFusionKit network operations.
public enum CDYelpNetworkError: Error, Sendable {
    /// The URLRequest could not be constructed from the given parameters.
    case invalidRequest(underlying: Error)
    /// The server returned a non-2xx HTTP status code.
    case httpError(statusCode: Int, data: Data)
    /// The response data could not be decoded into the expected model.
    case decodingFailed(underlying: Error)
    /// A network-level failure (timeout, no connectivity, etc.).
    case networkFailure(underlying: Error)
}
```

#### `Source/Internal/CDYelpURLSession.swift`

Internal actor that owns the `URLSession` and implements the core request/response cycle. Using an actor eliminates the `@unchecked Sendable` workaround on `CDYelpAPIClient`.

```swift
import Foundation

actor CDYelpURLSession {
    private let session: URLSession
    private let decoder: () -> JSONDecoder
    private let cache: CDYelpResponseCache?
    private let monitors: [any CDYelpEventMonitor]
    private let adapters: [any CDYelpRequestAdapter]
    private let retryConfig: CDYelpRetryConfiguration

    init(
        session: URLSession,
        decoder: @escaping () -> JSONDecoder,
        cache: CDYelpResponseCache?,
        monitors: [any CDYelpEventMonitor],
        adapters: [any CDYelpRequestAdapter],
        retryConfig: CDYelpRetryConfiguration
    ) {
        self.session = session
        self.decoder = decoder
        self.cache = cache
        self.monitors = monitors
        self.adapters = adapters
        self.retryConfig = retryConfig
    }

    func perform<T: Decodable>(_ urlRequest: URLRequest, attempt: UInt = 0) async throws -> T {
        var request = urlRequest
        for adapter in adapters {
            request = try adapter.adapt(request)
        }

        let cacheKey = CDYelpCacheKey.key(for: request)
        if let cache, let cached = cache.data(forKey: cacheKey) {
            return try decoder().decode(T.self, from: cached)
        }

        monitors.forEach { $0.requestDidStart(urlRequest: request) }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            monitors.forEach { $0.requestDidComplete(urlRequest: request, response: nil, data: nil, error: error) }
            let networkError = CDYelpNetworkError.networkFailure(underlying: error)
            if shouldRetry(error: networkError, statusCode: nil, attempt: attempt) {
                try await Task.sleep(nanoseconds: backoffNanoseconds(attempt: attempt))
                return try await perform(urlRequest, attempt: attempt + 1)
            }
            throw networkError
        }

        let httpResponse = response as? HTTPURLResponse
        monitors.forEach { $0.requestDidComplete(urlRequest: request, response: httpResponse, data: data, error: nil) }

        let statusCode = httpResponse?.statusCode ?? 0
        guard (200..<300).contains(statusCode) else {
            let error = CDYelpNetworkError.httpError(statusCode: statusCode, data: data)
            if shouldRetry(error: error, statusCode: statusCode, attempt: attempt) {
                try await Task.sleep(nanoseconds: backoffNanoseconds(attempt: attempt))
                return try await perform(urlRequest, attempt: attempt + 1)
            }
            throw error
        }

        cache?.set(data: data, forKey: cacheKey)

        do {
            return try decoder().decode(T.self, from: data)
        } catch {
            throw CDYelpNetworkError.decodingFailed(underlying: error)
        }
    }

    private func shouldRetry(error: CDYelpNetworkError, statusCode: Int?, attempt: UInt) -> Bool {
        guard attempt < retryConfig.retryLimit else { return false }
        if let code = statusCode {
            return retryConfig.retryableHTTPStatusCodes.contains(code)
        }
        if case .networkFailure(let underlying) = error,
           let urlError = underlying as? URLError {
            return [.networkConnectionLost, .notConnectedToInternet, .timedOut]
                .contains(urlError.code)
        }
        return false
    }

    private func backoffNanoseconds(attempt: UInt) -> UInt64 {
        let delay = retryConfig.initialDelay * pow(2.0, Double(attempt))
        return UInt64(delay * 1_000_000_000)
    }
}
```

#### `Source/Internal/CDYelpNativeRouter.swift`

Replaces `CDYelpRouter` (which currently conforms to Alamofire's `URLRequestConvertible`). The new router builds `URLRequest` using `URLComponents` and `URLQueryItem` — no Alamofire types.

The enum cases are identical to `CDYelpRouter`. Only the `asURLRequest()` implementation changes:

```swift
import Foundation

enum CDYelpNativeRouter {
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

    var path: String {
        // identical to CDYelpRouter.path — copy as-is
    }

    func asURLRequest(apiKey: String) throws -> URLRequest {
        guard var components = URLComponents(string: CDYelpURL.base + path) else {
            throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
        }

        let params = parameters
        if !params.isEmpty {
            components.queryItems = params.map {
                URLQueryItem(name: $0.key, value: String(describing: $0.value))
            }
        }

        guard let url = components.url else {
            throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private var parameters: [String: Any] {
        switch self {
        case let .search(p), let .phone(p), let .matches(p),
             let .autocomplete(p), let .events(p), let .featuredEvent(p),
             let .allCategories(p):
            return p
        case .transactions(_, let p), .business(_, let p),
             .reviews(_, let p), .event(_, let p), .categoryDetails(_, let p):
            return p
        }
    }
}
```

Note: `CDYelpRouter.swift` is deleted. `CDYelpNativeRouter.swift` takes its place. The `Parameters` typealias (from Alamofire) is replaced throughout with `[String: Any]` directly, or a local typealias `typealias CDYelpParameters = [String: Any]` in `Parameters+CDYelpFusionKit.swift`.

### Changes to Existing Files

#### `Source/CDYelpAPIClient.swift`

Replace the Alamofire `Session` with `CDYelpURLSession`. The lazy `manager` property becomes a `let` stored property initialized in `init`.

```swift
import Foundation

public final class CDYelpAPIClient: Sendable {  // full Sendable now, no @unchecked
    private let apiKey: String
    private let urlSession: CDYelpURLSession

    public init(
        apiKey: String,
        cacheConfiguration: CDYelpCacheConfiguration = .disabled,
        retryConfiguration: CDYelpRetryConfiguration = .disabled,
        decoderConfiguration: CDYelpDecoderConfiguration = .default,
        eventMonitors: [any CDYelpEventMonitor] = [],
        requestAdapters: [any CDYelpRequestAdapter] = []
    ) {
        precondition(!apiKey.isEmpty, "An apiKey is required to query the Yelp Fusion API.")
        self.apiKey = apiKey

        let cache = cacheConfiguration.ttl > 0
            ? CDYelpResponseCache(configuration: cacheConfiguration)
            : nil

        self.urlSession = CDYelpURLSession(
            session: URLSession.shared,
            decoder: { decoderConfiguration.makeDecoder() },
            cache: cache,
            monitors: eventMonitors,
            adapters: requestAdapters,
            retryConfig: retryConfiguration
        )
    }

    // Internal init for testing (CDYelpMockClientFactory)
    init(apiKey: String, session: URLSession, ...) { ... }
}
```

Each API method changes from:
```swift
manager
    .request(CDYelpRouter.search(parameters: parameters))
    .validate()
    .responseDecodable { ... }
```
to:
```swift
let router = CDYelpNativeRouter.search(parameters: parameters)
let urlRequest = try router.asURLRequest(apiKey: apiKey)
return try await urlSession.perform(urlRequest)
```

The completion-handler overloads are removed in v6. All callers use async/await. This is the second breaking change alongside the `AFError` → `CDYelpNetworkError` swap.

If completion-handler backward compatibility is required, wrap async methods with `Task { }` in a compatibility shim file — but the recommendation is to drop them and treat v6 as a clean async/await-only API.

#### `Source/CDYelpRouter.swift`

Delete this file. Replace with `Source/Internal/CDYelpNativeRouter.swift`.

#### `Source/Parameters+CDYelpFusionKit.swift`

Remove `import Alamofire`. Replace the `Parameters` typealias references with `[String: Any]` or add a local typealias at the top of the file:

```swift
typealias CDYelpParameters = [String: Any]
```

Update all function return types from `Parameters` to `CDYelpParameters` (or `[String: Any]`).

#### `Package.swift`

Remove the Alamofire dependency:

```swift
// Delete:
.package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.0")),

// Delete from target dependencies:
.product(name: "Alamofire", package: "Alamofire")
```

Remove `import Alamofire` from all three source files that currently import it:
- `Source/CDYelpAPIClient.swift`
- `Source/CDYelpRouter.swift` (deleted)
- `Source/Parameters+CDYelpFusionKit.swift`

#### `Source/Internal/CDYelpAlamofireEventMonitor.swift`

Delete this file. The `CDYelpURLSession` actor calls `CDYelpEventMonitor` methods directly — no bridge needed.

#### `Source/Internal/CDYelpAlamofireRequestAdapter.swift`

Delete this file. The `CDYelpURLSession` actor calls `CDYelpRequestAdapter.adapt(_:)` directly in a loop.

#### `CDYelpFusionKit.podspec`

Update `dependency` to remove Alamofire:

```ruby
# Delete:
s.dependency 'Alamofire', '~> 5.9'
```

Update `deployment_target` values to match the new minimums.

### How the v5 Test Suite Acts as the Contract

Every behavioral test written for v5 verifies a *what*, not a *how*:

| v5 Test | What it verifies | v6 implementation under test |
|---------|-----------------|------------------------------|
| `CDYelpResponseCacheTests` | TTL expiry, store/retrieve, clear | `CDYelpResponseCache` (unchanged) |
| `CDYelpRetryConfigurationTests` | Retry limit, backoff config | `CDYelpURLSession.shouldRetry` + `backoffNanoseconds` |
| `CDYelpDecoderConfigurationTests` | Key strategy applied | `CDYelpURLSession.perform` decode step |
| `CDYelpEventMonitorTests` | Monitor callbacks fire | `CDYelpURLSession` direct calls to monitors |
| `CDYelpAPIClientTests` | End-to-end response decode via mock | `CDYelpURLSession` + `CDYelpNativeRouter` |
| Model tests | JSON → struct decode | Unchanged — `Decodable` conformances are untouched |
| Router tests | URL path/parameter construction | Rewritten against `CDYelpNativeRouter` |

The router tests are the one group that needs updating: they test `CDYelpRouter.asURLRequest()` against Alamofire's `URLRequestConvertible`. In v6, update them to call `CDYelpNativeRouter.asURLRequest(apiKey:)` instead. The assertions (correct URL host, path, query parameters, HTTP method) are identical.

### v6 Completion Checklist

- [ ] Raise deployment targets in `Package.swift` and `CDYelpFusionKit.podspec`
- [ ] Create `Source/CDYelpNetworkError.swift`
- [ ] Create `Source/Internal/CDYelpURLSession.swift`
- [ ] Create `Source/Internal/CDYelpNativeRouter.swift`
- [ ] Update `Source/CDYelpAPIClient.swift` — remove Alamofire, use `CDYelpURLSession`
- [ ] Update `Source/Parameters+CDYelpFusionKit.swift` — remove `import Alamofire`, replace `Parameters`
- [ ] Delete `Source/CDYelpRouter.swift`
- [ ] Delete `Source/Internal/CDYelpAlamofireEventMonitor.swift`
- [ ] Delete `Source/Internal/CDYelpAlamofireRequestAdapter.swift`
- [ ] Update `Package.swift` — remove Alamofire dependency
- [ ] Update `CDYelpFusionKit.podspec` — remove Alamofire dependency
- [ ] Update router tests to use `CDYelpNativeRouter.asURLRequest(apiKey:)`
- [ ] Update any test or source file that references `AFError` to use `CDYelpNetworkError`
- [ ] Run `swift build` — must succeed with zero Alamofire imports
- [ ] Run `swift test` — all v5 behavioral tests must pass unchanged
- [ ] Run `swiftlint lint --strict` — no violations
- [ ] Run `swiftformat Source Tests --lint` — no violations
- [ ] Run `bundle exec pod lib lint --allow-warnings`
