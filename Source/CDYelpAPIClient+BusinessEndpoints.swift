//
//  CDYelpAPIClient+BusinessEndpoints.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 8/29/26.
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

extension CDYelpAPIClient {

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
        validateBusinessMatchIdentity(name: name, addressOne: addressOne, addressTwo: addressTwo,
                                      addressThree: addressThree, city: city, state: state, country: country)
        validateBusinessMatchOptionalFields(latitude: latitude, longitude: longitude, phone: phone,
                                            limit: limit, matchThresholdType: matchThresholdType)
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

    private func validateBusinessMatchIdentity(name: String, addressOne: String, addressTwo: String?,
                                               addressThree: String?, city: String, state: String, country: String) {
        precondition(
            !name.isEmpty && name.count <= 64,
            "A name (containing no more than 64 characters) is required to query the Yelp Fusion API business match endpoint."
        )
        precondition(
            !addressOne.isEmpty && addressOne.count <= 64,
            "addressOne must contain no more than 64 characters to query the Yelp Fusion API business match endpoint."
        )
        if let addressTwo {
            precondition(
                !addressTwo.isEmpty && addressTwo.count <= 64,
                "addressTwo must contain no more than 64 characters to query the Yelp Fusion API business match endpoint."
            )
        }
        if let addressThree {
            precondition(
                !addressThree.isEmpty && addressThree.count <= 64,
                "addressThree must contain no more than 64 characters to query the Yelp Fusion API business match endpoint."
            )
        }
        precondition(
            !city.isEmpty && city.count <= 64,
            "A city (no more than 64 characters) is required to query the Yelp Fusion API business match endpoint."
        )
        precondition(
            !state.isEmpty && state.count <= 3,
            "A state (containing no more than 3 characters) is required to query the Yelp Fusion API business match endpoint."
        )
        precondition(
            !country.isEmpty && country.count <= 2,
            "A country (containing no more than 2 characters) is required to query the Yelp Fusion API business match endpoint."
        )
    }

    private func validateBusinessMatchOptionalFields(latitude: Double?, longitude: Double?, phone: String?,
                                                     limit: Int?, matchThresholdType: CDYelpBusinessMatchThresholdType) {
        if let latitude {
            precondition(
                latitude >= -90.0 && latitude <= 90.0,
                "latitude must be between -90 and +90 to query the Yelp Fusion API business match endpoint."
            )
        }
        if let longitude {
            precondition(
                longitude >= -180.0 && longitude <= 180.0,
                "longitude must be between -180 and +180 to query the Yelp Fusion API business match endpoint."
            )
        }
        if let phone {
            precondition(
                !phone.isEmpty && phone.count <= 32,
                "phone must contain no more than 32 characters to query the Yelp Fusion API business match endpoint."
            )
        }
        if let limit {
            precondition(
                limit > 0 && limit <= 10,
                "The limit must be between 1 and 10 to query the Yelp Fusion API business match endpoint."
            )
        }
        precondition(
            !matchThresholdType.rawValue.isEmpty,
            "A match threshold type is required to query the Yelp Fusion API business match endpoint."
        )
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
}
