<p align="center">
    <a href="https://github.com/chrisdhaan/CDYelpFusionKit">
        <img src="https://raw.githubusercontent.com/chrisdhaan/CDYelpFusionKit/master/Documentation/cdyelpfusionkit.png" alt="CDYelpFusionKit" width="850" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/chrisdhaan/CDYelpFusionKit">
        <img src="https://raw.githubusercontent.com/chrisdhaan/CDYelpFusionKit/master/Documentation/github.png" alt="Star CDYelpFusionKit On Github" />
    </a>
    <a href="http://stackoverflow.com/questions/tagged/cdyelpfusionkit">
        <img src="https://raw.githubusercontent.com/chrisdhaan/CDYelpFusionKit/master/Documentation/stackoverflow.png" alt="Stack Overflow" />
    </a>
</p>

<p align="center">
    <a href="https://travis-ci.org/chrisdhaan/CDYelpFusionKit">
        <img src="http://img.shields.io/travis/chrisdhaan/CDYelpFusionKit.svg?style=flat" alt="CI Status">
    </a>
    <a href="https://github.com/chrisdhaan/CDYelpFusionKit/releases">
        <img src="https://img.shields.io/github/release/chrisdhaan/CDYelpFusionKit.svg" alt="GitHub Release">
    </a>
    <a href="http://cocoapods.org/pods/CDYelpFusionKit">
        <img src="https://img.shields.io/cocoapods/v/CDYelpFusionKit.svg?style=flat" alt="Version">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible">
    </a>
    <a href="http://cocoapods.org/pods/CDYelpFusionKit">
        <img src="https://img.shields.io/cocoapods/p/CDYelpFusionKit.svg?style=flat" alt="Platform">
    </a>
    <a href="http://cocoapods.org/pods/CDYelpFusionKit">
        <img src="https://img.shields.io/cocoapods/l/CDYelpFusionKit.svg?style=flat" alt="License">
    </a>
</p>

<br>

This Swift wrapper covers all possible network endpoints and responses for the Yelp Fusion API.

For a demonstration of the capabilities of CDYelpFusionKit; run the iOS Example project after cloning the repo.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
    - [Initialization](#initialization)
    - [Search Endpoint](#search-endpoint)
    - [Phone Search Endpoint](#phone-search-endpoint)
    - [Transaction Search Endpoint](#transaction-search-endpoint)
    - [Business Endpoint](#business-endpoint)
    - [Business Match Endpoint](#business-match-endpoint)
    - [Reviews Endpoint](#reviews-endpoint)
    - [Autocomplete Endpoint](#autocomplete-endpoint)
    - [Event Lookup Endpoint](#event-lookup)
    - [Event Search Endpoint](#event-search-endpoint)
    - [Featured Event Endpoint](#featured-event-endpoint)
    - [Deep Linking](#deep-linking)
    - [Web Linking](#web-linking)
    - [Brand Assets](#brand-assets)
- [Resources](#resources)
- [License](#license)

---

## Features

- [x] Authentication
- [x] API Endpoints
    - [x] Search
    - [x] Phone Search
    - [x] Transaction Search
    - [x] Business
    - [x] Business Match
    - [x] Reviews
    - [x] Autocomplete
    - [x] Event Lookup
    - [x] Event Search
    - [x] Featured Event
- [x] Deep Linking
- [x] Web Linking
- [x] Brand Assets
    - [x] Color
    - [x] Logos
- [x] Platform Support
    - [x] iOS
    - [x] macOS
    - [x] tvOS
    - [x] watchOS
- [x] Documentation

---

## Requirements

- iOS 8.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.1+
- Swift 3.0+
- [Yelp API Access](https://www.yelp.com/developers/v3/manage_app)

---

## Dependencies

- [AlamofireObjectMapper](https://github.com/tristanhimmelman/AlamofireObjectMapper)
- [Alamofire](https://github.com/Alamofire/Alamofire)
- [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper)

---

## Installation

### Installation via CocoaPods

CDYelpFusionKit is available through [CocoaPods](http://cocoapods.org). CocoaPods is a dependency manager that automates and simplifies the process of using 3rd-party libraries like CDYelpFusionKit in your projects. You can install CocoaPods with the following command:

```ruby
gem install cocoapods
```

To integrate CDYelpFusionKit into your Xcode project using CocoaPods, simply add the following line to your Podfile:

```ruby
pod 'CDYelpFusionKit', '1.5.1'
```

Afterwards, run the following command:

```ruby
pod install
```

### Installation via Carthage

CDYelpFusionKit is available through [Carthage](https://github.com/Carthage/Carthage). Carthage is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage via [Homebrew](http://brew.sh) with the following commands:

```ruby
brew update
brew install carthage
```

To integrate CDYelpFusionKit into your Xcode project using Carthage, simply add the following line to your Cartfile:

```ruby
github "chrisdhaan/CDYelpFusionKit" == 1.5.1
```

Afterwards, run the following command:

```ruby
carthage update
```

Next, add the built CDYelpFusionKit.framework into your Xcode project.

### Installation via Swift Package Manager

CDYelpFusionKit is available through the [Swift Package Manager](https://swift.org/package-manager). The Swift Package Manager is a tool for automating the distribution of Swift code.

The Swift Package Manager is in early development, but CDYelpFusionKit does support its use on supported platforms. Until the Swift Package Manager supports non-host platforms, it is recommended to use CocoaPods, Carthage, or Git Submodules to build iOS, watchOS, and tvOS apps.

The Swift Package Manager is integrated into the Swift compiler.

To integrate CDYelpFusionKit into your Xcode project using The Swift Package Manager, simply add the following line to your Package.swift file:

```swift
dependencies: [
    .Package(url: "https://github.com/chrisdhaan/CDYelpFusionKit.git", "1.5.1")
]
```

Afterwards, run the following command:

```ruby
swift package fetch
```

### Installation via Git Submodule

CDYelpFusionKit is available through [Git Submodule](https://git-scm.com/docs/git-submodule) Git Submodule allows you to keep another Git repository in a subdirectory of your repository.

If your project is not initialized as a git repository, navigate into your top-level project directory, and install Git Submodule with the following command:

```git
git init
```

To integrate CDYelpFusionKit into your Xcode project using Git Submodule, simply run the following command:

```git
git submodule add https://github.com/chrisdhaan/CDYelpFusionKit.git
```

Afterwards, open the new **CDYelpFusionKit** folder, and drag the **CDYelpFusionKit.xcodeproj** into the **Project Navigator** of your Xcode project. A common location for the **CDYelpFusionKit.xcodeproj** is directly below the **Products** folder.

Next, select your application project in the **Project Navigator** to navigate to the target configuration window and select the application target under the **Targets** heading in the sidebar. In the tab bar at the top of that window, open the **General** panel. Click on the **+** button under the **Embedded Binaries** section. You will see two different CDYelpFusionKit.xcodeproj folders, each with a version of the CDYelpFusionKit.framework nested inside a Products folder. It does not matter which Products folder you choose from, select the CDYelpFusionKit.framework for iOS.

---

## Usage

### Initialization

```swift
let yelpAPIClient = CDYelpAPIClient(apiKey: "YOUR_API_KEY")
```

Once you've created a CDYelpAPIClient object you can use it to query the Yelp Fusion API using any of the following methods.

- Parameters with `// Optional` can take nil as a value.
- Parameters with `// Required` will throw an exception when passing nil as a value.

### [Search Endpoint](https://www.yelp.com/developers/documentation/v3/business_search)

```swift
public func searchBusinesses(byTerm term: String?,                        // Optional
                             location: String?,                           // Optional
                             latitude: Double?,                           // Optional
                             longitude: Double?,                          // Optional
                             radius: Int?,                                // Optional - Max = 40000
                             categories: [CDYelpBusinessCategoryFilter]?, // Optional
                             locale: CDYelpLocale?,                       // Optional
                             limit: Int?,                                 // Optional - Default = 20, Max = 50
                             offset: Int?,                                // Optional
                             sortBy: CDYelpBusinessSortType?,             // Optional - Default = .bestMatch
                             priceTiers: [CDYelpPriceTier]?,              // Optional
                             openNow: Bool?,                              // Optional - Default = false
                             openAt: Int?,                                // Optional
                             attributes: [CDYelpAttributeFilter]?,        // Optional
                             completion: @escaping (CDYelpSearchResponse?) -> Void);
```

The search endpoint has a `categories` parameter which allows for query results to be returned based off one thousand four hundred and sixty-one types of categories. The full list of categories can be found in `CDYelpEnums.swift`. The following lines of code show an example of a category that can be passed into the `categories` parameter.

```swift
CDYelpBusinessCategoryFilter.activeLife
```

The search endpoint has a `locale` parameter which allows for query results to be returned based off forty-two types of language and country codes. The following lines of code show which locales can be passed into the `locale` parameter.

```swift
CDYelpLocale.chinese_hongKong
CDYelpLocale.chinese_taiwan
CDYelpLocale.czech_czechRepublic
CDYelpLocale.danish_denmark
CDYelpLocale.dutch_belgium
CDYelpLocale.dutch_theNetherlands
CDYelpLocale.english_australia
CDYelpLocale.english_belgium
CDYelpLocale.english_canada
CDYelpLocale.english_hongKong
CDYelpLocale.english_malaysia
CDYelpLocale.english_newZealand
CDYelpLocale.english_philippines
CDYelpLocale.english_republicOfIreland
CDYelpLocale.english_singapore
CDYelpLocale.english_switzerland
CDYelpLocale.english_unitedKingdom
CDYelpLocale.english_unitedStates
CDYelpLocale.filipino_philippines
CDYelpLocale.finnish_finland
CDYelpLocale.french_belgium
CDYelpLocale.french_canada
CDYelpLocale.french_france
CDYelpLocale.french_switzerland
CDYelpLocale.german_austria
CDYelpLocale.german_germany
CDYelpLocale.german_switzerland
CDYelpLocale.italian_italy
CDYelpLocale.italian_switzerland
CDYelpLocale.japanese_japan
CDYelpLocale.malay_malaysia
CDYelpLocale.norwegian_norway
CDYelpLocale.polish_poland
CDYelpLocale.portuguese_brazil
CDYelpLocale.portuguese_portugal
CDYelpLocale.spanish_argentina
CDYelpLocale.spanish_chile
CDYelpLocale.spanish_mexico
CDYelpLocale.spanish_spain
CDYelpLocale.swedish_finland
CDYelpLocale.swedish_sweden
CDYelpLocale.turkish_turkey
```

The search endpoint has a `sortBy` parameter which allows for query results to be filtered based off four types of criteria. The following lines of code show which sort types can be passed into the `sortBy` parameter.

```swift
CDYelpBusinessSortType.bestMatch   // Default
CDYelpBusinessSortType.rating
CDYelpBusinessSortType.reviewCount
CDYelpBusinessSortType.distance
```

The search endpoint has a `price` parameter which allows for query results to be filtered based off four types of criteria. The following lines of code show which price tiers can be passed into the `priceTiers` parameter.

```swift
CDYelpPriceTier.oneDollarSign
CDYelpPriceTier.twoDollarSigns
CDYelpPriceTier.threeDollarSigns
CDYelpPriceTier.fourDollarSigns
```

The search endpoint has an `attributes` parameter which allows for query results to be filtered based off five types of criteria. The following lines of code show which attributes can be passed into the `attributes` parameter.

```swift
CDYelpAttributeFilter.hotAndNew
CDYelpAttributeFilter.requestAQuote
CDYelpAttributeFilter.waitlistReservation
CDYelpAttributeFilter.cashback
CDYelpAttributeFilter.deals
```

The following lines of code show an example query to the search endpoint.

```swift
// Cancel any API requests previously made
yelpAPIClient.cancelAllPendingAPIRequests()
// Query Yelp Fusion API for business results
yelpAPIClient.searchBusinesses(byTerm: "Food",
                               location: "San Francisco",
                               latitude: nil,
                               longitude: nil,
                               radius: 10000,
                               categories: [.activeLife, .food],
                               locale: .english_unitedStates,
                               limit: 5,
                               offset: 0,
                               sortBy: .rating,
                               priceTiers: [.oneDollarSign, .twoDollarSigns],
                               openNow: true,
                               openAt: nil,
                               attributes: nil) { (response) in

  if let response = response,
      let businesses = response.businesses,
      businesses.count > 0 {
      print(businesses)
  }
}
```

### [Phone Search Endpoint](https://www.yelp.com/developers/documentation/v3/business_search_phone)

```swift
public func searchBusinesses(byPhoneNumber phoneNumber: String!, // Required
                                 completion: @escaping (CDYelpSearchResponse?) -> Void)
```

The following lines of code show an example query to the phone search endpoint.

```swift
yelpAPIClient.searchBusinesses(byPhoneNumber: "+14157492060") { (response) in

  if let response = response,
      let businesses = response.businesses,
      businesses.count > 0 {
      print(businesses)
  }
}
```

### [Transaction Search Endpoint](https://www.yelp.com/developers/documentation/v3/transactions_search)

```swift
public func searchTransactions(byType type: CDYelpTransactionType!, // Required
                              location: String?,                    // Optional
                              latitude: Double?,                    // Optional
                              longitude: Double?,                   // Optional
                              completion: @escaping (CDYelpSearchResponse?) -> Void)
```

The transactions search endpoint has a `type` parameter which allows for query results to be filtered based off one type of criteria. The following lines of code show which transaction types can be passed into the `byType` parameter.

```swift
CDYelpTransactionType.foodDelivery
```

The following lines of code show an example query to the transactions search endpoint.

```swift
yelpAPIClient.searchTransactions(byType: .foodDelivery,
                                 location: "San Francisco",
                                 latitude: nil,
                                 longitude: nil) { (response) in

  if let response = response,
      let businesses = response.businesses,
      businesses.count > 0 {
      print(businesses)
  }
}
```

### [Business Endpoint](https://www.yelp.com/developers/documentation/v3/business)

```swift
public func fetchBusiness(forId id: String!,     // Required
                          locale: CDYelpLocale?, // Optional
                          completion: @escaping (CDYelpBusiness?) -> Void)
```

The following lines of code show an example query to the business endpoint.

```swift
yelpAPIClient.fetchBusiness(forId: "north-india-restaurant-san-francisco"
                            locale: nil) { (business) in

  if let business = business {
      print(business)
  }
}
```

### [Business Match Endpoint](https://www.yelp.com/developers/documentation/v3/business_match)

```swift
public func searchBusinesses(byMatchType type: CDYelpBusinessMatchType!, // Required
                             name: String!,                              // Required
                             addressOne: String?,                        // Optional
                             addressTwo: String?,                        // Optional
                             addressThree: String?,                      // Optional
                             city: String!,                              // Required
                             state: String!,                             // Required
                             country: String!,                           // Required
                             latitude: Double?,                          // Optional
                             longitude: Double?,                         // Optional
                             phone: String?,                             // Optional
                             postalCode: String?,                        // Optional
                             yelpBusinessId: String?,                    // Optional
                             completion: @escaping (CDYelpSearchResponse?) -> Void)
```

The business match endpoint has a `type` parameter which allows for query results to be filtered based off two types of criteria. The following lines of code show which business match types can be passed into the `byMatchType` parameter.

```swift
CDYelpBusinessMatchType.best
CDYelpBusinessMatchType.lookup
```

The following lines of code show an example query to the business match endpoint.

```swift
yelpAPIClient.searchBusinesses(byMatchType: .best,
                               name: "Yelp if you need HELP!",
                               addressOne: nil,
                               addressTwo: nil,
                               addressThree: nil,
                               city: "San Francisco",
                               state: "CA",
                               country: "US",
                               latitude: nil,
                               longitude: nil,
                               phone: nil,
                               postalCode: nil,
                               yelpBusinessId: nil) { (response) in

  if let response = response,
      let businesses = response.businesses,
      businesses.count > 0 {
      print(businesses)
  }
}
```

### [Reviews Endpoint](https://www.yelp.com/developers/documentation/v3/business_reviews)

```swift
public func fetchReviews(forBusinessId id: String!, // Required
                         locale: CDYelpLocale?,     // Optional
                         completion: @escaping (CDYelpReviewsResponse?) -> Void)
```

The reviews endpoint has a `locale` parameter which allows for query results to be returned based off forty-two types of language and country codes. Refer to the [search endpoint](#search-endpoint) for information regarding using the `locale` parameter.

The following lines of code show an example query to the reviews endpoint.

```swift
yelpAPIClient.fetchReviews(forBusinessId: "north-india-restaurant-san-francisco",
                           locale: nil) { (reviews) in

  if let response = response,
      let reviews = response.reviews,
      reviews.count > 0 {
      print(reviews)
  }
}
```

### [Autocomplete Endpoint](https://www.yelp.com/developers/documentation/v3/autocomplete)

```swift
public func autocompleteBusinesses(byText text: String!,  // Required
                                   latitude: Double!,     // Required
                                   longitude: Double!,    // Required
                                   locale: CDYelpLocale?, // Optional
                                   completion: @escaping (CDYelpAutoCompleteResponse?) -> Void)
```

The autocomplete endpoint has a `locale` parameter which allows for query results to be returned based off forty-two types of language and country codes. Refer to the [search endpoint](#search-endpoint) for information regarding using the `locale` parameter.

The following lines of code show an example query to the autocomplete endpoint.

```swift
yelpAPIClient.autocompleteBusinesses(byText: "Pizza Hut",
                                     latitude: 37.786572,
                                     longitude: -122.415192,
                                     locale: nil) { (response) in

  if let response = response,
      let businesses = response.businesses,
      businesses.count > 0 {
      print(businesses)
  }
}
```

### [Event Lookup Endpoint](https://www.yelp.com/developers/documentation/v3/event)

```swift
public func fetchEvent(forId id: String!,     // Required
                       locale: CDYelpLocale?, // Optional
                       completion: @escaping (CDYelpEvent?) -> Void)
```

The event lookup endpoint has a `locale` parameter which allows for query results to be returned based off forty-two types of language and country codes. Refer to the [search endpoint](#search-endpoint) for information regarding using the `locale` parameter.

The following lines of code show an example query to the event lookup endpoint.

```swift
yelpAPIClient.fetchEvent(forId: "city-of-san-francisco-san-francisco",
                         locale: nil) { (event) in

  if let event = event {
      print(event)
  }
}
```

### [Event Search Endpoint](https://www.yelp.com/developers/documentation/v3/event_search)

```swift
public func searchEvents(byLocale locale: CDYelpLocale?,           // Optional
                         offset: Int?,                             // Optional
                         limit: Int?,                              // Optional - Default = 3, Max = 50
                         sortBy: CDYelpEventSortByType?,           // Optional - Default = .descending
                         sortOn: CDYelpEventSortOnType?,           // Optional - Default = .popularity
                         categories: [CDYelpEventCategoryFilter]?, // Optional
                         startDate: Date?,                         // Optional
                         endDate: Date?,                           // Optional
                         isFree: Bool?,                            // Optional - Default = false
                         location: String?,                        // Optional
                         latitude: Double?,                        // Optional
                         longitude: Double?,                       // Optional
                         radius: Int?,                             // Optional - Max = 40000
                         excludedEvents: [String]?,                // Optional
                         completion: @escaping (CDYelpEventsResponse?) -> Void)
```

The event search endpoint has a `locale` parameter which allows for query results to be returned based off forty-two types of language and country codes. Refer to the [search endpoint](#search-endpoint) for information regarding using the `locale` parameter.

The event search endpoint has a `sortBy` parameter which allows for query results to be filtered based off two types of criteria. The following lines of code show which sort types can be passed into the `sortBy` parameter.

```swift
CDYelpEventSortByType.ascending
CDYelpEventSortByType.descending // Default
```

The event search endpoint has a `sortOn` parameter which allows for query results to be filtered based off two types of criteria. The following lines of code show which sort types can be passed into the `sortBy` parameter.

```swift
CDYelpEventSortOnType.popularity // Default
CDYelpEventSortOnType.timeStart
```

The event search endpoint has a `categories` parameter which allows for query results to be returned based off thirteen types of categories. The following lines of code show which category types can be passed into the `categories` parameter.

```swift
CDYelpEventCategoryFilter.charities
CDYelpEventCategoryFilter.fashion
CDYelpEventCategoryFilter.festivalsAndFairs
CDYelpEventCategoryFilter.film
CDYelpEventCategoryFilter.foodAndDrink
CDYelpEventCategoryFilter.kidsAndFamily
CDYelpEventCategoryFilter.lecturesAndBooks
CDYelpEventCategoryFilter.music
CDYelpEventCategoryFilter.nightlife
CDYelpEventCategoryFilter.other
CDYelpEventCategoryFilter.performingArts
CDYelpEventCategoryFilter.sportsAndActiveLife
CDYelpEventCategoryFilter.visualArts
```

The following lines of code show an example query to the event search endpoint.

```swift
yelpAPIClient.searchEvents(byLocale: nil,
                           offset: nil,
                           limit: 5,
                           sortBy: .descending,
                           sortOn: .popularity,
                           categories: [.music, .foodAndDrink],
                           startDate: nil,
                           endDate: nil,
                           isFree: false,
                           location: nil,
                           latitude: 37.786572,
                           longitude: -122.415192,
                           radius: 10000,
                           excludedEvents: nil) { (response) in

  if let response = response,
      let events = response.events,
      events.count > 0 {
      print(events)
  }
}
```

### [Featured Event Endpoint](https://www.yelp.com/developers/documentation/v3/featured_event)

```swift
public func fetchFeaturedEvent(forLocale locale: CDYelpLocale?, // Optional
                               location: String?,               // Optional
                               latitude: Double?,               // Optional
                               longitude: Double?,              // Optional
                               completion: @escaping (CDYelpEvent?) -> Void)
```

The featured event endpoint has a `locale` parameter which allows for query results to be returned based off forty-two types of language and country codes. Refer to the [search endpoint](#search-endpoint) for information regarding using the `locale` parameter.

The following lines of code show an example query to the featured event endpoint.

```swift
yelpAPIClient.fetchFeaturedEvent(forLocale: nil,
                                 location: nil,
                                 latitude: 37.786572,
                                 longitude: -122.415192) { (event) in

  if let event = event {
      print(event)
  }
}
```

### [Deep Linking](https://www.yelp.com/developers/documentation/v2/iphone)

The Yelp iPhone application registers URL schemes that can be used to open the Yelp application, perform searches, view business information, or check-in.

```swift
static func yelpDeepLink() -> URL?
```

The following lines of code show an example of how to check if the Yelp application is installed and then open it.

```swift
if let url = URL.yelpDeepLink(),
    UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url,
                              options: [:],
                              completionHandler: nil)
}
```

### [Search](https://www.yelp.com/developers/documentation/v2/iphone)

```swift
static func yelpSearchDeepLink(withTerm term: String?,                  // Optional
                               category: CDYelpBusinessCategoryFilter?, // Optional
                               location: String?) -> URL?               // Optional
```

The search deep link has a `category` parameter which allows for query results to be returned based off one thousand four hundred and sixty-one types of categories. Refer to the [search endpoint](#search-endpoint) for information regarding using the `category` parameter.

The following lines of code show an example query to the search deep link.

```swift
if let url = URL.yelpSearchDeepLink(withTerm: "burrito",
                                    category: .food,
                                    location: "San Francisco, CA"),
    UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url,
                              options: [:],
                              completionHandler: nil)
}
```

### [Business](https://www.yelp.com/developers/documentation/v2/iphone)

```swift
static func yelpBusinessDeepLink(forId id: String!) -> URL? // Required
```

The following lines of code show an example query to the business deep link.

```swift
if let url = URL.yelpBusinessDeepLink(forId: "the-sentinel-san-francisco"),
    UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url,
                              options: [:],
                              completionHandler: nil)
}
```

### [Check In Nearby](https://www.yelp.com/developers/documentation/v2/iphone)

```swift
static func yelpCheckInNearbyDeepLink() -> URL?
```

The following lines of code show an example query to the check in nearby deep link.

```swift
if let url = URL.yelpCheckInNearbyDeepLink(),
    UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url,
                              options: [:],
                              completionHandler: nil)
}
```

### [Check-Ins](https://www.yelp.com/developers/documentation/v2/iphone)

```swift
static func yelpCheckInsDeepLink() -> URL?
```

The following lines of code show an example query to the check-ins deep link.

```swift
if let url = URL.yelpCheckInsDeepLink(),
    UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url,
                              options: [:],
                              completionHandler: nil)
}
```

### [Check-In Rankings](https://www.yelp.com/developers/documentation/v2/iphone)

```swift
static func yelpCheckInRankingsDeepLink() -> URL?
```

The following lines of code show an example query to the check-in rankings deep link.

```swift
if let url = URL.yelpCheckInRankingsDeepLink(),
    UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url,
                              options: [:],
                              completionHandler: nil)
}
```

### [Web Linking](https://www.yelp.com/developers/documentation/v2/iphone)

The Yelp website registers URL schemes that can be used to open the Yelp website, perform searches or view business information.

```swift
static func yelpWebLink() -> URL?
```

The following lines of code show an example of how to open the Yelp website.

```swift
if let url = URL.yelpWebLink(),
    UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url,
                              options: [:],
                              completionHandler: nil)
}
```

### [Search](https://www.yelp.com/developers/documentation/v2/iphone)

```swift
static func yelpSearchWebLink(withTerm term: String?,                  // Optional
                              category: CDYelpBusinessCategoryFilter?, // Optional
                              location: String?) -> URL?               // Optional
```

The search deep link has a `category` parameter which allows for query results to be returned based off one thousand four hundred and sixty-one types of categories. Refer to the [search endpoint](#search-endpoint) for information regarding using the `category` parameter.

The following lines of code show an example query to the search web link.

```swift
if let url = URL.yelpSearchWebLink(withTerm: "burrito",
                                   category: .food,
                                   location: "San Francisco, CA"),
    UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url,
                              options: [:],
                              completionHandler: nil)
}
```

### [Business](https://www.yelp.com/developers/documentation/v2/iphone)

```swift
static func yelpBusinessWebLink(forId id: String!) -> URL? // Required
```

The following lines of code show an example query to the business web link.

```swift
if let url = URL.yelpBusinessWebLink(forId: "the-sentinel-san-francisco"),
    UIApplication.shared.canOpenURL(url) {
    UIApplication.shared.open(url,
                              options: [:],
                              completionHandler: nil)
}
```

### [Brand Assets](https://www.yelp.com/brand)

The Yelp brand guidelines exist to achieve consistency and make sure the branded elements of Yelp are used correctly across every application.

### [Color](https://www.yelp.com/brand)

```swift
class func yelpFiveStarRed() -> UIColor
```

The following lines of code show an example of how to use the brand color.

```swift
cell.textLabel?.textColor = UIColor.yelpFiveStarRed()
```

### [Logo](https://www.yelp.com/brand)

```swift
class func yelpLogo() -> UIImage?
class func yelpLogoOutline() -> UIImage?
class func yelpBurstLogoRed() -> UIImage?
class func yelpBurstLogoWhite() -> UIImage?
```

The following lines of code show examples of how to use the brand logo and the brand burst logo.

```swift
cell.imageView?.image = UIImage.yelpLogo()
cell.imageView?.image = UIImage.yelpLogoOutline()
cell.imageView?.image = UIImage.yelpBurstLogoRed()
cell.imageView?.image = UIImage.yelpBurstLogoWhite()
```

### [Stars](https://www.yelp.com/developers/display_requirements)

```swift
class func yelpStars(numberOfStars: CDYelpStars!,
                     forSize size: CDYelpStarsSize!) -> UIImage?
```

The stars image has a `numberOfStars` parameter which defines the number of filled stars in the returned image. The following lines of code show which number of stars can be passed into the `numberOfStars` parameter.

```swift
CDYelpStars.zero
CDYelpStars.one
CDYelpStars.oneHalf
CDYelpStars.two
CDYelpStars.twoHalf
CDYelpStars.three
CDYelpStars.threeHalf
CDYelpStars.four
CDYelpStars.fourHalf
CDYelpStars.five
```

The stars image has a `forSize` parameter which defines the size of the returned image. The following lines of code show which sizes can be passed into the `forSize` parameter.

```swift
CDYelpStarsSize.small
CDYelpStarsSize.regular
CDYelpStarsSize.large
CDYelpStarsSize.extraLarge
```

The following lines of code show an example of how to use the stars image.

```swift
cell.imageView?.image = UIImage.yelpStars(numberOfStars: .twoHalf, forSize: .large)
```

---

## Author

Christopher de Haan, contact@christopherdehaan.me

## Resources

Visit the [Yelp Developers](https://www.yelp.com/developers) portal for additional resources regarding the Yelp API.

## License

CDYelpFusionKit is available under the MIT license. See the LICENSE file for more info.

---
