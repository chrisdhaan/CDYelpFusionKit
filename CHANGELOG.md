# Changelog

All notable changes to this project will be documented in this file.
CDYelpFusionKit adheres to [Semantic Versioning](https://semver.org/).

## Table of Contents

- [5.0.0](#500---2026-06-03)
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

## [5.0.0] - 2026-06-03

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
