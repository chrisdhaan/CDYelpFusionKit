//
//  Parameters+BusinessEndpoints.swift
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

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    // swiftlint:disable:next function_parameter_count
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
                                 jobAlias: String?) -> Parameters {
        var parameters: Parameters = [:]
        mergeSearchLocationParameters(into: &parameters, term: term, location: location, latitude: latitude,
                                      longitude: longitude, radius: radius, categories: categories, locale: locale)
        mergeSearchFilterParameters(into: &parameters, limit: limit, offset: offset, sortBy: sortBy,
                                    priceTiers: priceTiers, openNow: openNow, openAt: openAt, attributes: attributes)
        mergeSearchReservationParameters(into: &parameters, devicePlatform: devicePlatform, reservationDate: reservationDate,
                                         reservationTime: reservationTime, reservationCovers: reservationCovers,
                                         matchesPartySize: matchesPartySize, jobAlias: jobAlias)
        return parameters
    }

    private static func mergeSearchLocationParameters(into parameters: inout Parameters,
                                                      term: String?, location: String?, latitude: Double?,
                                                      longitude: Double?, radius: Int?,
                                                      categories: [CDYelpCategoryAlias]?, locale: CDYelpLocale?) {
        if let term,
           term != "" {
            parameters["term"] = term
        }
        if let location,
           location != "" {
            parameters["location"] = location
        }
        if let latitude {
            parameters["latitude"] = latitude
        }
        if let longitude {
            parameters["longitude"] = longitude
        }
        if let radius {
            parameters["radius"] = radius
        }
        if let categories,
           categories.count > 0 {
            parameters["categories"] = categories.map(\.rawValue).joined(separator: ",")
        }
        if let locale,
           locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }
    }

    private static func mergeSearchFilterParameters(into parameters: inout Parameters,
                                                    limit: Int?, offset: Int?, sortBy: CDYelpBusinessSortType?,
                                                    priceTiers: [CDYelpPriceTier]?, openNow: Bool?, openAt: Int?,
                                                    attributes: [CDYelpAttributeFilter]?) {
        if let limit {
            parameters["limit"] = limit
        }
        if let offset {
            parameters["offset"] = offset
        }
        if let sortBy,
           sortBy.rawValue != "" {
            parameters["sort_by"] = sortBy.rawValue
        }
        if let priceTiers,
           priceTiers.count > 0 {
            parameters["price"] = priceTiers.map(\.rawValue).joined(separator: ",")
        }
        if let openNow {
            parameters["open_now"] = openNow
        }
        if let openAt {
            parameters["open_at"] = openAt
        }
        if let attributes,
           attributes.count > 0 {
            parameters["attributes"] = attributes.map(\.rawValue).joined(separator: ",")
        }
    }

    private static func mergeSearchReservationParameters(into parameters: inout Parameters,
                                                         devicePlatform: String?, reservationDate: String?,
                                                         reservationTime: String?, reservationCovers: Int?,
                                                         matchesPartySize: Bool?, jobAlias: String?) {
        if let devicePlatform {
            parameters["device_platform"] = devicePlatform
        }
        if let reservationDate {
            parameters["reservation_date"] = reservationDate
        }
        if let reservationTime {
            parameters["reservation_time"] = reservationTime
        }
        if let reservationCovers {
            parameters["reservation_covers"] = reservationCovers
        }
        if let matchesPartySize {
            parameters["matches_party_size_param"] = matchesPartySize
        }
        if let jobAlias {
            parameters["job_alias"] = jobAlias
        }
    }

    static func phoneParameters(withPhoneNumber phoneNumber: String,
                                locale: CDYelpLocale?)
        -> Parameters {
        var parameters: Parameters = [:]
        parameters["phone"] = phoneNumber
        if let locale, locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }
        return parameters
    }

    static func transactionsParameters(withLocation location: String?,
                                       latitude: Double?,
                                       longitude: Double?,
                                       term: String?,
                                       categories: [CDYelpCategoryAlias]?,
                                       priceTiers: [CDYelpPriceTier]?)
        -> Parameters {
        var parameters: Parameters = [:]

        if let location, location != "" {
            parameters["location"] = location
        }
        if let latitude {
            parameters["latitude"] = latitude
        }
        if let longitude {
            parameters["longitude"] = longitude
        }
        if let term, term != "" {
            parameters["term"] = term
        }
        if let categories, !categories.isEmpty {
            parameters["categories"] = categories.map(\.rawValue).joined(separator: ",")
        }
        if let priceTiers, !priceTiers.isEmpty {
            parameters["price"] = priceTiers.map(\.rawValue).joined(separator: ",")
        }

        return parameters
    }

    static func businessParameters(withLocale locale: CDYelpLocale?,
                                   devicePlatform: String?)
        -> Parameters {
        var parameters: Parameters = [:]

        if let locale,
           locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }
        if let devicePlatform {
            parameters["device_platform"] = devicePlatform
        }

        return parameters
    }

    static func matchesParameters(withName name: String,
                                  addressOne: String?,
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
                                  matchThresholdType: CDYelpBusinessMatchThresholdType) -> Parameters {
        var parameters: Parameters = [:]
        mergeMatchesIdentityParameters(into: &parameters, name: name, addressOne: addressOne, addressTwo: addressTwo,
                                       addressThree: addressThree, city: city, state: state, country: country)
        mergeMatchesRemainingParameters(into: &parameters, latitude: latitude, longitude: longitude, phone: phone,
                                        zipCode: zipCode, yelpBusinessId: yelpBusinessId, limit: limit,
                                        matchThresholdType: matchThresholdType)
        return parameters
    }

    private static func mergeMatchesIdentityParameters(into parameters: inout Parameters,
                                                       name: String, addressOne: String?, addressTwo: String?,
                                                       addressThree: String?, city: String, state: String, country: String) {
        if !name.isEmpty {
            parameters["name"] = name
        }
        if let addressOne,
           addressOne != "" {
            parameters["address1"] = addressOne
        }
        if let addressTwo,
           addressTwo != "" {
            parameters["address2"] = addressTwo
        }
        if let addressThree,
           addressThree != "" {
            parameters["address3"] = addressThree
        }
        if !city.isEmpty {
            parameters["city"] = city
        }
        if !state.isEmpty {
            parameters["state"] = state
        }
        if !country.isEmpty {
            parameters["country"] = country
        }
    }

    private static func mergeMatchesRemainingParameters(into parameters: inout Parameters,
                                                        latitude: Double?, longitude: Double?, phone: String?,
                                                        zipCode: String?, yelpBusinessId: String?, limit: Int?,
                                                        matchThresholdType: CDYelpBusinessMatchThresholdType) {
        if let latitude {
            parameters["latitude"] = latitude
        }
        if let longitude {
            parameters["longitude"] = longitude
        }
        if let phone,
           phone != "" {
            parameters["phone"] = phone
        }
        if let postalCode = zipCode,
           postalCode != "" {
            parameters["postal_code"] = postalCode
        }
        if let yelpBusinessId,
           yelpBusinessId != "" {
            parameters["yelp_business_id"] = yelpBusinessId
        }
        if let limit {
            parameters["limit"] = limit
        }
        parameters["match_threshold"] = matchThresholdType.rawValue
    }

    static func reviewsParameters(withLocale locale: CDYelpLocale?,
                                  offset: Int?,
                                  limit: Int?,
                                  sortBy: CDYelpReviewSortType?)
        -> Parameters {
        var parameters: Parameters = [:]
        if let locale, locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }
        if let offset {
            parameters["offset"] = offset
        }
        if let limit {
            parameters["limit"] = limit
        }
        if let sortBy {
            parameters["sort_by"] = sortBy.rawValue
        }
        return parameters
    }

    static func autocompleteParameters(withText text: String,
                                       latitude: Double,
                                       longitude: Double,
                                       locale: CDYelpLocale?) -> Parameters {
        var parameters: Parameters = [:]

        if !text.isEmpty {
            parameters["text"] = text
        }
        parameters["latitude"] = latitude
        parameters["longitude"] = longitude
        if let locale,
           locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }

        return parameters
    }
}
