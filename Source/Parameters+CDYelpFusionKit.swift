//
//  Parameters+CDYelpFusionKit.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/10/16.
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

typealias Parameters = [String: Any]

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
                                 jobAlias: String?) -> Parameters
    {
        var parameters: Parameters = [:]

        if let term = term,
           term != ""
        {
            parameters["term"] = term
        }
        if let location = location,
           location != ""
        {
            parameters["location"] = location
        }
        if let latitude = latitude {
            parameters["latitude"] = latitude
        }
        if let longitude = longitude {
            parameters["longitude"] = longitude
        }
        if let radius = radius {
            parameters["radius"] = radius
        }
        if let categories = categories,
           categories.count > 0
        {
            parameters["categories"] = categories.map { $0.rawValue }.joined(separator: ",")
        }
        if let locale = locale,
           locale.rawValue != ""
        {
            parameters["locale"] = locale.rawValue
        }
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let offset = offset {
            parameters["offset"] = offset
        }
        if let sortBy = sortBy,
           sortBy.rawValue != ""
        {
            parameters["sort_by"] = sortBy.rawValue
        }
        if let priceTiers = priceTiers,
           priceTiers.count > 0
        {
            parameters["price"] = priceTiers.map { $0.rawValue }.joined(separator: ",")
        }
        if let openNow = openNow {
            parameters["open_now"] = openNow
        }
        if let openAt = openAt {
            parameters["open_at"] = openAt
        }
        if let attributes = attributes,
           attributes.count > 0
        {
            parameters["attributes"] = attributes.map { $0.rawValue }.joined(separator: ",")
        }
        if let devicePlatform = devicePlatform {
            parameters["device_platform"] = devicePlatform
        }
        if let reservationDate = reservationDate {
            parameters["reservation_date"] = reservationDate
        }
        if let reservationTime = reservationTime {
            parameters["reservation_time"] = reservationTime
        }
        if let reservationCovers = reservationCovers {
            parameters["reservation_covers"] = reservationCovers
        }
        if let matchesPartySize = matchesPartySize {
            parameters["matches_party_size_param"] = matchesPartySize
        }
        if let jobAlias = jobAlias {
            parameters["job_alias"] = jobAlias
        }

        return parameters
    }

    static func phoneParameters(withPhoneNumber phoneNumber: String,
                                locale: CDYelpLocale?)
        -> Parameters
    {
        var parameters: Parameters = [:]
        parameters["phone"] = phoneNumber
        if let locale = locale, locale.rawValue != "" {
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
        -> Parameters
    {
        var parameters: Parameters = [:]

        if let location = location, location != "" {
            parameters["location"] = location
        }
        if let latitude = latitude {
            parameters["latitude"] = latitude
        }
        if let longitude = longitude {
            parameters["longitude"] = longitude
        }
        if let term = term, term != "" {
            parameters["term"] = term
        }
        if let categories = categories, !categories.isEmpty {
            parameters["categories"] = categories.map { $0.rawValue }.joined(separator: ",")
        }
        if let priceTiers = priceTiers, !priceTiers.isEmpty {
            parameters["price"] = priceTiers.map { $0.rawValue }.joined(separator: ",")
        }

        return parameters
    }

    static func businessParameters(withLocale locale: CDYelpLocale?,
                                   devicePlatform: String?)
        -> Parameters
    {
        var parameters: Parameters = [:]

        if let locale = locale,
           locale.rawValue != ""
        {
            parameters["locale"] = locale.rawValue
        }
        if let devicePlatform = devicePlatform {
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
                                  matchThresholdType: CDYelpBusinessMatchThresholdType) -> Parameters
    {
        var parameters: Parameters = [:]

        if !name.isEmpty {
            parameters["name"] = name
        }
        if let addressOne = addressOne,
           addressOne != ""
        {
            parameters["address1"] = addressOne
        }
        if let addressTwo = addressTwo,
           addressTwo != ""
        {
            parameters["address2"] = addressTwo
        }
        if let addressThree = addressThree,
           addressThree != ""
        {
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
        if let latitude = latitude {
            parameters["latitude"] = latitude
        }
        if let longitude = longitude {
            parameters["longitude"] = longitude
        }
        if let phone = phone,
           phone != ""
        {
            parameters["phone"] = phone
        }
        if let postalCode = zipCode,
           postalCode != ""
        {
            parameters["postal_code"] = postalCode
        }
        if let yelpBusinessId = yelpBusinessId,
           yelpBusinessId != ""
        {
            parameters["yelp_business_id"] = yelpBusinessId
        }
        if let limit = limit {
            parameters["limit"] = limit
        }
        parameters["match_threshold"] = matchThresholdType.rawValue

        return parameters
    }

    static func reviewsParameters(withLocale locale: CDYelpLocale?,
                                  offset: Int?,
                                  limit: Int?,
                                  sortBy: CDYelpReviewSortType?)
        -> Parameters
    {
        var parameters: Parameters = [:]
        if let locale = locale, locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }
        if let offset = offset {
            parameters["offset"] = offset
        }
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let sortBy = sortBy {
            parameters["sort_by"] = sortBy.rawValue
        }
        return parameters
    }

    static func autocompleteParameters(withText text: String,
                                       latitude: Double,
                                       longitude: Double,
                                       locale: CDYelpLocale?) -> Parameters
    {
        var parameters: Parameters = [:]

        if !text.isEmpty {
            parameters["text"] = text
        }
        parameters["latitude"] = latitude
        parameters["longitude"] = longitude
        if let locale = locale,
           locale.rawValue != ""
        {
            parameters["locale"] = locale.rawValue
        }

        return parameters
    }

    static func eventParameters(withLocale locale: CDYelpLocale?) -> Parameters {
        var parameters: Parameters = [:]

        if let locale = locale,
           locale.rawValue != ""
        {
            parameters["locale"] = locale.rawValue
        }

        return parameters
    }

    static func eventsParameters(withLocale locale: CDYelpLocale?,
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
                                 excludedEvents: [String]?) -> Parameters
    {
        var parameters: Parameters = [:]

        if let locale = locale,
           locale.rawValue != ""
        {
            parameters["locale"] = locale.rawValue
        }
        if let offset = offset {
            parameters["offset"] = offset
        }
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let sortBy = sortBy,
           sortBy.rawValue != ""
        {
            parameters["sort_by"] = sortBy.rawValue
        }
        if let sortOn = sortOn,
           sortOn.rawValue != ""
        {
            parameters["sort_on"] = sortOn.rawValue
        }
        if let startDate = startDate {
            parameters["start_date"] = Int(startDate.timeIntervalSince1970)
        }
        if let endDate = endDate {
            parameters["end_date"] = Int(endDate.timeIntervalSince1970)
        }
        if let categories = categories,
           categories.count > 0
        {
            parameters["categories"] = categories.map { $0.rawValue }.joined(separator: ",")
        }
        if let isFree = isFree {
            parameters["is_free"] = isFree
        }
        if let location = location,
           location != ""
        {
            parameters["location"] = location
        }
        if let latitude = latitude {
            parameters["latitude"] = latitude
        }
        if let longitude = longitude {
            parameters["longitude"] = longitude
        }
        if let radius = radius {
            parameters["radius"] = radius
        }
        if let excludedEvents = excludedEvents,
           !excludedEvents.isEmpty
        {
            parameters["excluded_events"] = excludedEvents.joined(separator: ",")
        }

        return parameters
    }

    static func featuredEventParameters(withLocale locale: CDYelpLocale?,
                                        location: String?,
                                        latitude: Double?,
                                        longitude: Double?) -> Parameters
    {
        var parameters: Parameters = [:]

        if let locale = locale,
           locale.rawValue != ""
        {
            parameters["locale"] = locale.rawValue
        }
        if let location = location,
           location != ""
        {
            parameters["location"] = location
        }
        if let latitude = latitude {
            parameters["latitude"] = latitude
        }
        if let longitude = longitude {
            parameters["longitude"] = longitude
        }

        return parameters
    }

    static func categoriesParameters(withLocale locale: CDYelpLocale?) -> Parameters {
        var parameters: Parameters = [:]

        if let locale = locale,
           locale.rawValue != ""
        {
            parameters["locale"] = locale.rawValue
        }

        return parameters
    }

    static func engagementParameters(withBusinessIds businessIds: [String],
                                     dateRangeStart: String?,
                                     dateRangeEnd: String?)
        -> Parameters
    {
        var parameters: Parameters = [:]
        parameters["business_ids"] = businessIds.joined(separator: ",")
        if let start = dateRangeStart {
            parameters["date_range_start"] = start
        }
        if let end = dateRangeEnd {
            parameters["date_range_end"] = end
        }
        return parameters
    }

    static func businessInsightsParameters(withBusinessIds businessIds: [String],
                                           dateRangeStart: String,
                                           dateRangeEnd: String)
        -> Parameters
    {
        var parameters: Parameters = [:]
        parameters["business_ids"] = businessIds.joined(separator: ",")
        parameters["date_range_start"] = dateRangeStart
        parameters["date_range_end"] = dateRangeEnd
        return parameters
    }

    static func reviewHighlightsParameters(count: Int?,
                                           locale: CDYelpLocale?,
                                           devicePlatform: String?)
        -> Parameters
    {
        var parameters: Parameters = [:]
        if let count = count {
            parameters["count"] = count
        }
        if let locale = locale, locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }
        if let devicePlatform = devicePlatform {
            parameters["device_platform"] = devicePlatform
        }
        return parameters
    }

    static func openingsParameters(covers: Int,
                                   date: String,
                                   time: String,
                                   getCoversRange: Bool?)
        -> Parameters
    {
        var parameters: Parameters = [:]
        parameters["covers"] = covers
        parameters["date"] = date
        parameters["time"] = time
        if let getCoversRange = getCoversRange {
            parameters["get_covers_range"] = getCoversRange
        }
        return parameters
    }
}
