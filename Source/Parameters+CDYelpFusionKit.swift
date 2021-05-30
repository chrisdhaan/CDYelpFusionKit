//
//  Parameters+CDYelpFusionKit.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/10/16.
//
//  Copyright © 2016-2021 Christopher de Haan <contact@christopherdehaan.me>
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

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {

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
                                 attributes: [CDYelpAttributeFilter]?) -> Parameters {
        var parameters: Parameters = [:]

        if let term = term,
            term != "" {
            parameters["term"] = term
        }
        if let location = location,
            location != "" {
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
            categories.count > 0 {
            parameters["categories"] = categories.map { $0.rawValue }.joined(separator: ",")
        }
        if let locale = locale,
            locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let offset = offset {
            parameters["offset"] = offset
        }
        if let sortBy = sortBy,
            sortBy.rawValue != "" {
            parameters["sort_by"] = sortBy.rawValue
        }
        if let priceTiers = priceTiers,
            priceTiers.count > 0 {
            parameters["price"] = priceTiers.map { $0.rawValue }.joined(separator: ",")
        }
        if let openNow = openNow {
            parameters["open_now"] = openNow
        }
        if let openAt = openAt {
            parameters["open_at"] = openAt
        }
        if let attributes = attributes,
            attributes.count > 0 {

            var attributesString = ""
            for attribute in attributes {
                attributesString += attribute.rawValue + ","
            }
            let parametersString = String(attributesString[..<attributesString.index(before: attributesString.endIndex)])
            parameters["attributes"] = parametersString
        }

        return parameters
    }

    static func phoneParameters(withPhoneNumber phoneNumber: String!) -> Parameters {
        var parameters: Parameters = [:]

        parameters["phone"] = phoneNumber

        return parameters
    }

    static func transactionsParameters(withLocation location: String?,
                                       latitude: Double?,
                                       longitude: Double?) -> Parameters {
        var parameters: Parameters = [:]

        if let location = location,
            location != "" {
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

    static func businessParameters(withLocale locale: CDYelpLocale?) -> Parameters {
        var parameters: Parameters = [:]

        if let locale = locale,
            locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }

        return parameters
    }

    static func matchesParameters(withName name: String!,
                                  addressOne: String?,
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
                                  matchThresholdType: CDYelpBusinessMatchThresholdType!) -> Parameters {
        var parameters: Parameters = [:]

        if let name = name,
            name != "" {
            parameters["name"] = name
        }
        if let addressOne = addressOne,
            addressOne != "" {
            parameters["address1"] = addressOne
        }
        if let addressTwo = addressTwo,
            addressTwo != "" {
            parameters["address2"] = addressTwo
        }
        if let addressThree = addressThree,
            addressThree != "" {
            parameters["address3"] = addressThree
        }
        if let city = city,
            city != "" {
            parameters["city"] = city
        }
        if let state = state,
            state != "" {
            parameters["state"] = state
        }
        if let country = country,
            country != "" {
            parameters["country"] = country
        }
        if let latitude = latitude {
            parameters["latitude"] = latitude
        }
        if let longitude = longitude {
            parameters["longitude"] = longitude
        }
        if let phone = phone,
            phone != "" {
            parameters["phone"] = phone
        }
        if let postalCode = zipCode,
            postalCode != "" {
            parameters["postal_code"] = postalCode
        }
        if let yelpBusinessId = yelpBusinessId,
            yelpBusinessId != "" {
            parameters["yelp_business_id"] = yelpBusinessId
        }
        if let limit = limit {
            parameters["limit"] = limit
        }
        parameters["match_threshold"] = matchThresholdType.rawValue

        return parameters
    }

    static func reviewsParameters(withLocale locale: CDYelpLocale?) -> Parameters {
        var parameters: Parameters = [:]

        if let locale = locale,
            locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }

        return parameters
    }

    static func autocompleteParameters(withText text: String!,
                                       latitude: Double!,
                                       longitude: Double!,
                                       locale: CDYelpLocale?) -> Parameters {
        var parameters: Parameters = [:]

        if let text = text,
            text != "" {
            parameters["text"] = text
        }
        if let latitude = latitude {
            parameters["latitude"] = latitude
        }
        if let longitude = longitude {
            parameters["longitude"] = longitude
        }
        if let locale = locale,
            locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }

        return parameters
    }

    static func eventParameters(withLocale locale: CDYelpLocale?) -> Parameters {
        var parameters: Parameters = [:]

        if let locale = locale,
            locale.rawValue != "" {
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
                                 excludedEvents: [String]?) -> Parameters {
        var parameters: Parameters = [:]

        if let locale = locale,
            locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }
        if let offset = offset {
            parameters["offset"] = offset
        }
        if let limit = limit {
            parameters["limit"] = limit
        }
        if let sortBy = sortBy,
            sortBy.rawValue != "" {
            parameters["sort_by"] = sortBy.rawValue
        }
        if let sortOn = sortOn,
            sortOn.rawValue != "" {
            parameters["sort_on"] = sortOn.rawValue
        }
        if let startDate = startDate {
            parameters["start_date"] = startDate.timeIntervalSince1970
        }
        if let endDate = endDate {
            parameters["end_date"] = endDate.timeIntervalSince1970
        }
        if let categories = categories,
            categories.count > 0 {

            var categoriesString = ""
            for category in categories {
                categoriesString += category.rawValue + ","
            }
            let parametersString = String(categoriesString[..<categoriesString.index(before: categoriesString.endIndex)])
            parameters["categories"] = parametersString
        }
        if let isFree = isFree {
            parameters["is_free"] = isFree
        }
        if let location = location,
            location != "" {
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
            excludedEvents.count > 0 {

            var excludedEventsString = ""
            for excludedEvent in excludedEvents {
                excludedEventsString += excludedEvent + ","
            }
            let parametersString = String(excludedEventsString[..<excludedEventsString.index(before: excludedEventsString.endIndex)])
            parameters["excluded_events"] = parametersString
        }

        return parameters
    }

    static func featuredEventParameters(withLocale locale: CDYelpLocale?,
                                        location: String?,
                                        latitude: Double?,
                                        longitude: Double?) -> Parameters {
        var parameters: Parameters = [:]

        if let locale = locale,
            locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }
        if let location = location,
            location != "" {
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
            locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }

        return parameters
    }
}
