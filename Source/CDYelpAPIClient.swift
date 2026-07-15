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

public final class CDYelpAPIClient: Sendable {
    private let apiKey: String
    private let decoderConfiguration: CDYelpDecoderConfiguration
    private let urlSession: CDYelpURLSession

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
    public convenience init(
        apiKey: String,
        cacheConfiguration: CDYelpCacheConfiguration = .disabled,
        retryConfiguration: CDYelpRetryConfiguration = .disabled,
        decoderConfiguration: CDYelpDecoderConfiguration = .default,
        eventMonitors: [any CDYelpEventMonitor] = [],
        requestAdapters: [any CDYelpRequestAdapter] = []
    ) {
        self.init(
            apiKey: apiKey,
            sessionConfiguration: .default,
            cacheConfiguration: cacheConfiguration,
            retryConfiguration: retryConfiguration,
            decoderConfiguration: decoderConfiguration,
            eventMonitors: eventMonitors,
            requestAdapters: requestAdapters
        )
    }

    ///
    /// Initializes a new CDYelpAPIClient object with a custom URLSessionConfiguration. This
    /// overload exists primarily so `CDYelpMockClientFactory` (in the separate `CDYelpFusionKitTesting`
    /// target) can inject a configuration whose `protocolClasses` route requests through
    /// `CDYelpMockURLProtocol` for testing.
    ///
    /// - parameters:
    ///   - apiKey: (**Required**) A unique key for the Yelp application used for authenticating with the Yelp Fusion API. **Do not share this key**.
    ///   - sessionConfiguration: (**Required**) The `URLSessionConfiguration` used to construct the underlying `URLSession`.
    ///   - cacheConfiguration: (Optional) Configuration for the built-in response cache. Defaults to disabled.
    ///   - retryConfiguration: (Optional) Configuration for automatic retry with exponential backoff. Defaults to disabled.
    ///   - decoderConfiguration: (Optional) Configuration for JSON decoding strategies. Defaults to standard configuration.
    ///   - eventMonitors: (Optional) An array of event monitors to observe CDYelpFusionKit request and response events. Defaults to an empty array.
    ///   - requestAdapters: (Optional) An array of request adapters to mutate URLRequests before sending. Defaults to an empty array.
    ///
    public init(
        apiKey: String,
        sessionConfiguration: URLSessionConfiguration,
        cacheConfiguration: CDYelpCacheConfiguration = .disabled,
        retryConfiguration: CDYelpRetryConfiguration = .disabled,
        decoderConfiguration: CDYelpDecoderConfiguration = .default,
        eventMonitors: [any CDYelpEventMonitor] = [],
        requestAdapters: [any CDYelpRequestAdapter] = []
    ) {
        precondition(!apiKey.isEmpty, "An apiKey is required to query the Yelp Fusion API.")
        self.apiKey = apiKey
        self.decoderConfiguration = decoderConfiguration
        let cache = cacheConfiguration.ttl > 0
            ? CDYelpResponseCache(configuration: cacheConfiguration)
            : nil
        urlSession = CDYelpURLSession(
            session: URLSession(configuration: sessionConfiguration),
            makeDecoder: { decoderConfiguration.makeDecoder() },
            cache: cache,
            monitors: eventMonitors,
            adapters: requestAdapters,
            retryConfig: retryConfiguration
        )
    }

    // MARK: - Cache Methods

    /// Removes all cached responses.
    public func clearCache() {
        urlSession.clearCache()
    }

    /// Builds a decoder honoring `decoderConfiguration` with the given date format substituted in,
    /// shared by the reviews/events endpoints whose date fields don't use the default ISO-8601 strategy.
    private func makeDecoder(dateFormat: DateFormatter) -> JSONDecoder {
        let decoder = decoderConfiguration.makeDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormat)
        return decoder
    }

    // MARK: - Request Methods

    /// Cancels any in progress or pending API requests. Suspends until cancellation has been
    /// applied to all in-flight tasks and retry backoff sleeps.
    public func cancelAllPendingAPIRequests() async {
        await urlSession.cancelAllTasks()
    }

    /// Builds and performs the request for a router case, shared by every endpoint method below
    /// so the "build request, perform, honor cacheability" sequence is expressed once.
    private func perform<T: Decodable>(_ router: CDYelpRouter, decoder: JSONDecoder? = nil) async throws -> T {
        let request = try router.asURLRequest(apiKey: apiKey)
        return try await urlSession.perform(request, decoder: decoder, cacheable: router.isCacheable)
    }

    // MARK: - Yelp Fusion API Methods

    // MARK: - Business Endpoints

    /// Searches for businesses based on the provided search criteria.
    ///
    /// This endpoint returns up to 1000 businesses with basic information. Use ``fetchBusiness(forId:locale:devicePlatform:)`` for detailed information or ``fetchReviews(forBusinessId:locale:offset:limit:sortBy:)`` for reviews.
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
    ///   - devicePlatform: (Optional) The device platform for the request.
    ///   - reservationDate: (Optional) The date for reservation filtering (format: YYYY-MM-DD).
    ///   - reservationTime: (Optional) The time for reservation filtering (format: HH:MM).
    ///   - reservationCovers: (Optional) The party size for reservation filtering.
    ///   - matchesPartySize: (Optional) Whether to filter for businesses that match the party size.
    ///   - jobAlias: (Optional) The job alias for job-related filtering.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func searchBusinesses(
        byTerm term: String?,
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
        devicePlatform: String? = nil,
        reservationDate: String? = nil,
        reservationTime: String? = nil,
        reservationCovers: Int? = nil,
        matchesPartySize: Bool? = nil,
        jobAlias: String? = nil
    ) async throws -> CDYelpSearchResponse.Business {
        precondition(
            (latitude != nil && longitude != nil) || location != nil,
            "Either a latitude and longitude or a location are required to query the Yelp Fusion API search endpoint."
        )
        if let radius {
            precondition(radius > 0 && radius <= 40000, "The radius must be 40,000 meters or less to query the Yelp Fusion API search endpoint.")
        }
        if let limit {
            precondition(limit > 0 && limit <= 50, "The limit must be 50 or less to query the Yelp Fusion API search endpoint.")
        }
        let parameters = Parameters.searchParameters(
            withTerm: term,
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
            attributes: attributes,
            devicePlatform: devicePlatform,
            reservationDate: reservationDate,
            reservationTime: reservationTime,
            reservationCovers: reservationCovers,
            matchesPartySize: matchesPartySize,
            jobAlias: jobAlias
        )
        let router = CDYelpRouter.search(parameters: parameters)
        return try await perform(router)
    }

    ///
    /// This endpoint returns a list of businesses based on the provided phone number. It is possible for more than one businesses having the same phone number (for example, chain stores with the same +1 800 phone number). At this time, this endpoint does not return businesses without any reviews.
    ///
    /// - parameters:
    ///   - phoneNumber: (**Required**) The phone number of the business for the Yelp Fusion API to query. It must start with + and include the country code, (e.g. "+14159083801").
    ///   - locale: (Optional) The interface locale; this determines the language for the results to return.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func searchBusinesses(
        byPhoneNumber phoneNumber: String,
        locale: CDYelpLocale? = nil
    ) async throws -> CDYelpSearchResponse.Phone {
        precondition(!phoneNumber.isEmpty, "A business phone number is required to query the Yelp Fusion API phone endpoint.")
        let parameters = Parameters.phoneParameters(withPhoneNumber: phoneNumber, locale: locale)
        let router = CDYelpRouter.phone(parameters: parameters)
        return try await perform(router)
    }

    ///
    /// This endpoint returns a list of businesses which support certain transactions. At this time, this endpoint does not return businesses without any reviews. This endpoint supports food delivery, pickup, and restaurant reservations. Delivery and pickup are only supported in the US.
    ///
    /// - parameters:
    ///   - type: (**Required**) A transaction type for the Yelp Fusion API to query.
    ///   - latitude: (**Required when location isn't provided**) The latitude of the location you want delivery from.
    ///   - longitude: (**Required when location isn't provided**) The longitude of the location you want delivery from.
    ///   - location: (**Required when latitude and longitude aren't provided**) The address of the location you want delivery from.
    ///   - term: (Optional) A search term to filter transaction results.
    ///   - categories: (Optional) Category filters using ``CDYelpCategoryAlias``.
    ///   - priceTiers: (Optional) Price filters using ``CDYelpPriceTier``.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func searchTransactions(
        byType type: CDYelpTransactionType,
        location: String?,
        latitude: Double?,
        longitude: Double?,
        term: String? = nil,
        categories: [CDYelpCategoryAlias]? = nil,
        priceTiers: [CDYelpPriceTier]? = nil
    ) async throws -> CDYelpSearchResponse.Transaction {
        precondition(
            (latitude != nil && longitude != nil) || location != nil,
            "Either a latitude and longitude or a location are required to query the Yelp Fusion API transactions endpoint."
        )
        let parameters = Parameters.transactionsParameters(
            withLocation: location,
            latitude: latitude,
            longitude: longitude,
            term: term,
            categories: categories,
            priceTiers: priceTiers
        )
        let router = CDYelpRouter.transactions(type: type.rawValue, parameters: parameters)
        return try await perform(router)
    }

    ///
    /// This endpoint returns the detail information of a business. To get a business id, refer to **searchBusinesses(byTerm: )**, **searchBusinesses(byPhoneNumber: )**, **searchTransactions(byType: )**, **searchBusinesses(byMatchType: )** or **autocompleteBusinesses(byText: )**. To get review information for a business, refer to **fetchReviews(forBusinessId: )**. At this time, this endpoint does not return businesses without any reviews.
    ///
    /// - parameters:
    ///   - id: (**Required**) The identifier of the business for the Yelp Fusion API to query.
    ///   - locale: (Optional) The interface locale; this determines the language of the business information returned.
    ///   - devicePlatform: (Optional) The device platform for the request.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchBusiness(
        forId id: String,
        locale: CDYelpLocale?,
        devicePlatform: String? = nil
    ) async throws -> CDYelpBusinessResponse {
        precondition(!id.isEmpty, "A business id is required to query the Yelp Fusion API business endpoint.")
        let parameters = Parameters.businessParameters(withLocale: locale, devicePlatform: devicePlatform)
        let router = CDYelpRouter.business(id: id, parameters: parameters)
        return try await perform(router)
    }

    ///
    /// This endpoint lets you match business data from other sources against businesses on Yelp, based on provided business information. For example, if you know a business's exact address and name, and you want to find that business and only that business on Yelp. At this time, the API does not return businesses without any reviews.
    ///
    /// - parameters:
    ///   - name: (**Required**) The name of the business. Maximum length is 64; only digits, letters, spaces, and !#$%&+,­./:?@'are allowed
    ///   - addressOne: (Optional) The first line of the business's address. Maximum length is 64; only digits, letters, spaces, and ­'/#&,.: are allowed.
    ///   - addressTwo: (Optional) The second line of the business's address. Maximum length is 64; only digits, letters, spaces, and ­'/#&,.: are allowed.
    ///   - addressThree: (Optional) The third line of the business's address. Maximum length is 64; only digits, letters, spaces, and ­'/#&,.: are allowed.
    ///   - city: (**Required**) The city of the business. Maximum length is 64; only digits, letters, spaces, and ­'.() are allowed.
    ///   - state: (**Required**) The ISO 3166-2 (with a few exceptions) state code of this business. Maximum length is 3.
    ///   - country: (**Required**) The ISO 3166-1 alpha-2 country code of this business. Maximum length is 2.
    ///   - latitude: (Optional) The WGS84 latitude of the business in decimal degrees. Must be between ­-90 and +90.
    ///   - longitude: (Optional) The WGS84 longitude of the business in decimal degrees. Must be between ­-180 and +180.
    ///   - phone: (Optional) The phone number of the business which can be submitted as (a) locally ­formatted with digits only (e.g., 016703080) or (b) internationally­ formatted with a leading + sign and digits only after (+35316703080). Maximum length is 32.
    ///   - zipCode: (Optional) The zip code of the business.
    ///   - yelpBusinessId: (Optional) Unique Yelp identifier of the business if available. Used as a hint when finding a matching business.
    ///   - limit: (Optional)
    ///   - matchThresholdType: (**Required**) Specifies whether a match quality threshold should be applied to the matched businesses. Use the **CDYelpBusinessMatchThresholdType** enum to get the list of supported thresholds.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func searchBusinesses(
        name: String,
        addressOne: String,
        addressTwo: String?,
        addressThree: String?,
        city: String,
        state: String,
        country: String,
        latitude: Double?,
        longitude: Double?,
        phone: String?,
        zipCode: String?,
        yelpBusinessId: String?,
        limit: Int?,
        matchThresholdType: CDYelpBusinessMatchThresholdType
    ) async throws -> CDYelpSearchResponse.BusinessMatch {
        precondition(!name.isEmpty && name.count <= 64, "A name (containing no more than 64 characters) is required to query the Yelp Fusion API business match endpoint.")
        precondition(!addressOne.isEmpty && addressOne.count <= 64, "addressOne must contain no more than 64 characters to query the Yelp Fusion API business match endpoint.")
        if let addressTwo {
            precondition(!addressTwo.isEmpty && addressTwo.count <= 64, "addressTwo must contain no more than 64 characters to query the Yelp Fusion API business match endpoint.")
        }
        if let addressThree {
            precondition(!addressThree.isEmpty && addressThree.count <= 64, "addressThree must contain no more than 64 characters to query the Yelp Fusion API business match endpoint.")
        }
        precondition(!city.isEmpty && city.count <= 64, "A city (no more than 64 characters) is required to query the Yelp Fusion API business match endpoint.")
        precondition(!state.isEmpty && state.count <= 3, "A state (containing no more than 3 characters) is required to query the Yelp Fusion API business match endpoint.")
        precondition(!country.isEmpty && country.count <= 2, "A country (containing no more than 2 characters) is required to query the Yelp Fusion API business match endpoint.")
        if let latitude {
            precondition(latitude >= -90.0 && latitude <= 90.0, "latitude must be between -90 and +90 to query the Yelp Fusion API business match endpoint.")
        }
        if let longitude {
            precondition(longitude >= -180.0 && longitude <= 180.0, "longitude must be between -180 and +180 to query the Yelp Fusion API business match endpoint.")
        }
        if let phone {
            precondition(!phone.isEmpty && phone.count <= 32, "phone must contain no more than 32 characters to query the Yelp Fusion API business match endpoint.")
        }
        if let limit {
            precondition(limit > 0 && limit <= 10, "The limit must be between 1 and 10 to query the Yelp Fusion API business match endpoint.")
        }
        precondition(!matchThresholdType.rawValue.isEmpty, "A match threshold type is required to query the Yelp Fusion API business match endpoint.")
        let parameters = Parameters.matchesParameters(
            withName: name,
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
            matchThresholdType: matchThresholdType
        )
        let router = CDYelpRouter.matches(parameters: parameters)
        return try await perform(router)
    }

    ///
    /// This endpoint returns the up to three reviews for a business.
    ///
    /// - parameters:
    ///   - id: (**Required**) The identifier of the business for the Yelp Fusion API to query.
    ///   - locale: (Optional) The interface locale; this determines the language for the reviews to return.
    ///   - offset: (Optional) A number the list of returned reviews should be offset by. **The maximum value is 1000**.
    ///   - limit: (Optional) The number of reviews to return. **The maximum value is 50**.
    ///   - sortBy: (Optional) The sort order for reviews. Defaults to `.yelpSort`.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchReviews(
        forBusinessId id: String,
        locale: CDYelpLocale?,
        offset: Int? = nil,
        limit: Int? = nil,
        sortBy: CDYelpReviewSortType? = nil
    ) async throws -> CDYelpReviewsResponse {
        precondition(!id.isEmpty, "A business id is required to query the Yelp Fusion API reviews endpoint.")
        if let offset {
            precondition(offset >= 0 && offset <= 1000, "offset must be between 0 and 1000.")
        }
        if let limit {
            precondition(limit >= 0 && limit <= 50, "The limit must be between 0 and 50.")
        }
        let parameters = Parameters.reviewsParameters(withLocale: locale, offset: offset, limit: limit, sortBy: sortBy)
        let router = CDYelpRouter.reviews(id: id, parameters: parameters)
        return try await perform(router, decoder: makeDecoder(dateFormat: DateFormatter.reviews))
    }

    ///
    /// This endpoint returns autocomplete suggestions for search keywords, businesses and categories, based on the input text.
    ///
    /// - parameters:
    ///   - text: (**Required**) The text for the Yelp Fusion API to query.
    ///   - latitude: (**Required**) The latitude of the location to look for business autocomplete suggestions.
    ///   - longitude: (**Required**) The longitude of the location to look for business autocomplete suggestions.
    ///   - locale: (Optional) The interface locale; this determines the language for the autocomplete suggestions to return.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func autocompleteBusinesses(
        byText text: String,
        latitude: Double,
        longitude: Double,
        locale: CDYelpLocale?
    ) async throws -> CDYelpAutoCompleteResponse {
        precondition(!text.isEmpty, "A search term is required to query the Yelp Fusion API autocomplete endpoint.")
        let parameters = Parameters.autocompleteParameters(withText: text, latitude: latitude, longitude: longitude, locale: locale)
        let router = CDYelpRouter.autocomplete(parameters: parameters)
        return try await perform(router)
    }

    // MARK: - Event Endpoints

    ///
    /// This endpoint returns the detailed information of a Yelp event. To get an event id, refer to **searchEvents(byLocale: )** or **fetchFeaturedEvent(forLocale: )**. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - id: (**Required**) The identifier of the event for the Yelp Fusion API to query.
    ///   - locale: (Optional) The locale to return the event information in.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchEvent(
        forId id: String,
        locale: CDYelpLocale?
    ) async throws -> CDYelpEventResponse {
        precondition(!id.isEmpty, "An event id is required to query the Yelp Fusion API event endpoint.")
        let parameters = Parameters.eventParameters(withLocale: locale)
        let router = CDYelpRouter.event(id: id, parameters: parameters)
        return try await perform(router, decoder: makeDecoder(dateFormat: DateFormatter.events))
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
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func searchEvents(
        byLocale locale: CDYelpLocale?,
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
        excludedEvents: [String]?
    ) async throws -> CDYelpEventsResponse {
        if let limit {
            precondition(limit > 0 && limit <= 50, "The limit must be 50 or less to query the Yelp Fusion API events endpoint.")
        }
        if let radius {
            precondition(radius > 0 && radius <= 40000, "The radius must be 40,000 meters or less to query the Yelp Fusion API events endpoint.")
        }
        let parameters = Parameters.eventsParameters(
            withLocale: locale,
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
            excludedEvents: excludedEvents
        )
        let router = CDYelpRouter.events(parameters: parameters)
        return try await perform(router, decoder: makeDecoder(dateFormat: DateFormatter.events))
    }

    ///
    /// This endpoint returns the featured event for a given location. Featured events are chosen by Yelp's community managers. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - locale: (Optional) The locale to return the event information in.
    ///   - location: Required unless latitude and longitude are both provided. Specifies the combination of "address, neighborhood, city, state or zip, optional country" to be used when querying the Yelp Fusion API for events.
    ///   - latitude: Required unless location is provided. Must be accompanied by longitude.
    ///   - longitude: Required unless location is provided. Must be accompanied by latitude.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchFeaturedEvent(
        forLocale locale: CDYelpLocale?,
        location: String?,
        latitude: Double?,
        longitude: Double?
    ) async throws -> CDYelpEventResponse {
        precondition(
            (latitude != nil && longitude != nil) || location != nil,
            "Either a latitude and longitude or a location are required to query the Yelp Fusion API featured event endpoint."
        )
        let parameters = Parameters.featuredEventParameters(
            withLocale: locale,
            location: location,
            latitude: latitude,
            longitude: longitude
        )
        let router = CDYelpRouter.featuredEvent(parameters: parameters)
        return try await perform(router, decoder: makeDecoder(dateFormat: DateFormatter.events))
    }

    // MARK: - Category Endpoints

    ///
    /// This endpoint returns all Yelp business categories across all locales by default. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - locale: (Optional) The locale to return the category information in.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchCategories(forLocale locale: CDYelpLocale?) async throws -> CDYelpCategoriesResponse {
        let parameters = Parameters.categoriesParameters(withLocale: locale)
        let router = CDYelpRouter.allCategories(parameters: parameters)
        return try await perform(router)
    }

    ///
    /// This endpoint returns detailed information about the Yelp category specified by a Yelp category alias.  To get a category alias, refer to **fetchCategories(forLocale: )**. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - alias: (**Required**) The alias to return category details for. Use the **CDYelpCategoryAlias** enum to get the list of supported category aliases.
    ///   - locale: (Optional) The locale to return the category information in.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchCategory(
        forAlias alias: CDYelpCategoryAlias,
        andLocale locale: CDYelpLocale?
    ) async throws -> CDYelpCategoryResponse {
        precondition(!alias.rawValue.isEmpty, "A category alias is required to query the Yelp Fusion API category details endpoint.")
        let parameters = Parameters.categoriesParameters(withLocale: locale)
        let router = CDYelpRouter.categoryDetails(alias: alias.rawValue, parameters: parameters)
        return try await perform(router)
    }

    ///
    /// Fetches AI chat response from the Yelp AI Chat endpoint.
    ///
    /// - parameters:
    ///   - query: (Required) A natural language query about local businesses. Maximum length is 1000 characters.
    ///   - chatId: (Optional) The ID of an existing chat to continue a multi-turn conversation.
    ///   - latitude: (Optional) The latitude of the user's location. Must be provided together with `longitude`, or not at all.
    ///   - longitude: (Optional) The longitude of the user's location. Must be provided together with `latitude`, or not at all.
    ///   - requestContext: (Optional) Additional key-value context for the request.
    ///
    /// - Precondition: `latitude` and `longitude` must both be `nil` or both be non-`nil`. Passing only one traps,
    ///   unlike prior versions, which silently dropped the lone coordinate. See the 6.0 migration guide.
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchAIChat(
        query: String,
        chatId: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        requestContext: [String: String]? = nil
    ) async throws -> CDYelpAIChatResponse {
        precondition(!query.isEmpty, "A query is required.")
        precondition(query.count <= 1000, "Query must be 1000 characters or fewer.")
        precondition(
            (latitude == nil) == (longitude == nil),
            "latitude and longitude must be provided together or not at all."
        )
        let userContext: CDYelpAIChatRequest.UserContext?
        if let latitude, let longitude {
            userContext = .init(latitude: latitude, longitude: longitude)
        } else {
            userContext = nil
        }
        let chatRequest = CDYelpAIChatRequest(
            query: query,
            chatId: chatId,
            userContext: userContext,
            requestContext: requestContext
        )
        let router = CDYelpRouter.aiChat(request: chatRequest)
        return try await perform(router)
    }

    ///
    /// Fetches engagement metrics for a list of businesses.
    ///
    /// - parameters:
    ///   - businessIds: (Required) A list of business IDs (1–20 required).
    ///   - dateRangeStart: (Optional) The start date for the metric date range.
    ///   - dateRangeEnd: (Optional) The end date for the metric date range.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchEngagementMetrics(
        forBusinessIds businessIds: [String],
        dateRangeStart: String? = nil,
        dateRangeEnd: String? = nil
    ) async throws -> CDYelpEngagementResponse {
        precondition(!businessIds.isEmpty && businessIds.count <= 20, "Between 1 and 20 business IDs are required.")
        let parameters = Parameters.engagementParameters(
            withBusinessIds: businessIds,
            dateRangeStart: dateRangeStart,
            dateRangeEnd: dateRangeEnd
        )
        let router = CDYelpRouter.engagement(parameters: parameters)
        return try await perform(router)
    }

    ///
    /// Fetches service offerings for a business.
    ///
    /// - parameters:
    ///   - id: (Required) The business ID.
    ///   - locale: (Optional) The desired language for the response.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchServiceOfferings(
        forBusinessId id: String,
        locale: CDYelpLocale? = nil
    ) async throws -> CDYelpServiceOfferingsResponse {
        precondition(!id.isEmpty, "A business ID is required.")
        let parameters = Parameters.businessParameters(withLocale: locale, devicePlatform: nil)
        let router = CDYelpRouter.serviceOfferings(id: id, parameters: parameters)
        return try await perform(router)
    }

    ///
    /// Fetches business insights for the provided business IDs.
    ///
    /// - parameters:
    ///   - businessIds: (Required) The business IDs for which to fetch insights. Must be between 1 and 20.
    ///   - dateRangeStart: (Required) Start date for the insights (format: YYYYMM).
    ///   - dateRangeEnd: (Required) End date for the insights (format: YYYYMM).
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchBusinessInsights(
        forBusinessIds businessIds: [String],
        dateRangeStart: String,
        dateRangeEnd: String
    ) async throws -> CDYelpBusinessInsightsResponse {
        precondition(!businessIds.isEmpty && businessIds.count <= 20, "Between 1 and 20 business IDs are required.")
        precondition(!dateRangeStart.isEmpty && !dateRangeEnd.isEmpty, "dateRangeStart and dateRangeEnd are required (format: YYYYMM).")
        let parameters = Parameters.businessInsightsParameters(
            withBusinessIds: businessIds,
            dateRangeStart: dateRangeStart,
            dateRangeEnd: dateRangeEnd
        )
        let router = CDYelpRouter.businessInsights(parameters: parameters)
        return try await perform(router)
    }

    ///
    /// Fetches review highlights for a business.
    ///
    /// - parameters:
    ///   - id: (Required) The business ID.
    ///   - count: (Optional) Number of highlights to return (1–5).
    ///   - locale: (Optional) The desired language for the response.
    ///   - devicePlatform: (Optional) The device platform for the request.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchReviewHighlights(
        forBusinessId id: String,
        count: Int? = nil,
        locale: CDYelpLocale? = nil,
        devicePlatform: String? = nil
    ) async throws -> CDYelpReviewHighlightsResponse {
        precondition(!id.isEmpty, "A business ID is required.")
        if let count {
            precondition(count >= 1 && count <= 5, "count must be between 1 and 5.")
        }
        let parameters = Parameters.reviewHighlightsParameters(count: count, locale: locale, devicePlatform: devicePlatform)
        let router = CDYelpRouter.reviewHighlights(id: id, parameters: parameters)
        return try await perform(router)
    }

    ///
    /// Fetches home services (jobs) for the provided query.
    ///
    /// - parameters:
    ///   - query: (Required) The search query (1–1000 characters).
    ///   - locale: (Optional) The desired language for the response.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchJobs(
        forQuery query: String,
        locale: CDYelpLocale? = nil
    ) async throws -> CDYelpJobsResponse {
        precondition(!query.isEmpty && query.count <= 1000, "A query of 1–1000 characters is required.")
        let router = CDYelpRouter.jobs(query: query, locale: locale?.rawValue)
        return try await perform(router)
    }

    ///
    /// Fetches available reservation openings for a business.
    ///
    /// - parameters:
    ///   - id: (Required) The business ID.
    ///   - covers: (Required) Party size (1–10).
    ///   - date: (Required) The desired date (format: YYYY-MM-DD).
    ///   - time: (Required) The desired time (format: HH:MM).
    ///   - getCoversRange: (Optional) Whether to include covers range information.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchOpenings(
        forBusinessId id: String,
        covers: Int,
        date: String,
        time: String,
        getCoversRange: Bool? = nil
    ) async throws -> CDYelpOpeningsResponse {
        precondition(!id.isEmpty, "A business ID is required.")
        precondition(covers >= 1 && covers <= 10, "covers must be between 1 and 10.")
        precondition(!date.isEmpty, "A date is required (format: YYYY-MM-DD).")
        precondition(!time.isEmpty, "A time is required (format: HH:MM).")
        let parameters = Parameters.openingsParameters(covers: covers, date: date, time: time, getCoversRange: getCoversRange)
        let router = CDYelpRouter.openings(businessId: id, parameters: parameters)
        return try await perform(router)
    }
}
