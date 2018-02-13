//
//  Parameters+CDYelpFusionKit.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/10/16.
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

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    
    static func searchParameters(withTerm term: String?,
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
                                 attributes: [CDYelpAttributeFilter]?) -> Parameters {
        var params: Parameters = [:]
        
        if let term = term,
            term != "" {
            params["term"] = term
        }
        if let location = location,
            location != "" {
            params["location"] = location
        }
        if let latitude = latitude {
            params["latitude"] = latitude
        }
        if let longitude = longitude {
            params["longitude"] = longitude
        }
        if let radius = radius {
            params["radius"] = radius
        }
        if let categories = categories,
            categories.count > 0 {
            
            var categoriesString = ""
            for category in categories {
                categoriesString = categoriesString + category.rawValue + ","
            }
            let parametersString = String(categoriesString[..<categoriesString.index(before: categoriesString.endIndex)])
            params["categories"] = parametersString
        }
        if let locale = locale,
            locale.rawValue != "" {
            params["locale"] = locale.rawValue
        }
        if let limit = limit {
            params["limit"] = limit
        }
        if let offset = offset {
            params["offset"] = offset
        }
        if let sortBy = sortBy,
            sortBy.rawValue != "" {
            params["sort_By"] = sortBy.rawValue
        }
        if let priceTiers = priceTiers,
            priceTiers.count > 0 {
            
            var priceString = ""
            for priceTier in priceTiers {
                priceString = priceString + priceTier.rawValue + ","
            }
            let parametersString = String(priceString[..<priceString.index(before: priceString.endIndex)])
            params["price"] = parametersString
        }
        if let openNow = openNow {
            params["open_now"] = openNow
        }
        if let openAt = openAt {
            params["open_at"] = openAt
        }
        if let attributes = attributes,
            attributes.count > 0 {
            
            var attributesString = ""
            for attribute in attributes {
                attributesString = attributesString + attribute.rawValue + ","
            }
            let parametersString = String(attributesString[..<attributesString.index(before: attributesString.endIndex)])
            params["attributes"] = parametersString
        }
        
        return params
    }
    
    static func phoneParameters(withPhoneNumber phoneNumber: String!) -> Parameters {
        var params: Parameters = [:]
        
        if let phone = phoneNumber,
            phone != "" {
            params["phone"] = phone
        }
        
        return params
    }
    
    static func transactionsParameters(withLocation location: String?,
                                       latitude: Double?,
                                       longitude: Double?) -> Parameters {
        var params: Parameters = [:]
        
        if let location = location,
            location != "" {
            params["location"] = location
        }
        if let latitude = latitude {
            params["latitude"] = latitude
        }
        if let longitude = longitude {
            params["longitude"] = longitude
        }
        
        return params
    }
    
    static func businessParameters(withLocale locale: CDYelpLocale?) -> Parameters {
        var params: Parameters = [:]
        
        if let locale = locale,
            locale.rawValue != "" {
            params["locale"] = locale.rawValue
        }
        
        return params
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
                                  postalCode: String?,
                                  yelpBusinessId: String?) -> Parameters {
        var params: Parameters = [:]
        
        if let name = name,
            name != "" {
            params["name"] = name
        }
        if let addressOne = addressOne,
            addressOne != "" {
            params["address1"] = addressOne
        }
        if let addressTwo = addressTwo,
            addressTwo != "" {
            params["address2"] = addressTwo
        }
        if let addressThree = addressThree,
            addressThree != "" {
            params["address3"] = addressThree
        }
        if let city = city,
            city != "" {
            params["city"] = city
        }
        if let state = state,
            state != "" {
            params["state"] = state
        }
        if let country = country,
            country != "" {
            params["country"] = country
        }
        if let latitude = latitude {
            params["latitude"] = latitude
        }
        if let longitude = longitude {
            params["longitude"] = longitude
        }
        if let phone = phone,
            phone != "" {
            params["phone"] = phone
        }
        if let postalCode = postalCode,
            postalCode != "" {
            params["postal_code"] = postalCode
        }
        if let yelpBusinessId = yelpBusinessId,
            yelpBusinessId != "" {
            params["yelp_business_id"] = yelpBusinessId
        }
        
        return params
    }
    
    static func reviewsParameters(withLocale locale: CDYelpLocale?) -> Parameters {
        var params: Parameters = [:]
        
        if let locale = locale,
            locale.rawValue != "" {
            params["locale"] = locale.rawValue
        }
        
        return params
    }
    
    static func autocompleteParameters(withText text: String!,
                                       latitude: Double!,
                                       longitude: Double!,
                                       locale: CDYelpLocale?) -> Parameters {
        var params: Parameters = [:]
        
        if let text = text,
            text != "" {
            params["text"] = text
        }
        if let latitude = latitude {
            params["latitude"] = latitude
        }
        if let longitude = longitude {
            params["longitude"] = longitude
        }
        if let locale = locale,
            locale.rawValue != "" {
            params["locale"] = locale.rawValue
        }
        
        return params
    }
    
    static func eventParameters(withLocale locale: CDYelpLocale?) -> Parameters {
        var params: Parameters = [:]
        
        if let locale = locale,
            locale.rawValue != "" {
            params["locale"] = locale.rawValue
        }
        
        return params
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
        var params: Parameters = [:]
        
        if let locale = locale,
            locale.rawValue != "" {
            params["locale"] = locale.rawValue
        }
        if let offset = offset {
            params["offset"] = offset
        }
        if let limit = limit {
            params["limit"] = limit
        }
        if let sortBy = sortBy,
            sortBy.rawValue != "" {
            params["sort_by"] = sortBy.rawValue
        }
        if let sortOn = sortOn,
            sortOn.rawValue != "" {
            params["sort_on"] = sortOn.rawValue
        }
        if let startDate = startDate {
            params["start_date"] = startDate.timeIntervalSince1970
        }
        if let endDate = endDate {
            params["end_date"] = endDate.timeIntervalSince1970
        }
        if let categories = categories,
            categories.count > 0 {
            
            var categoriesString = ""
            for category in categories {
                categoriesString = categoriesString + category.rawValue + ","
            }
            let parametersString = String(categoriesString[..<categoriesString.index(before: categoriesString.endIndex)])
            params["categories"] = parametersString
        }
        if let isFree = isFree {
            params["is_free"] = isFree
        }
        if let location = location,
            location != "" {
            params["location"] = location
        }
        if let latitude = latitude {
            params["latitude"] = latitude
        }
        if let longitude = longitude {
            params["longitude"] = longitude
        }
        if let radius = radius {
            params["radius"] = radius
        }
        if let excludedEvents = excludedEvents,
            excludedEvents.count > 0 {
            
            var excludedEventsString = ""
            for excludedEvent in excludedEvents {
                excludedEventsString = excludedEventsString + excludedEvent + ","
            }
            let parametersString = String(excludedEventsString[..<excludedEventsString.index(before: excludedEventsString.endIndex)])
            params["excluded_events"] = parametersString
        }
        
        return params
    }
    
    static func featuredEvent(withLocale locale: CDYelpLocale?,
                              location: String?,
                              latitude: Double?,
                              longitude: Double?) -> Parameters {
        var params: Parameters = [:]
        
        if let locale = locale,
            locale.rawValue != "" {
            params["locale"] = locale.rawValue
        }
        if let location = location,
            location != "" {
            params["location"] = location
        }
        if let latitude = latitude {
            params["latitude"] = latitude
        }
        if let longitude = longitude {
            params["longitude"] = longitude
        }
        
        return params
    }
}
