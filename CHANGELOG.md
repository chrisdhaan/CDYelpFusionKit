# Changelog

All notable changes to this project will be documented in this file.
CDYelpFusionKit adheres to [Semantic Versioning](https://semver.org/).

## Table of Contents

- [6.0.1](#601---2026-08-06)
- [6.0.0](#600---2026-07-24)
- [5.1.0](#510---2026-06-15)
- [5.0.0](#500---2026-06-07)
- [4.0.0](#400---2026-06-02)
- [3.2.0](#320---2022-08-02)
- [3.1.0](#310---2022-06-13)
- [3.0.1](#301---2021-09-17)
- [3.0.0](#300---2021-09-12)
- [2.1.1](#211---2021-05-30)
- [2.1.0](#210---2020-08-31)
- [2.0.0](#200---2020-08-30)
- [1.5.1](#151---2018-12-14)
- [1.5.0](#150---2018-02-12)
- [1.4.0](#140---2017-11-20)
- [1.3.0](#130---2017-11-16)
- [1.2.0](#120---2017-11-14)
- [1.1.0](#110---2017-11-01)
- [1.0.0](#100---2017-09-28)

---

## [6.0.1] - 2026-08-06

### Fixed

- `URL.yelpSearchWebLink`/`yelpSearchDeepLink` sent the wrong category slug when called without a search term — the Swift enum case name (e.g. `activeLife`) was interpolated instead of its Yelp API raw value (`active`)
- `URL.yelpSearchWebLink`/`yelpSearchDeepLink` produced a malformed URL when called with a `location` but no term — the category-only and location-only code paths didn't percent-encode `location`
- `CDYelpBusiness.PhoneSearch` and `CDYelpBusiness.TransactionSearch` silently dropped `display_address` and `cross_streets` from decoded responses — both used the plain `CDYelpLocation` type instead of `CDYelpLocation.Detailed`
- `DateFormatter.events`, `.reviews`, and `.specialHours` could fail to parse (or misparse) Yelp API date strings on devices set to a non-Gregorian-calendar locale — none of the three explicitly set `locale`
- The `Accept-Language` request header was computed once from `Locale.preferredLanguages` and cached for the lifetime of the process, so a device language change wasn't reflected until relaunch
- `Documentation/Usage.md`'s cache example showed `await client.clearCache()`; the method is synchronous
- `Documentation/ARCHITECTURE.md`'s `CDColor`/`CDImage` code samples referenced `UIColor`/`UIImage` types and signatures that don't exist in this framework; corrected to the actual `CDColor`/`CDImage` API
- `Documentation/ARCHITECTURE.md` and `Documentation/Usage.md` incorrectly claimed watchOS has no `UIImage` access; `CDImage` is a `UIImage` typealias on watchOS and the framework's star rating images render there normally
- `Documentation/ARCHITECTURE.md`'s Asset Catalog section referenced the wrong path (`Resources/Assets.xcassets` instead of `Resources/Images.xcassets`), an incorrect star image count (44 instead of 40), and a nonexistent colorset-based brand color setup

---

## [6.0.0] - 2026-07-24

### Added

- `CDYelpNetworkError` — native Swift error enum replacing `AFError` with four cases: `.invalidRequest(underlying:)`, `.networkFailure(underlying:)`, `.httpError(statusCode:data:headers:)`, `.decodingFailed(underlying:)`
- `CDYelpURLSession` — internal Swift actor managing the URLSession-based networking pipeline: adapter chain, cache, network dispatch, retry, and decode
- Retry backoff honors a server-provided `Retry-After` response header when present, instead of always using exponential backoff

### Updated

- **Alamofire removed** — CDYelpFusionKit is now dependency-free, using Apple's URLSession directly
- All 19 `CDYelpAPIClient` methods are now `async throws` only; completion-handler overloads removed
- Minimum deployment targets raised: iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0 (visionOS 1.0 unchanged)
- `CDYelpRouter` internal routing enum renamed from `CDYelpNativeRouter` for continuity with v5 naming; `asURLRequest()` now requires an explicit `apiKey:` parameter
- `CDYelpRetryConfiguration` default retry codes updated to `[408, 429, 500, 502, 503, 504]`
- `cancelAllPendingAPIRequests()` is now `async` — it suspends until in-flight tasks and retry backoff sleeps are actually cancelled, instead of returning before cancellation takes effect
- Requests include `User-Agent` and `Accept-Language` headers (matching Alamofire's previous default header behavior); any framework-set header a request adapter removes entirely is automatically restored
- `fetchAIChat` requires `latitude` and `longitude` to be provided together, or not at all — see the 6.0 migration guide

### Removed

- Completion-handler API — all `CDYelpAPIClient` methods previously had `completion:` variants; replaced by `async throws` exclusively
- `CDYelpAlamofireEventMonitor` and `CDYelpAlamofireRequestAdapter` internal Alamofire bridge types
- Alamofire SPM and CocoaPods dependency
- `isAuthenticated()` method — `init` already enforces a non-empty `apiKey` via `precondition`, so the check could never return `false`

---

## [5.1.0] - 2026-06-15

### Added

- `CDYelpTransactionType.pickup` and `CDYelpTransactionType.restaurantReservation` enum cases
- 10 new `CDYelpAttributeFilter` values: parking filters (`parkingGarage`, `parkingLot`, `parkingStreet`, `parkingValet`, `parkingBike`, `parkingValidated`) and dietary filters (`likedByVegetarians`, `veganOfferings`, `glutenFreeOfferings`, `outdoorSeating`)
- `CDYelpReviewSortType` enum with `yelpSort`, `rating`, and `timeCreated` cases
- `language: String?` field on `CDYelpReview`
- `fetchAIChat(query:chatId:latitude:longitude:requestContext:completion:)` — new `POST /ai/chat/v2` endpoint with multi-turn conversation support via `CDYelpAIChatRequest` / `CDYelpAIChatResponse`
- `fetchEngagementMetrics(forBusinessIds:dateRangeStart:dateRangeEnd:completion:)` — new `GET /v3/businesses/engagement` endpoint via `CDYelpEngagementResponse`
- `fetchServiceOfferings(forBusinessId:locale:completion:)` — new `GET /v3/businesses/{id}/service_offerings` endpoint via `CDYelpServiceOfferingsResponse`
- `fetchBusinessInsights(forBusinessIds:dateRangeStart:dateRangeEnd:completion:)` — new `GET /v3/businesses/insights` endpoint via `CDYelpBusinessInsightsResponse`
- `fetchReviewHighlights(forBusinessId:count:locale:devicePlatform:completion:)` — new `GET /v3/businesses/{id}/review_highlights` endpoint via `CDYelpReviewHighlightsResponse`
- `fetchJobs(forQuery:locale:completion:)` — new `POST /v3/jobs` home services endpoint via `CDYelpJobsResponse`
- `fetchOpenings(forBusinessId:covers:date:time:getCoversRange:completion:)` — new `GET /v3/bookings/{id}/openings` reservations endpoint via `CDYelpOpeningsResponse`
- Async/await overloads for all 7 new endpoints
- 48 new unit tests covering new router cases and response model decoding (193 total, up from 145)

### Updated

- `searchBusinesses(byTerm:...)` — added `devicePlatform`, `reservationDate`, `reservationTime`, `reservationCovers`, `matchesPartySize`, `jobAlias` parameters
- `searchBusinesses(byPhoneNumber:...)` — added `locale` parameter
- `fetchBusiness(forId:...)` — added `devicePlatform` parameter
- `searchTransactions(byType:...)` — added `term`, `categories`, `priceTiers` parameters
- `fetchReviews(forBusinessId:...)` — added `offset`, `limit`, `sortBy` parameters
- `.swiftlint.yml` file length thresholds raised to accommodate growth in `CDYelpAPIClient.swift`

---

## [5.0.0] - 2026-06-07

### Added

- `CDYelpEventMonitor` protocol for observing request/response lifecycle events (requestDidStart, requestDidComplete, requestWillRetry)
- `CDYelpRequestAdapter` protocol for mutating `URLRequest` before dispatch (e.g. header injection, signing)
- `CDYelpCacheConfiguration` struct for opt-in in-memory response caching with configurable TTL, count limit, and cost limit
- `CDYelpRetryConfiguration` struct for automatic retry with exponential backoff and configurable retryable HTTP status codes
- `CDYelpDecoderConfiguration` struct for customizing `JSONDecoder` key decoding and date decoding strategies
- `CDYelpMockURLProtocol` URLProtocol subclass for intercepting and stubbing network requests in tests
- `CDYelpMockClientFactory` factory for creating `CDYelpAPIClient` instances backed by `CDYelpMockURLProtocol`
- `clearCache()` method on `CDYelpAPIClient` for programmatic cache invalidation
- `Source/Internal/` subdirectory containing Alamofire bridge types (`CDYelpAlamofireEventMonitor`, `CDYelpAlamofireRequestAdapter`) and cache internals (`CDYelpResponseCache`, `CDYelpCacheKey`)
- `Source/Testing/` subdirectory containing `CDYelpMockURLProtocol` and `CDYelpMockClientFactory` (available in the `CDYelpFusionKitTesting` product)
- JSON test fixtures for business search, business detail, and reviews responses
- 4 new integration tests in `CDYelpAPIClientTests` covering decode, error handling, cache end-to-end, and event monitor bridge

### Updated

- `CDYelpAPIClient.init` accepts five new opt-in parameters: `cacheConfiguration`, `retryConfiguration`, `decoderConfiguration`, `eventMonitors`, `requestAdapters` — all have sensible defaults so existing `CDYelpAPIClient(apiKey:)` call sites are unaffected
- `Alamofire.Session` is now created eagerly in `init` via a static `makeSession` helper (previously a `lazy var`) to honour the `@unchecked Sendable` thread-safety contract
- `Package.swift` test target includes `Fixtures` resource bundle
- `.swiftlint.yml` disables `trailing_comma` rule (conflicts with SwiftFormat's `trailingCommas` rule)

### Fixed

- `CDYelpReview.timeCreatedAsDate()` now uses the correct `"yyyy-MM-dd HH:mm:ss"` format (was always returning nil)
- `CDYelpSpecialHour.dateAsDate()` now uses the correct `"yyyy-MM-dd"` format (was always returning nil)

---

## [4.0.0] - 2026-06-02

### Added

- Async/await overloads for all 12 Yelp Fusion API methods (iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+)
- Unit test target with model deserialization and router tests (Swift Testing framework)
- Privacy manifest (PrivacyInfo.xcprivacy) for App Store compliance
- CLAUDE.md project documentation for Claude Code users
- Documentation/Usage.md comprehensive usage guide
- Documentation/ARCHITECTURE.md technical architecture documentation
- Documentation/CDYelpFusionKit 4.0 Migration Guide.md for version migration
- Dynamic library product (CDYelpFusionKitDynamic) for SPM consumers
- SwiftLint CI job for code quality enforcement
- SwiftFormat CI job for automated formatting enforcement
- CodeQL security scanning in CI pipeline
- visionOS platform support (visionOS 1.0+)
- DocC API documentation bundle and GitHub Pages publication
- Documentation/API_SCHEMA.md documenting all Yelp Fusion endpoints
- .swiftformat configuration with project-specific overrides

### Updated

- swift-tools-version from 5.6 to 6.0
- Minimum deployment targets: iOS 12.0, macOS 11.0, tvOS 12.0, watchOS 4.0
- Alamofire dependency from 5.6.1 to 5.9.0+
- CI runners to macOS-15 and macos-26 with Xcode 16.4 and 26.x
- CI output formatter from xcpretty to xcbeautify
- CocoaPods CI to use bundle exec with Gemfile-managed versions
- GitHub Actions checkout from v3 to v4
- GitHub Actions cache from v3 to v4
- Copyright headers to 2016-2026
- CDYelpAPIClient removed NSObject inheritance (plain Swift class)
- apiKey parameter from implicitly-unwrapped String! to non-optional String
- Removed Carthage support; SPM and CocoaPods only
- Platform conditional imports from #if !os(OSX) to #if os(macOS)

### Fixed

- apiKey parameter validation from assert to precondition for production safety
- Print-based error logging removed from library code (no console output from SDK)
- Example app modernization (removed deprecated UIApplication.openURL patterns)
- Example app adopted UIScene lifecycle to resolve pending assert warning
- Example app API key sourced from Secrets.xcconfig via Info.plist instead of hardcoded placeholder

---

## [3.2.0] - 2022-08-02

### Added

- CDYelpBusiness.BusinessSearch, CDYelpBusiness.PhoneSearch, CDYelpBusiness.TransactionSearch, CDYelpBusiness.Detailed, CDYelpBusiness.BusinessMatch, and CDYelpBusiness.Autocomplete structs
- CDYelpCategoriesResponse.error property
- CDYelpCategory.Detailed struct
- CDYelpCategoryResponse.error property
- CDYelpEventResponse struct
- CDYelpLocation.Detailed struct
- CDYelpMessaging struct
- CDYelpSearchResponse.Business, CDYelpSearchResponse.Phone, CDYelpSearchResponse.Transaction, and CDYelpSearchResponse.BusinessMatch structs
- CDYelpSpecialHour struct
- toDate methods for String representations
- toUrl methods for String representations

### Updated

- CDYelpSearchResponse completion block from @escaping (CDYelpSearchResponse?) to typed variants (Business, Phone, Transaction, BusinessMatch)
- CDYelpBusiness completion block from @escaping (CDYelpBusiness?) to @escaping (CDYelpBusinessResponse?)
- CDYelpEvent completion block from @escaping (CDYelpEvent?) to @escaping (CDYelpEventResponse?)
- CDYelpAutocompleteResponse.businesses type to [CDYelpBusiness.Autocomplete]
- CDYelpBusinessResponse.business type to CDYelpBusiness.Detailed
- CDYelpCategoriesResponse.categories type to [CDYelpCategory.Detailed]
- CDYelpCategoryResponse.category type to CDYelpCategory.Detailed
- Date types to String throughout models
- URL types to String throughout models

### Fixed

- Removed CDYelpAttributeFilter.cashback, CDYelpTransactionType.pickup, and CDYelpTransactionType.restaurantReservation enums

---

## [3.1.0] - 2022-06-13

### Added

- Swift 5.4 support
- Swift 5.5 support
- Swift 5.6 support

### Updated

- Swift Package Manager minimum Swift version to 5.3
- Alamofire dependency
- CI test device, platform, Xcode, and SDK versions

---

## [3.0.1] - 2021-09-17

### Added

- macOS 5.1 CI test
- macOS 5.2 CI test
- Swift Package Manager CI test

### Updated

- Swift Package Manager configuration

---

## [3.0.0] - 2021-09-12

### Added

- validate method to API methods

### Updated

- Client responseObject model transformation to responseDecodable
- All models from class to struct
- All model properties from var to let
- Decodable and Encodable API conformance
- Alamofire dependency
- Swift Package Manager configuration

### Fixed

- Removed ObjectMapper dependency
- Removed Travis CI configuration

---

## [2.1.1] - 2021-05-30

### Updated

- Model URL types to String
- Model Date types to String
- Swift Package Manager to build with swift-tools-version:5.1

---

## [2.1.0] - 2020-08-31

### Added

- Swift 5.1 support

---

## [2.0.0] - 2020-08-30

### Added

- Swift 5.0 support
- All Categories API endpoint
- Category Details API endpoint

### Updated

- Business Match API endpoint
- CDYelpEnums naming: CDYelpBusinessCategoryFilter becomes CDYelpCategoryAlias

---

## [1.5.1] - 2018-12-14

### Added

- Swift 4.2 support
- SwiftLint integration

### Updated

- macOS platform support: CDImage+CDYelpFusionKit cdImage(named:) to initialize with CDImage.Name type

---

## [1.5.0] - 2018-02-12

### Updated

- Authentication: clientId and clientSecret becomes apiKey
- Removed CDYelpOAuthClient, CDYelpOAuthCredential, and CDYelpOAuthRouter classes

---

## [1.4.0] - 2017-11-20

### Added

- Swift 4.0 support

---

## [1.3.0] - 2017-11-16

### Added

- macOS platform support
- tvOS platform support
- watchOS platform support
- Web Linking support

### Updated

- Deep Linking implementation

---

## [1.2.0] - 2017-11-14

### Added

- Event Lookup API endpoint
- Event Search API endpoint
- Featured Event API endpoint
- Deep Linking support
- Brand Assets (Yelp colors and imagery)

### Updated

- CDYelpEnums naming: CDYelpCategoryFilter becomes CDYelpBusinessCategoryFilter
- CDYelpEnums naming: CDSortType becomes CDYelpBusinessSortType

---

## [1.1.0] - 2017-11-01

### Added

- Business Match API endpoint

### Updated

- CDYelpAPIClient completion block parameters from @escaping (CDYelpSearchResponse?, Error?) to @escaping (CDYelpSearchResponse?)
- CDYelpAPIClient completion block parameters from @escaping (CDYelpBusiness?, Error?) to @escaping (CDYelpBusiness?)
- CDYelpAPIClient completion block parameters from @escaping (CDYelpReviewsResponse?, Error?) to @escaping (CDYelpReviewsResponse?)
- CDYelpAPIClient completion block parameters from @escaping (CDYelpAutoCompleteResponse?, Error?) to @escaping (CDYelpAutoCompleteResponse?)

---

## [1.0.0] - 2017-09-28

### Added

- Authentication with API key
- Search API endpoint
- Phone Search API endpoint
- Transaction Search API endpoint
- Business Details API endpoint
- Reviews API endpoint
- Autocomplete API endpoint
- Complete CDYelpCategoryFilter mapping

---
