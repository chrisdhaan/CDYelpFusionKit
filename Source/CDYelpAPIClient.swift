//
//  CDYelpAPIClient.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/7/16.
//
//  Copyright © 2016-2026 Christopher de Haan <contact@christopherdehaan.me>
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

#if os(macOS)
    import Foundation
#else
    import UIKit
#endif

import Alamofire

public class CDYelpAPIClient: @unchecked Sendable {
    private let apiKey: String
    private let responseCache: CDYelpResponseCache?
    private let retryConfiguration: CDYelpRetryConfiguration
    private let decoderConfiguration: CDYelpDecoderConfiguration
    private let eventMonitors: [any CDYelpEventMonitor]
    private let requestAdapters: [any CDYelpRequestAdapter]
    private lazy var manager: Alamofire.Session = {
        var headers = HTTPHeaders.default
        headers["Authorization"] = "Bearer \(self.apiKey)"
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers.dictionary

        let alamofireMonitors: [any EventMonitor] = self.eventMonitors.isEmpty
            ? []
            : [CDYelpAlamofireEventMonitor(monitors: self.eventMonitors)]

        var adapters: [RequestAdapter] = []
        if !self.requestAdapters.isEmpty {
            adapters.append(CDYelpAlamofireRequestAdapter(adapters: self.requestAdapters))
        }

        var retriers: [RequestRetrier] = []
        if self.retryConfiguration.retryLimit > 0 {
            let policy = RetryPolicy(
                retryLimit: self.retryConfiguration.retryLimit,
                exponentialBackoffBase: 2,
                exponentialBackoffScale: self.retryConfiguration.initialDelay,
                retryableHTTPStatusCodes: self.retryConfiguration.retryableHTTPStatusCodes,
                retryableURLErrorCodes: [
                    .networkConnectionLost,
                    .notConnectedToInternet,
                    .timedOut,
                ]
            )
            retriers.append(policy)
        }

        let interceptor: RequestInterceptor? = (adapters.isEmpty && retriers.isEmpty)
            ? nil
            : Interceptor(adapters: adapters, retriers: retriers)

        return Alamofire.Session(
            configuration: configuration,
            interceptor: interceptor,
            eventMonitors: alamofireMonitors
        )
    }()

    // MARK: - Initializers

    ///
    /// Initializes a new CDYelpAPIClient object.
    ///
    /// - parameters:
    ///   - apiKey: (**Required**) A unique key for the Yelp application used for authenticating with the Yelp Fusion API. **Do not share this key**.
    ///   - cacheConfiguration: (Optional) Configuration for the built-in response cache. Defaults to disabled.
    ///   - retryConfiguration: (Optional) Configuration for automatic retry with exponential backoff. Defaults to disabled.
    ///   - decoderConfiguration: (Optional) Configuration for JSON decoding strategies. Defaults to standard configuration.
    ///   - eventMonitors: (Optional) An array of event monitors to observe CDYelpFusionKit request and response events. Defaults to an empty array.
    ///   - requestAdapters: (Optional) An array of request adapters to mutate URLRequests before sending. Defaults to an empty array.
    ///
    /// - returns: Void
    ///
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
        self.decoderConfiguration = decoderConfiguration
        self.retryConfiguration = retryConfiguration
        responseCache = cacheConfiguration.ttl > 0
            ? CDYelpResponseCache(configuration: cacheConfiguration)
            : nil
        self.eventMonitors = eventMonitors
        self.requestAdapters = requestAdapters
    }

    // MARK: - Authentication Methods

    ///
    /// Determines whether or not the Yelp application has successfully authenticated with the Yelp Fusion API.
    ///
    /// - returns: Bool
    ///
    public func isAuthenticated() -> Bool {
        return true
    }

    // MARK: - Cache Methods

    /// Removes all cached responses.
    public func clearCache() {
        responseCache?.removeAll()
    }

    // MARK: - Private Request Helpers

    private func cachedRequest<T: Decodable>(
        _ router: CDYelpRouter,
        decoder: JSONDecoder? = nil,
        completion: @escaping (T?) -> Void
    ) {
        let decoder = decoder ?? decoderConfiguration.makeDecoder()

        // Only build the cache key when caching is enabled, skipping the redundant
        // asURLRequest() + adapter pass on every uncached call. If any adapter throws,
        // skip caching and let Alamofire surface the error through the normal failure path.
        var cacheKey: String?
        if responseCache != nil, var urlRequest = try? router.asURLRequest() {
            do {
                for adapter in requestAdapters {
                    urlRequest = try adapter.adapt(urlRequest)
                }
                cacheKey = CDYelpCacheKey.key(for: urlRequest)
            } catch {
                cacheKey = nil
            }
        }

        if let cache = responseCache, let key = cacheKey, let cachedData = cache.data(forKey: key) {
            completion(try? decoder.decode(T.self, from: cachedData))
            return
        }

        manager
            .request(router)
            .validate()
            .responseData { [weak self] dataResponse in
                switch dataResponse.result {
                case let .success(data):
                    // Only cache bytes that decode successfully; storing undecoded data would
                    // poison the cache key for the entire TTL with no recovery path.
                    if let decoded = try? decoder.decode(T.self, from: data) {
                        if let key = cacheKey {
                            self?.responseCache?.set(data: data, forKey: key)
                        }
                        completion(decoded)
                    } else {
                        completion(nil)
                    }
                case .failure:
                    completion(nil)
                }
            }
    }

    // MARK: - Yelp Fusion API Methods

    // MARK: - Business Endpoints

    /// Searches for businesses based on the provided search criteria.
    ///
    /// This endpoint returns up to 1000 businesses with basic information. Use ``fetchBusiness(forId:locale:completion:)`` for detailed information or ``fetchReviews(forBusinessId:locale:completion:)`` for reviews.
    ///
    /// - Parameters:
    ///   - term: A search term (e.g. "food", "restaurants"). If not provided, all data is searched.
    ///   - location: A location string (address, city, state, or zip). Required unless latitude and longitude are provided.
    ///   - latitude: The latitude to search nearby. Required unless location is provided.
    ///   - longitude: The longitude to search nearby. Required unless location is provided.
    ///   - radius: Search radius in meters (maximum 40,000).
    ///   - categories: Category filters using ``CDYelpCategoryAlias``.
    ///   - locale: Result locale using ``CDYelpLocale``.
    ///   - limit: Number of results (1-50, default 20).
    ///   - offset: Result offset for pagination.
    ///   - sortBy: Sort mode using ``CDYelpBusinessSortType`` (default .bestMatch).
    ///   - priceTiers: Price filters using ``CDYelpPriceTier``.
    ///   - openNow: Filter to open businesses only.
    ///   - openAt: Unix timestamp to filter businesses open at specific time.
    ///   - attributes: Additional filters using ``CDYelpAttributeFilter``.
    ///   - completion: Callback with ``CDYelpSearchResponse`` Business results.
    ///
    public func searchBusinesses(byTerm term: String?,
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
                                 completion: @escaping (CDYelpSearchResponse.Business?) -> Void)
    {
        assert((latitude != nil && longitude != nil) ||
            (location != nil), "Either a latitude and longitude or a location are required to query the Yelp Fusion API search endpoint.")
        if let radius = radius {
            assert(radius > 0 && radius <= 40000, "The radius must be 40,000 meters or less to query the Yelp Fusion API search endpoint.")
        }
        if let limit = limit {
            assert(limit > 0 && limit <= 50, "The limit must be 50 or less to query the Yelp Fusion API search endpoint.")
        }

        if isAuthenticated() == true {
            let parameters = Parameters.searchParameters(withTerm: term,
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

            cachedRequest(CDYelpRouter.search(parameters: parameters), completion: completion)
        }
    }

    ///
    /// This endpoint returns a list of businesses based on the provided phone number. It is possible for more than one businesses having the same phone number (for example, chain stores with the same +1 800 phone number). At this time, this endpoint does not return businesses without any reviews.
    ///
    /// - parameters:
    ///   - phoneNumber: (**Required**) The phone number of the business for the Yelp Fusion API to query. It must start with + and include the country code, (e.g. "+14159083801").
    ///   - completion: A completion block in which the Yelp Fusion API phone search endpoint response can be parsed.
    ///
    public func searchBusinesses(byPhoneNumber phoneNumber: String!,
                                 completion: @escaping (CDYelpSearchResponse.Phone?) -> Void)
    {
        assert(phoneNumber != nil && phoneNumber.count > 0, "A business phone number is required to query the Yelp Fusion API phone endpoint.")

        if isAuthenticated() == true {
            let parameters = Parameters.phoneParameters(withPhoneNumber: phoneNumber)

            cachedRequest(CDYelpRouter.phone(parameters: parameters), completion: completion)
        }
    }

    ///
    /// This endpoint returns a list of businesses which support certain transactions. At this time, this endpoint does not return businesses without any reviews. Currently, this endpoint only supports food delivery in the US.
    ///
    /// - parameters:
    ///   - type: (**Required**) A transaction type for the Yelp Fusion API to query.
    ///   - latitude: (**Required when location isn't provided**) The latitude of the location you want delivery from.
    ///   - longitude: (**Required when location isn't provided**) The longitude of the location you want delivery from.
    ///   - location: (**Required when latitude and longitude aren't provided**) The address of the location you want delivery from.
    ///   - completion: A completion block in which the Yelp Fusion API transactions endpoint response can be parsed.
    ///
    public func searchTransactions(byType type: CDYelpTransactionType!,
                                   location: String?,
                                   latitude: Double?,
                                   longitude: Double?,
                                   completion: @escaping (CDYelpSearchResponse.Transaction?) -> Void)
    {
        assert(type != nil, "A transaction type is required to query the Yelp Fusion API transactions endpoint.")
        assert((latitude != nil && longitude != nil) ||
            (location != nil), "Either a latitude and longitude or a location are required to query the Yelp Fusion API transactions endpoint.")

        if isAuthenticated() == true {
            let parameters = Parameters.transactionsParameters(withLocation: location,
                                                               latitude: latitude,
                                                               longitude: longitude)

            cachedRequest(CDYelpRouter.transactions(type: type.rawValue, parameters: parameters), completion: completion)
        }
    }

    ///
    /// This endpoint returns the detail information of a business. To get a business id, refer to **searchBusinesses(byTerm: )**, **searchBusinesses(byPhoneNumber: )**, **searchTransactions(byType: )**, **searchBusinesses(byMatchType: )** or **autocompleteBusinesses(byText: )**. To get review information for a business, refer to **fetchReviews(forBusinessId: )**. At this time, this endpoint does not return businesses without any reviews.
    ///
    /// - parameters:
    ///   - id: (**Required**) The identifier of the business for the Yelp Fusion API to query.
    ///   - locale: (Optional) The interface locale; this determines the language of the business information returned.
    ///   - completion: A completion block in which the Yelp Fusion API business endpoint response can be parsed.
    ///
    public func fetchBusiness(forId id: String!,
                              locale: CDYelpLocale?,
                              completion: @escaping (CDYelpBusinessResponse?) -> Void)
    {
        assert(id != nil && id.count > 0, "A business id is required to query the Yelp Fusion API business endpoint.")

        if isAuthenticated() == true {
            let parameters = Parameters.businessParameters(withLocale: locale)

            cachedRequest(CDYelpRouter.business(id: id, parameters: parameters), completion: completion)
        }
    }

    ///
    /// This endpoint lets you match business data from other sources against businesses on Yelp, based on provided business information. For example, if you know a business's exact address and name, and you want to find that business and only that business on Yelp. At this time, the API does not return businesses without any reviews.
    ///
    /// - parameters:
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
    ///   - zipCode: (Optional) The zip code of the business.
    ///   - yelpBusinessId: (Optional) Unique Yelp identifier of the business if available. Used as a hint when finding a matching business.
    ///   - limit: (Optional)
    ///   - matchThresholdType: (**Required**) Specifies whether a match quality threshold should be applied to the matched businesses. Use the **CDYelpBusinessMatchThresholdType** enum to get the list of supported thresholds.
    ///   - completion: A completion block in which the Yelp Fusion API business match endpoint response can be parsed.
    ///
    public func searchBusinesses(name: String!,
                                 addressOne: String!,
                                 addressTwo: String?,
                                 addressThree: String?,
                                 city: String!,
                                 state: String!,
                                 country: String!,
                                 latitude: Double?,
                                 longitude: Double?,
                                 phone: String?,
                                 zipCode: String?,
                                 yelpBusinessId: String?,
                                 limit: Int?,
                                 matchThresholdType: CDYelpBusinessMatchThresholdType!,
                                 completion: @escaping (CDYelpSearchResponse.BusinessMatch?) -> Void)
    {
        assert(name != nil && name.count > 0 && name.count <= 64, "A name (containing no more than 64 characters) is required to query the Yelp Fusion API business match endpoint.")
        assert(addressOne != nil && addressOne.count > 0 && addressOne.count <= 64, "addressOne must contain no more than 64 characters to query the Yelp Fusion API business match endpoint.")
        if let addressTwo = addressTwo {
            assert(addressTwo.count > 0 && addressTwo.count <= 64, "addressTwo must contain no more than 64 characters to query the Yelp Fusion API business match endpoint.")
        }
        if let addressThree = addressThree {
            assert(addressThree.count > 0 && addressThree.count <= 64, "addressThree must contain no more than 64 characters to query the Yelp Fusion API business match endpoint.")
        }
        assert(city != nil && city.count > 0 && city.count <= 64, "A city (no more than 64 characters) is required to query the Yelp Fusion API business match endpoint.")
        assert(state != nil && state.count > 0 && state.count <= 3, "A state (containing no more than 3 characters) is required to query the Yelp Fusion API business match endpoint.")
        assert(country != nil && country.count > 0 && country.count <= 2, "A country (containing no more than 2 characters) is required to query the Yelp Fusion API business match endpoint.")
        if let latitude = latitude {
            assert(latitude >= -90.0 && latitude <= 90.0, "latitude must be between -90 and +90 to query the Yelp Fustion API business match endpoint")
        }
        if let longitude = longitude {
            assert(longitude >= -180.0 && longitude <= 180.0, "longitude must be between -180 and +180 to query the Yelp Fustion API business match endpoint")
        }
        if let phone = phone {
            assert(phone.count > 0 && phone.count <= 32, "phone must contain no more than 32 characters to query the Yelp Fusion API business match endpoint.")
        }
        if let limit = limit {
            assert(limit > 0 && limit <= 10, "The limit must be between 1 and 10 to query the Yelp Fusion API business match endpoint.")
        }
        assert(matchThresholdType != nil && matchThresholdType.rawValue.count > 0, "A match threshold type is required to query the Yelp Fusion API business match endpoint")

        if isAuthenticated() == true {
            let parameters = Parameters.matchesParameters(withName: name,
                                                          addressOne: addressOne,
                                                          addressTwo: addressTwo,
                                                          addressThree: addressThree,
                                                          city: city,
                                                          state: state,
                                                          country: country,
                                                          latitude: latitude,
                                                          longitude: longitude,
                                                          phone: phone,
                                                          zipCode: zipCode,
                                                          yelpBusinessId: yelpBusinessId,
                                                          limit: limit,
                                                          matchThresholdType: matchThresholdType)

            cachedRequest(CDYelpRouter.matches(parameters: parameters), completion: completion)
        }
    }

    ///
    /// This endpoint returns the up to three reviews for a business.
    ///
    /// - parameters:
    ///   - id: (**Required**) The identifier of the business for the Yelp Fusion API to query.
    ///   - locale: (Optional) The interface locale; this determines the language for the reviews to return.
    ///   - completion: A completion block in which the Yelp Fusion API reviews endpoint response can be parsed.
    ///
    public func fetchReviews(forBusinessId id: String!,
                             locale: CDYelpLocale?,
                             completion: @escaping (CDYelpReviewsResponse?) -> Void)
    {
        assert(id != nil && id.count > 0, "A business id is required to query the Yelp Fusion API reviews endpoint.")

        if isAuthenticated() == true {
            let parameters = Parameters.reviewsParameters(withLocale: locale)
            let decoder = decoderConfiguration.makeDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.reviews)

            cachedRequest(CDYelpRouter.reviews(id: id, parameters: parameters), decoder: decoder, completion: completion)
        }
    }

    ///
    /// This endpoint returns autocomplete suggestions for search keywords, businesses and categories, based on the input text.
    ///
    /// - parameters:
    ///   - text: (**Required**) The text for the Yelp Fusion API to query.
    ///   - latitude: (**Required**) The latitude of the location to look for business autocomplete suggestions.
    ///   - longitude: (**Required**) The longitude of the location to look for business autocomplete suggestions.
    ///   - locale: (Optional) The interface locale; this determines the language for the autocomplete suggestions to return.
    ///   - completion: A completion block in which the Yelp Fusion API autocomplete endpoint response can be parsed.
    ///
    public func autocompleteBusinesses(byText text: String!,
                                       latitude: Double!,
                                       longitude: Double!,
                                       locale: CDYelpLocale?,
                                       completion: @escaping (CDYelpAutoCompleteResponse?) -> Void)
    {
        assert((text != nil && text.count > 0) &&
            latitude != nil &&
            longitude != nil, "A search term, latitude, and longitude are required to query the Yelp Fusion API autocomplete endpoint.")

        if isAuthenticated() == true {
            let parameters = Parameters.autocompleteParameters(withText: text,
                                                               latitude: latitude,
                                                               longitude: longitude,
                                                               locale: locale)

            cachedRequest(CDYelpRouter.autocomplete(parameters: parameters), completion: completion)
        }
    }

    // MARK: - Event Endpoints

    ///
    /// This endpoint returns the detailed information of a Yelp event. To get an event id, refer to **searchEvents(byLocale: )** or **fetchFeaturedEvent(forLocale: )**. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - id: (**Required**) The identifier of the event for the Yelp Fusion API to query.
    ///   - locale: (Optional) The locale to return the event information in.
    ///   - completion: A completion block in which the Yelp Fusion API event endpoint response can be parsed.
    ///
    public func fetchEvent(forId id: String!,
                           locale: CDYelpLocale?,
                           completion: @escaping (CDYelpEventResponse?) -> Void)
    {
        assert(id != nil && id.count > 0, "An event id is required to query the Yelp Fusion API event endpoint.")

        if isAuthenticated() == true {
            let parameters = Parameters.eventParameters(withLocale: locale)
            let decoder = decoderConfiguration.makeDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.events)

            cachedRequest(CDYelpRouter.event(id: id, parameters: parameters), decoder: decoder, completion: completion)
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
    ///   - categories: (Optional) The categories for the Yelp Fusion API to filter events by.
    ///   - excludedEvents: (Optional) A list of event ids. Events associated with these event ids in this list will not show up in the response.
    ///   - completion: A completion block in which the Yelp Fusion API featured event endpoint response can be parsed.
    ///
    public func searchEvents(byLocale locale: CDYelpLocale?,
                             offset: Int?,
                             limit: Int?,
                             sortBy: CDYelpEventSortByType?,
                             sortOn: CDYelpEventSortOnType?,
                             startDate: Date?,
                             endDate: Date?,
                             categories: [CDYelpEventCategoryFilter]?,
                             isFree: Bool?,
                             location: String?,
                             latitude: Double?,
                             longitude: Double?,
                             radius: Int?,
                             excludedEvents: [String]?,
                             completion: @escaping (CDYelpEventsResponse?) -> Void)
    {
        if let limit = limit {
            assert(limit > 0 && limit <= 50, "The limit must be 50 or less to query the Yelp Fusion API events endpoint.")
        }
        if let radius = radius {
            assert(radius > 0 && radius <= 40000, "The radius must be 40,000 meters or less to query the Yelp Fusion API events endpoint.")
        }

        if isAuthenticated() == true {
            let parameters = Parameters.eventsParameters(withLocale: locale,
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
            let decoder = decoderConfiguration.makeDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.events)

            cachedRequest(CDYelpRouter.events(parameters: parameters), decoder: decoder, completion: completion)
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
    public func fetchFeaturedEvent(forLocale locale: CDYelpLocale?,
                                   location: String?,
                                   latitude: Double?,
                                   longitude: Double?,
                                   completion: @escaping (CDYelpEventResponse?) -> Void)
    {
        assert((latitude != nil && longitude != nil) ||
            (location != nil), "Either a latitude and longitude or a location are required to query the Yelp Fusion API featured event endpoint.")

        if isAuthenticated() == true {
            let parameters = Parameters.featuredEventParameters(withLocale: locale,
                                                                location: location,
                                                                latitude: latitude,
                                                                longitude: longitude)
            let decoder = decoderConfiguration.makeDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.events)

            cachedRequest(CDYelpRouter.featuredEvent(parameters: parameters), decoder: decoder, completion: completion)
        }
    }

    // MARK: - Category Endpoints

    ///
    /// This endpoint returns all Yelp business categories across all locales by default. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - locale: (Optional) The locale to return the category information in.
    ///   - completion: A completion block in which the Yelp Fusion API categories endpoint response can be parsed.
    ///
    public func fetchCategories(forLocale locale: CDYelpLocale?,
                                completion: @escaping (CDYelpCategoriesResponse?) -> Void)
    {
        if isAuthenticated() == true {
            let parameters = Parameters.categoriesParameters(withLocale: locale)

            cachedRequest(CDYelpRouter.allCategories(parameters: parameters), completion: completion)
        }
    }

    ///
    /// This endpoint returns detailed information about the Yelp category specified by a Yelp category alias.  To get a category alias, refer to **fetchCategories(forLocale: )**. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - alias: (**Required**) The alias to return category details for. Use the **CDYelpCategoryAlias** enum to get the list of supported category aliases.
    ///   - locale: (Optional) The locale to return the category information in.
    ///   - completion: A completion block in which the Yelp Fusion API category endpoint response can be parsed.
    ///
    public func fetchCategory(forAlias alias: CDYelpCategoryAlias!,
                              andLocale locale: CDYelpLocale?,
                              completion: @escaping (CDYelpCategoryResponse?) -> Void)
    {
        assert(alias != nil && alias.rawValue.count > 0, "A category alias is required to query the Yelp Fusion API category details endpoint.")

        if isAuthenticated() == true {
            let parameters = Parameters.categoriesParameters(withLocale: locale)

            cachedRequest(CDYelpRouter.categoryDetails(alias: alias.rawValue, parameters: parameters), completion: completion)
        }
    }

    // MARK: - Request Methods

    ///
    /// Cancels any in progress or pending API requests.
    public func cancelAllPendingAPIRequests() {
        manager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }

    // MARK: - Async/Await Overloads

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func searchBusinesses(byTerm term: String?,
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
                                 attributes: [CDYelpAttributeFilter]?) async throws -> CDYelpSearchResponse.Business
    {
        try await withCheckedThrowingContinuation { continuation in
            self.searchBusinesses(byTerm: term,
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
            { response in
                guard let response = response else {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                    return
                }
                if let error = response.error {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .customValidationFailed(error: error)))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func searchBusinesses(byPhoneNumber phoneNumber: String!) async throws -> CDYelpSearchResponse.Phone {
        try await withCheckedThrowingContinuation { continuation in
            self.searchBusinesses(byPhoneNumber: phoneNumber) { response in
                guard let response = response else {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                    return
                }
                if let error = response.error {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .customValidationFailed(error: error)))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func searchTransactions(byType type: CDYelpTransactionType!,
                                   location: String?,
                                   latitude: Double?,
                                   longitude: Double?) async throws -> CDYelpSearchResponse.Transaction
    {
        try await withCheckedThrowingContinuation { continuation in
            self.searchTransactions(byType: type,
                                    location: location,
                                    latitude: latitude,
                                    longitude: longitude)
            { response in
                guard let response = response else {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                    return
                }
                if let error = response.error {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .customValidationFailed(error: error)))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func fetchBusiness(forId id: String!,
                              locale: CDYelpLocale?) async throws -> CDYelpBusinessResponse
    {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchBusiness(forId: id,
                               locale: locale)
            { response in
                guard let response = response else {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func searchBusinesses(name: String!,
                                 addressOne: String!,
                                 addressTwo: String?,
                                 addressThree: String?,
                                 city: String!,
                                 state: String!,
                                 country: String!,
                                 latitude: Double?,
                                 longitude: Double?,
                                 phone: String?,
                                 zipCode: String?,
                                 yelpBusinessId: String?,
                                 limit: Int?,
                                 matchThresholdType: CDYelpBusinessMatchThresholdType!) async throws -> CDYelpSearchResponse.BusinessMatch
    {
        try await withCheckedThrowingContinuation { continuation in
            self.searchBusinesses(name: name,
                                  addressOne: addressOne,
                                  addressTwo: addressTwo,
                                  addressThree: addressThree,
                                  city: city,
                                  state: state,
                                  country: country,
                                  latitude: latitude,
                                  longitude: longitude,
                                  phone: phone,
                                  zipCode: zipCode,
                                  yelpBusinessId: yelpBusinessId,
                                  limit: limit,
                                  matchThresholdType: matchThresholdType)
            { response in
                guard let response = response else {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                    return
                }
                if let error = response.error {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .customValidationFailed(error: error)))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func fetchReviews(forBusinessId id: String!,
                             locale: CDYelpLocale?) async throws -> CDYelpReviewsResponse
    {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchReviews(forBusinessId: id,
                              locale: locale)
            { response in
                guard let response = response else {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                    return
                }
                if let error = response.error {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .customValidationFailed(error: error)))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func autocompleteBusinesses(byText text: String!,
                                       latitude: Double!,
                                       longitude: Double!,
                                       locale: CDYelpLocale?) async throws -> CDYelpAutoCompleteResponse
    {
        try await withCheckedThrowingContinuation { continuation in
            self.autocompleteBusinesses(byText: text,
                                        latitude: latitude,
                                        longitude: longitude,
                                        locale: locale)
            { response in
                guard let response = response else {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                    return
                }
                if let error = response.error {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .customValidationFailed(error: error)))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func fetchEvent(forId id: String!,
                           locale: CDYelpLocale?) async throws -> CDYelpEventResponse
    {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchEvent(forId: id,
                            locale: locale)
            { response in
                guard let response = response else {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func searchEvents(byLocale locale: CDYelpLocale?,
                             offset: Int?,
                             limit: Int?,
                             sortBy: CDYelpEventSortByType?,
                             sortOn: CDYelpEventSortOnType?,
                             startDate: Date?,
                             endDate: Date?,
                             categories: [CDYelpEventCategoryFilter]?,
                             isFree: Bool?,
                             location: String?,
                             latitude: Double?,
                             longitude: Double?,
                             radius: Int?,
                             excludedEvents: [String]?) async throws -> CDYelpEventsResponse
    {
        try await withCheckedThrowingContinuation { continuation in
            self.searchEvents(byLocale: locale,
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
            { response in
                guard let response = response else {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                    return
                }
                if let error = response.error {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .customValidationFailed(error: error)))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func fetchFeaturedEvent(forLocale locale: CDYelpLocale?,
                                   location: String?,
                                   latitude: Double?,
                                   longitude: Double?) async throws -> CDYelpEventResponse
    {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchFeaturedEvent(forLocale: locale,
                                    location: location,
                                    latitude: latitude,
                                    longitude: longitude)
            { response in
                guard let response = response else {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func fetchCategories(forLocale locale: CDYelpLocale?) async throws -> CDYelpCategoriesResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchCategories(forLocale: locale) { response in
                guard let response = response else {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }

    @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
    public func fetchCategory(forAlias alias: CDYelpCategoryAlias!,
                              andLocale locale: CDYelpLocale?) async throws -> CDYelpCategoryResponse
    {
        try await withCheckedThrowingContinuation { continuation in
            self.fetchCategory(forAlias: alias,
                               andLocale: locale)
            { response in
                guard let response = response else {
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                    return
                }
                continuation.resume(returning: response)
            }
        }
    }
}
