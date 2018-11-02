//
//  CDYelpAPIClient.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/7/16.
//
//  Copyright © 2016-2018 Christopher de Haan <contact@christopherdehaan.me>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Alamofire
import AlamofireObjectMapper

public class CDYelpAPIClient: NSObject {

    private let apiKey: String!
    private lazy var manager: Alamofire.SessionManager = {
        if let apiKey = self.apiKey,
            apiKey != "" {
            // Get the default headers
            var headers = Alamofire.SessionManager.defaultHTTPHeaders
            // Add the Authorization header
            headers["Authorization"] = "Bearer \(apiKey)"
            // Create a custom session configuration
            let configuration = URLSessionConfiguration.default
            // Add the Authorization header
            configuration.httpAdditionalHeaders = headers
            // Create a session manager with the custom configuration
            return Alamofire.SessionManager(configuration: configuration)
        } else {
            return Alamofire.SessionManager()
        }
    }()

    // MARK: - Initializers

    ///
    /// Initializes a new CDYelpAPIClient object.
    ///
    /// - parameters:
    ///   - apiKey: (**Required**) A unique key for the Yelp application used for authenticating with the Yelp Fusion API. **Do not share this key**.
    ///
    /// - returns: Void
    ///
    public init(apiKey: String!) {
        assert((apiKey != nil && apiKey != ""), "An apiKey is required to query the Yelp Fusion API.")
        self.apiKey = apiKey
        super.init()
    }

    // MARK: - Authentication Methods

    ///
    /// Determines whether or not the Yelp application has successfully authenticated with the Yelp Fusion API.
    ///
    /// - returns: Bool
    ///
    public func isAuthenticated() -> Bool {
        if self.apiKey != nil,
            self.apiKey != "" {
            return true
        }
        return false
    }

    // MARK: - Yelp Fusion API Methods

    ///
    /// This endpoint returns up to 1000 businesses based on the provided search criteria. It has basic information about each business. To get detailed information or reviews, use a returned business id and refer to **fetchBusiness(byId: )** and **fetchReviews(forBusinessId: )**.
    ///
    /// - parameters:
    ///   - byTerm: (Optional) A search term for the Yelp Fusion API to query. (e.g. "food", "restaurants"). If `byTerm` isn’t included all data will be searched. The `byTerm` keyword also accepts business names (e.g. "Starbucks").
    ///   - location: (**Required**) Can be (Optional) if either latitude or longitude is provided. Specifies the combination of "address, neighborhood, city, state or zip, optional country" to be used when querying the Yelp Fusion API for businesses.
    ///   - latitude: (**Required**) Can be (Optional) if location is provided. The latitude of the location the Yelp Fusion API should search nearby.
    ///   - longitude: (**Required**) Can be (Optional) if location is provided. The longitude of the location the Yelp Fusion API should search nearby.
    ///   - radius: (Optional) The search radius in meters. If the value is too large, an AREA_TOO_LARGE error may be returned. **The maximum value is 40,000 meters (25 miles)**.
    ///   - categories: (Optional) The categorie(s) to filter the search results with. Use the **CDYelpBusinessCategoryFilter** enum to get the list of supported categories. `categories` can be an array of categories (e.g. [.bars, .parks] will filter the results to show businesses that are listed as Bars or Parks).
    ///   - locale: (Optional) Specifies the locale to return the business information in. Use the **CDYelpLocale** enum to get the list of supported locales.
    ///   - limit: (Optional) The number of business results to return. By default, the value is set to 20. **The maximum value is 50**.
    ///   - offset: (Optional) A number the list of returned business results should be offset by.
    ///   - sortBy: (Optional) The sort mode that will be used on the returned business results. Use the **CDYelpBusinessSortType** enum to get the list of supported sort types. By default sortBy is set to `.bestMatch`. The `.rating` sort is not strictly sorted by the rating value, but by an adjusted rating value that takes into account the number of ratings, similar to a bayesian average. This is so a business with 1 rating of 5 stars doesn’t immediately jump to the top.
    ///   - price: (Optional) The pricing levels to filter the search result with. Use the **CDYelpPriceTier** enum to get the list of supported pricing levels. `price` can be an array of pricing levels (e.g. [.oneDollarSign, .twoDollarSigns, .threeDollarSigns] will filter the results to show businesses that are listed as $, $$, or $$$).
    ///   - openNow: (Optional) When set to true, only businesses open at the current time will be returned. The default value is false. **Notice that open_at and open_now cannot be used together**.
    ///   - openAt: (Optional) An integer representing the Unix time in the same timezone of the search location. If specified, only businesses open at the given time will be returned. **Notice that open_at and open_now cannot be used together**.
    ///   - attributes: (Optional) Additional filters to restrict search results. Use the **CDYelpAttributeFilter** enum to get the list of supported attribute filters. `attributes` can be an array of attributes. If multiple attributes are used, only businesses that satisfy ALL attributes will be returned in search results (e.g. the attributes [.hotAndNew, .cashback] will return businesses that are Hot and New AND offer Cash Back).
    ///   - completion: A completion block in which the Yelp Fusion API search endpoint response can be parsed.
    ///
    /// - returns: (CDYelpSearchResponse?) -> Void
    ///
    public func searchBusinesses(byTerm term: String?,
                                 location: String?,
                                 latitude: Double?,
                                 longitude: Double?,
                                 radius: Int?,
                                 categories: [CDYelpBusinessCategoryFilter]?,
                                 locale: CDYelpLocale?,
                                 limit: Int?,
                                 offset: Int?,
                                 sortBy: CDYelpBusinessSortType?,
                                 priceTiers: [CDYelpPriceTier]?,
                                 openNow: Bool?,
                                 openAt: Int?,
                                 attributes: [CDYelpAttributeFilter]?,
                                 completion: @escaping (CDYelpSearchResponse?) -> Void) {
        assert((latitude != nil && longitude != nil) ||
            (location != nil && location != ""), "Either a latitude and longitude or a location are required to query the Yelp Fusion API search endpoint.")
        if let radius = radius {
            assert((radius <= 40000), "The radius must be 40,000 meters or less to query the Yelp Fusion API search endpoint.")
        }
        if let limit = limit {
            assert((limit <= 50), "The limit must be 50 or less to query the Yelp Fusion API search endpoint.")
        }

        if self.isAuthenticated() == true {

            let params = Parameters.searchParameters(withTerm: term,
                                                     location: location,
                                                     latitude: latitude,
                                                     longitude: longitude,
                                                     radius: radius,
                                                     categories: categories,
                                                     locale: locale,
                                                     limit: limit,
                                                     offset: offset,
                                                     sortBy: sortBy,
                                                     priceTiers: priceTiers,
                                                     openNow: openNow,
                                                     openAt: openAt,
                                                     attributes: attributes)

            self.manager.request(CDYelpRouter.search(parameters: params)).responseObject { (response: DataResponse<CDYelpSearchResponse>) in

                switch response.result {
                case .success(let searchResponse):
                    if let error = searchResponse.error {
                        print("searchBusinesses(byTerm) error: ", error.description ?? "")
                    }
                    completion(searchResponse)
                case .failure(let error):
                    print("searchBusinesses(byTerm) failure: ", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    ///
    /// This endpoint returns a list of businesses based on the provided phone number. It is possible for more than one businesses having the same phone number (for example, chain stores with the same +1 800 phone number). At this time, this endpoint does not return businesses without any reviews.
    ///
    /// - parameters:
    ///   - byPhoneNumber: (**Required**) The phone number of the business for the Yelp Fusion API to query. It must start with + and include the country code, (e.g. "+14159083801").
    ///   - completion: A completion block in which the Yelp Fusion API phone search endpoint response can be parsed.
    ///
    /// - returns: (CDYelpSearchResponse?) -> Void
    ///
    public func searchBusinesses(byPhoneNumber phoneNumber: String!,
                                 completion: @escaping (CDYelpSearchResponse?) -> Void) {
        assert((phoneNumber != nil && phoneNumber != ""), "A business phone number is required to query the Yelp Fusion API phone endpoint.")

        if self.isAuthenticated() == true {

            let params = Parameters.phoneParameters(withPhoneNumber: phoneNumber)

            self.manager.request(CDYelpRouter.phone(parameters: params)).responseObject { (response: DataResponse<CDYelpSearchResponse>) in

                switch response.result {
                case .success(let searchResponse):
                    if let error = searchResponse.error {
                        print("searchBusinesses(byPhone) error: ", error.description ?? "")
                    }
                    completion(searchResponse)
                case .failure(let error):
                    print("searchBusinesses(byPhone) failure: ", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    ///
    /// This endpoint returns a list of businesses which support certain transactions. At this time, this endpoint does not return businesses without any reviews. Currently, this endpoint only supports food delivery in the US.
    ///
    /// - parameters:
    ///   - byType: (**Required**) A transaction type for the Yelp Fusion API to query.
    ///   - latitude: (**Required when location isn't provided**) The latitude of the location you want delivery from.
    ///   - longitude: (**Required when location isn't provided**) The longitude of the location you want delivery from.
    ///   - location: (**Required when latitude and longitude aren't provided**) The address of the location you want delivery from.
    ///   - completion: A completion block in which the Yelp Fusion API transactions endpoint response can be parsed.
    ///
    /// - returns: (CDYelpSearchResponse?) -> Void
    ///
    public func searchTransactions(byType type: CDYelpTransactionType!,
                                   location: String?,
                                   latitude: Double?,
                                   longitude: Double?,
                                   completion: @escaping (CDYelpSearchResponse?) -> Void) {
        assert(type != nil, "A transaction type is required to query the Yelp Fusion API transactions endpoint.")
        assert((latitude != nil && longitude != nil) ||
            (location != nil && location != ""), "Either a latitude and longitude or a location are required to query the Yelp Fusion API transactions endpoint.")

        if self.isAuthenticated() == true {

            let params = Parameters.transactionsParameters(withLocation: location,
                                                           latitude: latitude,
                                                           longitude: longitude)

            self.manager.request(CDYelpRouter.transactions(type: type.rawValue, parameters: params)).responseObject { (response: DataResponse<CDYelpSearchResponse>) in

                switch response.result {
                case .success(let searchResponse):
                    if let error = searchResponse.error {
                        print("searchTransactions(byType) error: ", error.description ?? "")
                    }
                    completion(searchResponse)
                case .failure(let error):
                    print("searchTransactions(byType) failure: ", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    ///
    /// This endpoint returns the detail information of a business. To get a business id, refer to **searchBusinesses(byTerm: )**, **searchBusinesses(byPhoneNumber: )**, **searchTransactions(byType: )**, **searchBusinesses(byMatchType: )** or **autocompleteBusinesses(byText: )**. To get review information for a business, refer to **fetchReviews(forBusinessId: )**. At this time, this endpoint does not return businesses without any reviews.
    ///
    /// - parameters:
    ///   - byId: (**Required**) The identifier of the business for the Yelp Fusion API to query.
    ///   - completion: A completion block in which the Yelp Fusion API business endpoint response can be parsed.
    ///
    /// - returns: (CDYelpBusiness?) -> Void
    ///
    public func fetchBusiness(forId id: String!,
                              locale: CDYelpLocale?,
                              completion: @escaping (CDYelpBusiness?) -> Void) {
        assert((id != nil && id != ""), "A business id is required to query the Yelp Fusion API business endpoint.")

        if self.isAuthenticated() == true {

            let params = Parameters.businessParameters(withLocale: locale)

            self.manager.request(CDYelpRouter.business(id: id, parameters: params)).responseObject { (response: DataResponse<CDYelpBusiness>) in

                switch response.result {
                case .success(let business):
                    completion(business)
                case .failure(let error):
                    print("fetchBusiness(byId) failure: ", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    ///
    /// This endpoints lets you match business data from other sources against Yelps businesses based on some minimal information provided. Best match will only return 1 business that is the best match based on the information provided. Lookup will return up to 10 businesses that is the best match based on the information provided. At this time, the API does not return businesses without any reviews.
    ///
    /// - parameters:
    ///   - byMatchType: (**Required**) A business match type for the Yelp Fusion API to query.
    ///   - name: (**Required**) The name of the business. Maximum length is 64; only digits, letters, spaces, and !#$%&+,­./:?@'are allowed
    ///   - addressOne: (Optional) The first line of the business’s address. Maximum length is 64; only digits, letters, spaces, and ­’/#&,.: are allowed.
    ///   - addressTwo: (Optional) The second line of the business’s address. Maximum length is 64; only digits, letters, spaces, and ­’/#&,.: are allowed.
    ///   - addressThree: (Optional) The third line of the business’s address. Maximum length is 64; only digits, letters, spaces, and ­’/#&,.: are allowed.
    ///   - city: (**Required**) The city of the business. Maximum length is 64; only digits, letters, spaces, and ­’.() are allowed.
    ///   - state: (**Required**) The ISO 3166-2 (with a few exceptions) state code of this business. Maximum length is 3.
    ///   - country: (**Required**) The ISO 3166-1 alpha-2 country code of this business. Maximum length is 2.
    ///   - latitude: (Optional) The WGS84 latitude of the business in decimal degrees. Must be between ­-90 and +90.
    ///   - longitude: (Optional) The WGS84 longitude of the business in decimal degrees. Must be between ­-180 and +180.
    ///   - phone: (Optional) The phone number of the business which can be submitted as (a) locally ­formatted with digits only (e.g., 016703080) or (b) internationally­ formatted with a leading + sign and digits only after (+35316703080). Maximum length is 32.
    ///   - postalCode: (Optional) The postal code of the business. Maximum length is 12.
    ///   - yelpBusinessId: (Optional) Unique Yelp identifier of the business if available. Used as a hint when finding a matching business.
    ///   - completion: A completion block in which the Yelp Fusion API business match endpoint response can be parsed.
    ///
    /// - returns: (CDYelpSearchResponse?) -> Void
    ///
    public func searchBusinesses(byMatchType type: CDYelpBusinessMatchType!,
                                 name: String!,
                                 addressOne: String?,
                                 addressTwo: String?,
                                 addressThree: String?,
                                 city: String!,
                                 state: String!,
                                 country: String!,
                                 latitude: Double?,
                                 longitude: Double?,
                                 phone: String?,
                                 postalCode: String?,
                                 yelpBusinessId: String?,
                                 completion: @escaping (CDYelpSearchResponse?) -> Void) {
        assert(type != nil, "A business match type is required to query the Yelp Fusion API business match endpoint.")
        assert((name != nil && name != "" && name.count <= 64), "A name (containing no more than 64 characters) is required to query the Yelp Fusion API business match endpoint.")
        if let addressOne = addressOne {
            assert(addressOne.count <= 64, "addressOne must contain no more than 64 characters to query the Yelp Fusion API business match endpoint.")
        }
        if let addressTwo = addressTwo {
            assert(addressTwo.count <= 64, "addressTwo must contain no more than 64 characters to query the Yelp Fusion API business match endpoint.")
        }
        if let addressThree = addressThree {
            assert(addressThree.count <= 64, "addressThree must contain no more than 64 characters to query the Yelp Fusion API business match endpoint.")
        }
        assert((city != nil && city != "" && city.count <= 64), "A city (no more than 64 characters) is required to query the Yelp Fusion API business match endpoint.")
        assert((state != nil && state != "" && state.count <= 3), "A state (containing no more than 3 characters) is required to query the Yelp Fusion API business match endpoint.")
        assert((country != nil && country != "" && country.count <= 2), "A country (containing no more than 2 characters) is required to query the Yelp Fusion API business match endpoint.")
        if let phone = phone {
            assert(phone.count <= 32, "phone must contain no more than 32 characters to query the Yelp Fusion API business match endpoint.")
        }
        if let postalCode = postalCode {
            assert(postalCode.count <= 12, "postalCode must contain no more than 12 characters to query the Yelp Fusion API business match endpoint.")
        }

        if self.isAuthenticated() == true {

            let params = Parameters.matchesParameters(withName: name,
                                                      addressOne: addressOne,
                                                      addressTwo: addressTwo,
                                                      addressThree: addressThree,
                                                      city: city,
                                                      state: state,
                                                      country: country,
                                                      latitude: latitude,
                                                      longitude: longitude,
                                                      phone: phone,
                                                      postalCode: postalCode,
                                                      yelpBusinessId: yelpBusinessId)

            self.manager.request(CDYelpRouter.matches(type: type.rawValue, parameters: params)).responseObject { (response: DataResponse<CDYelpSearchResponse>) in

                switch response.result {
                case .success(let searchResponse):
                    if let error = searchResponse.error {
                        print("searchBusinessMatches(byType) error: ", error.description ?? "")
                    }
                    completion(searchResponse)
                case .failure(let error):
                    print("searchBusinessMatches(byType) failure: ", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    ///
    /// This endpoint returns the up to three reviews for a business.
    ///
    /// - parameters:
    ///   - forBusinessId: (**Required**) The identifier of the business for the Yelp Fusion API to query.
    ///   - locale: (Optional) The interface locale; this determines the language for the reviews to return.
    ///   - completion: A completion block in which the Yelp Fusion API reviews endpoint response can be parsed.
    ///
    /// - returns: (CDYelpReviewsResponse?) -> Void
    ///
    public func fetchReviews(forBusinessId id: String!,
                             locale: CDYelpLocale?,
                             completion: @escaping (CDYelpReviewsResponse?) -> Void) {
        assert((id != nil && id != ""), "A business id is required to query the Yelp Fusion API reviews endpoint.")

        if self.isAuthenticated() == true {

            let params = Parameters.reviewsParameters(withLocale: locale)

            self.manager.request(CDYelpRouter.reviews(id: id, parameters: params)).responseObject { (response: DataResponse<CDYelpReviewsResponse>) in

                switch response.result {
                case .success(let reviewsResponse):
                    if let error = reviewsResponse.error {
                        print("fetchReviews(forBusinessId) error: ", error.description ?? "")
                    }
                    completion(reviewsResponse)
                case .failure(let error):
                    print("fetchReviews(forBusinessId) failure: ", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    ///
    /// This endpoint returns autocomplete suggestions for search keywords, businesses and categories, based on the input text.
    ///
    /// - parameters:
    ///   - byText: (**Required**) The text for the Yelp Fusion API to query.
    ///   - latitude: (**Required**) The latitude of the location to look for business autocomplete suggestions.
    ///   - longitude: (**Required**) The longitude of the location to look for business autocomplete suggestions.
    ///   - locale: (Optional) The interface locale; this determines the language for the autocomplete suggestions to return.
    ///   - completion: A completion block in which the Yelp Fusion API autocomplete endpoint response can be parsed.
    ///
    /// - returns: (CDYelpAutoCompleteResponse?) -> Void
    ///
    public func autocompleteBusinesses(byText text: String!,
                                       latitude: Double!,
                                       longitude: Double!,
                                       locale: CDYelpLocale?,
                                       completion: @escaping (CDYelpAutoCompleteResponse?) -> Void) {
        assert((text != nil && text != "") &&
            latitude != nil &&
            longitude != nil, "A search term, latitude, and longitude are required to query the Yelp Fusion API autocomplete endpoint.")

        if self.isAuthenticated() == true {

            let params = Parameters.autocompleteParameters(withText: text,
                                                           latitude: latitude,
                                                           longitude: longitude,
                                                           locale: locale)

            self.manager.request(CDYelpRouter.autocomplete(parameters: params)).responseObject { (response: DataResponse<CDYelpAutoCompleteResponse>) in

                switch response.result {
                case .success(let autocompleteResponse):
                    if let error = autocompleteResponse.error {
                        print("autocompleteBusinesses(byText) error: ", error.description ?? "")
                    }
                    completion(autocompleteResponse)
                case .failure(let error):
                    print("autocompleteBusinesses(byText) failure: ", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    ///
    /// This endpoint returns the detailed information of a Yelp event. To get an event id, refer to **searchEvents(byLocale: )** or **fetchFeaturedEvent(forLocale: )**. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - forId: (**Required**) The identifier of the event for the Yelp Fusion API to query.
    ///   - locale: (Optional) The locale to return the event information in.
    ///   - completion: A completion block in which the Yelp Fusion API event endpoint response can be parsed.
    ///
    /// - returns: (CDYelpEvent?) -> Void
    ///
    public func fetchEvent(forId id: String!,
                           locale: CDYelpLocale?,
                           completion: @escaping (CDYelpEvent?) -> Void) {
        assert((id != nil && id != ""), "An event id is required to query the Yelp Fusion API event endpoint.")

        if self.isAuthenticated() == true {

            let params = Parameters.eventParameters(withLocale: locale)

            self.manager.request(CDYelpRouter.event(id: id, parameters: params)).responseObject { (response: DataResponse<CDYelpEvent>) in

                switch response.result {
                case .success(let event):
                    completion(event)
                case .failure(let error):
                    print("fetchEvent(forId) failure: ", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    ///
    /// This endpoint returns events based on the provided search criteria. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - locale: (Optional) The locale to return the event information in.
    ///   - offset: (Optional) A number the list of returned events should be offset by.
    ///   - limit: (Optional) The number of events results to return. By default, the value is set to 3. **The maximum value is 50**.
    ///   - sortBy: (Optional) The sort by mode that will be used on the returned events results. Use the **CDYelpEvetSortByType** enum to get the list of supported sort types. By default sortBy is set to `.descending`.
    ///   - sortOn: (Optional) The sort on mode that will be used on the returned events results. Use the **CDYelpEvetSortOnType** enum to get the list of supported sort types. By default sortBy is set to `.popularity`.
    ///   - startDate: (Optional) A unix timestamp that queiries events only beginiing at or after the specified time.
    ///   - endDate: (Optional) A unix timestamp that queiries events only ending at or before the specified time.
    ///   - isFree: (Optional) When set to true, only events that are free to attend will be returned. By default, no filter is applied so both free and paid events will be returned.
    ///   - location: (Optional) Specifies the combination of "address, neighborhood, city, state or zip, optional country" to be used when querying the Yelp Fusion API for events.
    ///   - latitude: (Optional) The latitude of the location the Yelp Fusion API should search nearby.
    ///   - longitude: (Optional) The longitude of the location the Yelp Fusion API should search nearby.
    ///   - radius: (Optional) The search radius in meters. If the value is too large, an AREA_TOO_LARGE error may be returned. **The maximum value is 40,000 meters (25 miles)**.
    ///   - excludedEvent: (Optional) A list of event ids. Events associated with these event ids in this list will not show up in the response.
    ///   - completion: A completion block in which the Yelp Fusion API featured event endpoint response can be parsed.
    ///
    /// - returns: (CDYelpEventsResponse?) -> Void
    ///
    public func searchEvents(byLocale locale: CDYelpLocale?,
                             offset: Int?,
                             limit: Int?,
                             sortBy: CDYelpEventSortByType?,
                             sortOn: CDYelpEventSortOnType?,
                             categories: [CDYelpEventCategoryFilter]?,
                             startDate: Date?,
                             endDate: Date?,
                             isFree: Bool?,
                             location: String?,
                             latitude: Double?,
                             longitude: Double?,
                             radius: Int?,
                             excludedEvents: [String]?,
                             completion: @escaping (CDYelpEventsResponse?) -> Void) {
        if let limit = limit {
            assert((limit <= 50), "The limit must be 50 or less to query the Yelp Fusion API events endpoint.")
        }
        if let radius = radius {
            assert((radius <= 40000), "The radius must be 40,000 meters or less to query the Yelp Fusion API events endpoint.")
        }

        if self.isAuthenticated() == true {

            let params = Parameters.eventsParameters(withLocale: locale,
                                                     offset: offset,
                                                     limit: limit,
                                                     sortBy: sortBy,
                                                     sortOn: sortOn,
                                                     startDate: startDate,
                                                     endDate: endDate,
                                                     categories: categories,
                                                     isFree: isFree,
                                                     location: location,
                                                     latitude: latitude,
                                                     longitude: longitude,
                                                     radius: radius,
                                                     excludedEvents: excludedEvents)

            self.manager.request(CDYelpRouter.events(parameters: params)).responseObject { (response: DataResponse<CDYelpEventsResponse>) in

                switch response.result {
                case .success(let eventsResponse):
                    if let error = eventsResponse.error {
                        print("searchEvents(byLocale) error: ", error.description ?? "")
                    }
                    completion(eventsResponse)
                case .failure(let error):
                    print("searchEvents(byLocale) failure: ", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    ///
    /// This endpoint returns the featured event for a given location. Featured events are chosen by Yelp's community managers. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - locale: (Optional) The locale to return the event information in.
    ///   - location: (**Required**) Can be (Optional) if either latitude or longitude is provided. Specifies the combination of "address, neighborhood, city, state or zip, optional country" to be used when querying the Yelp Fusion API for events.
    ///   - latitude: (**Required**) Can be (Optional) if location is provided. The latitude of the location the Yelp Fusion API should search nearby.
    ///   - longitude: (**Required**) Can be (Optional) if location is provided. The longitude of the location the Yelp Fusion API should search nearby.
    ///   - completion: A completion block in which the Yelp Fusion API featured event endpoint response can be parsed.
    ///
    /// - returns: (CDYelpEvent?) -> Void
    ///
    public func fetchFeaturedEvent(forLocale locale: CDYelpLocale?,
                                   location: String?,
                                   latitude: Double?,
                                   longitude: Double?,
                                   completion: @escaping (CDYelpEvent?) -> Void) {
        assert((latitude != nil && longitude != nil) ||
            (location != nil && location != ""), "Either a latitude and longitude or a location are required to query the Yelp Fusion API featured event endpoint.")

        if self.isAuthenticated() == true {

            let params = Parameters.featuredEvent(withLocale: locale,
                                                  location: location,
                                                  latitude: latitude,
                                                  longitude: longitude)

            self.manager.request(CDYelpRouter.featuredEvent(parameters: params)).responseObject { (response: DataResponse<CDYelpEvent>) in

                switch response.result {
                case .success(let event):
                    completion(event)
                case .failure(let error):
                    print("fetchFeaturedEvent(forLocale) failure: ", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    ///
    /// Cancels any in progress or pending API requests.
    ///
    /// - returns: Void
    ///
    public func cancelAllPendingAPIRequests() {
        self.manager.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }
}
