# CDYelpFusionKit

[![CI Status](http://img.shields.io/travis/chrisdhaan/CDYelpFusionKit.svg?style=flat)](https://travis-ci.org/chrisdhaan/CDYelpFusionKit)
[![Version](https://img.shields.io/cocoapods/v/CDYelpFusionKit.svg?style=flat)](http://cocoapods.org/pods/CDYelpFusionKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/CDYelpFusionKit.svg?style=flat)](http://cocoapods.org/pods/CDYelpFusionKit)
[![Platform](https://img.shields.io/cocoapods/p/CDYelpFusionKit.svg?style=flat)](http://cocoapods.org/pods/CDYelpFusionKit)

This Swift wrapper covers all possible network endpoints and responses for the Yelp Fusion Developers V3 API.

For a demonstration of the capabilities of CDYelpFusionKit; run the iOS Example project after cloning the repo.

---

## Pre-Release Software

This framework is currently in development. As of release 0.9.0 the code is stable and in a usable state to install in applications. But be aware that breaking changes may occur until 1.0.0 is released.

---

## Requirements

- iOS 8.0+
- Xcode 8.1+
- Swift 3.0+
- [Yelp API Access](https://www.yelp.com/developers/v3/manage_app)

---

## Installation

### Installation via CocoaPods

CDYelpFusionKit is available through [CocoaPods](http://cocoapods.org). CocoaPods is a dependency manager that automates and simplifies the process of using 3rd-party libraries like CDYelpFusionKit in your projects. You can install CocoaPods with the following command:

```ruby
gem install cocoapods
```

To integrate CDYelpFusionKit into your Xcode project using CocoaPods, simply add the following line to your Podfile:

```ruby
# use this line to install CDYelpFusionKit while in development
pod "CDYelpFusionKit", :git => "https://github.com/chrisdhaan/CDYelpFusionKit"
# this line will eventually be used upon the 1.0.0 release of CDYelpFusionKit and can be disregarded for now
pod "CDYelpFusionKit" "~> 1.0.0"
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
# use this line to install CDYelpFusionKit while in development
github "chrisdhaan/CDYelpFusionKit"
# this line will eventually be used upon the 1.0.0 release of CDYelpFusionKit and can be disregarded for now
github "chrisdhaan/CDYelpFusionKit" ~> 1.0.0
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
    .Package(url: "https://github.com/chrisdhaan/CDYelpFusionKit.git", majorVersion: 1)
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
let yelpAPIClient = CDYelpAPIClient(clientId: "YOUR_CLIENT_ID",
                                    clientSecret: "YOUR_CLIENT_SECRET")
```

Once you've created a CDYelpAPIClient object you can use it to query the Yelp Fusion API using any of the following methods.

- Parameters with "// Optional" can take nil as a value.
- Parameters with "// Required" will throw an exception when passing nil as a value.

### [Search API](https://www.yelp.com/developers/documentation/v3/business_search)

```swift
public func searchBusinesses(byTerm term: String?,                 // Optional
                             location: String?,                    // Optional
                             latitude: Double?,                    // Optional
                             longitude: Double?,                   // Optional
                             radius: Int?,                         // Optional - Max = 40000
                             categories: [String]?,                // Optional
                             locale: CDYelpLocale?,                // Optional
                             limit: Int?,                          // Optional - Default = 20, Max = 50
                             offset: Int?,                         // Optional
                             sortBy: CDYelpSortType?,              // Optional - Default = .bestMatch
                             price: [CDYelpPriceTier]?,            // Optional
                             openNow: Bool?,                       // Optional - Default = false
                             openAt: Int?,                         // Optional
                             attributes: [CDYelpAttributeFilter]?, // Optional
                             completion: @escaping (CDYelpSearchResponse?, Error?) -> Void);
```

The Search API has a `locale` parameter which allows for query results to be returned based off forty-two types of language and country codes. The following lines of code show which locales can be passed into the `locale` parameter.

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

The Search API has a `sortBy` parameter which allows for query results to be filtered based off four types of criteria. The following lines of code show which sort types can be passed into the `sortBy` parameter.

```swift
CDYelpSortType.bestMatch   // Default
CDYelpSortType.rating
CDYelpSortType.reviewCount
CDYelpSortType.distance
```

** Some parameters are currently not implemented** even though they can be passed into the `searchBusinesses` method. Those parameters are listed below:

- categories
- price
- attributes

The following lines of code show an example query to the Yelp Fusion Search API.

```swift
// Cancel any API requests previously made
yelpAPIClient.cancelAllPendingAPIRequests()
// Query Yelp Fusion API for business results
yelpAPIClient.searchBusinesses(byTerm: "Food",
                               location: "San Francisco",
                               latitude: nil,
                               longitude: nil,
                               radius: 10000,
                               categories: nil,
                               locale: .english_unitedStates,
                               limit: 5,
                               offset: 0,
                               sortBy: .rating,
                               price: nil,
                               openNow: true,
                               openAt: nil,
                               attributes: nil) { (response, error) in
            
  if let response = response,
      let businesses = response.businesses,
      businesses.count > 0 {
      print(businesses)
  }
}
```

### [Phone Search API](https://www.yelp.com/developers/documentation/v3/business_search_phone)

```swift
public func searchBusinesses(byPhoneNumber phoneNumber: String!,	// Required
                                 completion: @escaping (CDYelpSearchResponse?, Error?) -> Void)
```

The following lines of code show an example query to the Yelp Fusion Phone Search API.

```swift
yelpAPIClient.searchBusinesses(byPhoneNumber: "+14157492060") { (response, error) in
            
  if let response = response,
      let businesses = response.businesses,
      businesses.count > 0 {
      print(businesses)
  }
}
```

### [Transaction Search API](https://www.yelp.com/developers/documentation/v3/transactions_search)

```swift
public func searchTransactions(byType type: CDYelpTransactionType!, // Required
                              location: String?,                    // Optional
                              latitude: Double?,                    // Optional
                              longitude: Double?,                   // Optional
                              completion: @escaping (CDYelpSearchResponse?, Error?) -> Void)
```

The following lines of code show an example query to the Yelp Fusion Transaction Search API.

```swift
yelpAPIClient.searchTransactions(byType: .foodDelivery,
                                 location: "San Francisco",
                                 latitude: nil,
                                 longitude: nil) { (response, error) in
            
  if let response = response,
      let businesses = response.businesses,
      businesses.count > 0 {
      print(businesses)
  }
}
```

### [Business API](https://www.yelp.com/developers/documentation/v3/business)

```swift
public func fetchBusiness(byId id: String!, // Required
                          completion: @escaping (CDYelpBusiness?, Error?) -> Void)
```

The following lines of code show an example query to the Yelp Fusion Business API.

```swift
yelpAPIClient.fetchBusiness(byId: "north-india-restaurant-san-francisco") { (business, error) in
            
  if let business = business {
      print(business)
  }
}
```
### [Reviews API](https://www.yelp.com/developers/documentation/v3/business_reviews)

```swift
public func fetchReviews(forBusinessId id: String!, // Required
                         locale: CDYelpLocale?,     // Optional
                         completion: @escaping (CDYelpReviewsResponse?, Error?) -> Void)
```

The Reviews API has a `locale` parameter which allows for query results to be returned based off forty-two types of language and country codes. Refer to the [Search API](#search-api) for information regarding using the `locale` parameter.

The following lines of code show an example query to the Yelp Fusion Business API.

```swift
yelpAPIClient.fetchReviews(forBusinessId: "north-india-restaurant-san-francisco",
                           locale: nil) { (reviews, error) in
            
  if let response = response,
      let reviews = response.reviews,
      reviews.count > 0 {
      print(reviews)
  }
}
```

### [Autocomplete API](https://www.yelp.com/developers/documentation/v3/autocomplete)

```swift
public func autocompleteBusinesses(byText text: String!,  // Required
                                   latitude: Double!,     // Required
                                   longitude: Double!,    // Required
                                   locale: CDYelpLocale?, // Optional
                                   completion: @escaping (CDYelpAutoCompleteResponse?, Error?) -> Void)
```

The Autocomplete API has a `locale` parameter which allows for query results to be returned based off forty-two types of language and country codes. Refer to the [Search API](#search-api) for information regarding using the `locale` parameter.

The following lines of code show an example query to the Yelp Fusion Business API.

```swift
yelpAPIClient.autocompleteBusinesses(byText: "Pizza Hut",
                                     latitude: 37.786572,
                                     longitude: -122.415192,
                                     locale: nil) { (response, error) in
            
  if let response = response,
      let businesses = response.businesses,
      businesses.count > 0 {
      print(businesses)
  }
}
```

## Author

Christopher de Haan, contact@christopherdehaan.me

## Resources

Visit the [Yelp Developers](https://www.yelp.com/developers) portal for additional resources regarding the Yelp API.

## License

CDYelpFusionKit is available under the MIT license. See the LICENSE file for more info.

---
