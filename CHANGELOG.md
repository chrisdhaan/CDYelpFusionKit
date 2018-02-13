## [1.0.0](https://github.com/chrisdhaan/CDYelpFusionKit/releases/tag/1.0.0)
## Authentication and API Endpoints
Released on 2017-09-28.

### Added

- [x] Authentication
- [ ] API Endpoints
    - [x] Search
    - [x] Phone Search
    - [x] Transaction Search
    - [x] Business
    - [x] Reviews
    - [x] Autocomplete
- [x] Complete CDYelpCategoryFilter Mapping

---

## [1.1.0](https://github.com/chrisdhaan/CDYelpFusionKit/releases/tag/1.1.0)
## API Endpoints
Released on 2017-11-01.

### Added

- [ ] API Endpoints
    - [x] Business Match

### Changed

- [x] CDYelpAPIClient Completion Block Parameters
    - [x] `@escaping (CDYelpSearchResponse?, Error?)` becomes `@escaping (CDYelpSearchResponse?)`
    - [x] `@escaping (CDYelpBusiness?, Error?)` becomes `@escaping (CDYelpBusiness?)`
    - [x] `@escaping (CDYelpReviewsResponse?, Error?)` becomes `@escaping (CDYelpReviewsResponse?)`
    - [x] `@escaping (CDYelpAutoCompleteResponse?, Error?)` becomes `@escaping (CDYelpAutoCompleteResponse?)`

---

## [1.2.0](https://github.com/chrisdhaan/CDYelpFusionKit/releases/tag/1.2.0)
## API Endpoints, Deep Linking, and Brand Assets
Released on 2017-11-14.

### Added

- [x] API Endpoints
    - [x] Event Lookup
    - [x] Event Search
    - [x] Featured Event
- [x] Deep Linking
- [x] Brand Assets

### Changed

- [x] CDYelpEnums Naming
    - [x] `CDYelpCategoryFilter` becomes `CDYelpBusinessCategoryFilter`
    - [x] `CDSortType` becomes `CDYelpBusinessSortType`

---

## [1.3.0](https://github.com/chrisdhaan/CDYelpFusionKit/releases/tag/1.3.0)
## Platform Support, Web Linking, and Deep Linking
Released on 2017-11-16.

### Added

- [x] Platform Support
    - [x] macOS
    - [x] tvOS
    - [x] watchOS
- [x] Web Linking

### Changed

- [x] Deep Linking

---

## [1.4.0](https://github.com/chrisdhaan/CDYelpFusionKit/releases/tag/1.4.0)
## SDK Support
Released on 2017-11-20.

### Added

- [x] Swift 4.0

---

## [1.5.0](https://github.com/chrisdhaan/CDYelpFusionKit/releases/tag/1.5.0)
## Authentication
Released on 2018-02-12.

### Changed

- [x] Authentication
    - [x] `clientId and clientSecret` becomes `apiKey`
    - [x] Removes `CDYelpOAuthClient`, `CDYelpOAuthCredential`, and `CDYelpOAuthRouter` classes

---
