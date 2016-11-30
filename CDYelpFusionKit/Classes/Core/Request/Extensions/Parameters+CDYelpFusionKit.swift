//
//  Parameters+CDYelpFusionKit.swift
//  Pods
//
//  Created by Chris De Haan on 11/10/16.
//
//  Copyright (c) 2016 Christopher de Haan <contact@christopherdehaan.me>
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

import UIKit

import Alamofire

internal extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    
    internal static func searchParameters(withTerm term: String?,
                                          location: String?,
                                          latitude: Double?,
                                          longitude: Double?,
                                          radius: Int?,
                                          categories: [String]?,
                                          locale: String?,
                                          limit: Int?,
                                          offset: Int?,
                                          sortBy: String?,
                                          price: String?,
                                          openNow: Bool?,
                                          openAt: Int?,
                                          attributes: [String]?) -> Parameters {
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
        // TODO: - categories
        if let locale = locale,
            locale != "" {
            params["locale"] = locale
        }
        if let limit = limit {
            params["limit"] = limit
        }
        if let offset = offset {
            params["offset"] = offset
        }
        if let sortBy = sortBy,
            sortBy != "" {
            params["sort_By"] = sortBy
        }
        if let price = price,
            price != "" {
            params["price"] = price
        }
        if let openNow = openNow {
            params["open_now"] = openNow
        }
        if let openAt = openAt {
            params["open_at"] = openAt
        }
        // TODO: - attributes
        
        return params
    }
    
    internal static func phoneParameters(withPhoneNumber phoneNumber: String!) -> Parameters {
        var params: Parameters = [:]
        
        if let phone = phoneNumber,
            phone != "" {
            params["phone"] = phone
        }
        
        return params
    }
    
    internal static func transactionsParameters(withLocation location: String?,
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
    
    internal static func reviewsParameters(withLocale locale: String?) -> Parameters {
        var params: Parameters = [:]
        
        if let locale = locale,
            locale != "" {
            params["locale"] = locale
        }
        
        return params
    }
    
    internal static func autocompleteParameters(withTerm term: String!,
                                                latitude: Double!,
                                                longitude: Double!,
                                                locale: String?) -> Parameters {
        var params: Parameters = [:]
        
        if let term = term,
            term != "" {
            params["term"] = term
        }
        if let latitude = latitude {
            params["latitude"] = latitude
        }
        if let longitude = longitude {
            params["longitude"] = longitude
        }
        if let locale = locale,
            locale != "" {
            params["locale"] = locale
        }
        
        return params
    }
}
