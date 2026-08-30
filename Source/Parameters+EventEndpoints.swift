//
//  Parameters+EventEndpoints.swift
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
    static func eventParameters(withLocale locale: CDYelpLocale?) -> Parameters {
        var parameters: Parameters = [:]

        if let locale,
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
        mergeEventSortingParameters(into: &parameters, locale: locale, offset: offset, limit: limit, sortBy: sortBy,
                                    sortOn: sortOn, startDate: startDate, endDate: endDate, categories: categories, isFree: isFree)
        mergeEventLocationParameters(into: &parameters, location: location, latitude: latitude, longitude: longitude,
                                     radius: radius, excludedEvents: excludedEvents)
        return parameters
    }

    private static func mergeEventSortingParameters(into parameters: inout Parameters,
                                                    locale: CDYelpLocale?, offset: Int?, limit: Int?,
                                                    sortBy: CDYelpEventSortByType?, sortOn: CDYelpEventSortOnType?,
                                                    startDate: Date?, endDate: Date?,
                                                    categories: [CDYelpEventCategoryFilter]?, isFree: Bool?) {
        if let locale,
           locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }
        if let offset {
            parameters["offset"] = offset
        }
        if let limit {
            parameters["limit"] = limit
        }
        if let sortBy,
           sortBy.rawValue != "" {
            parameters["sort_by"] = sortBy.rawValue
        }
        if let sortOn,
           sortOn.rawValue != "" {
            parameters["sort_on"] = sortOn.rawValue
        }
        if let startDate {
            parameters["start_date"] = Int(startDate.timeIntervalSince1970)
        }
        if let endDate {
            parameters["end_date"] = Int(endDate.timeIntervalSince1970)
        }
        if let categories,
           categories.count > 0 {
            parameters["categories"] = categories.map(\.rawValue).joined(separator: ",")
        }
        if let isFree {
            parameters["is_free"] = isFree
        }
    }

    private static func mergeEventLocationParameters(into parameters: inout Parameters,
                                                     location: String?, latitude: Double?, longitude: Double?,
                                                     radius: Int?, excludedEvents: [String]?) {
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
        if let excludedEvents,
           !excludedEvents.isEmpty {
            parameters["excluded_events"] = excludedEvents.joined(separator: ",")
        }
    }

    static func featuredEventParameters(withLocale locale: CDYelpLocale?,
                                        location: String?,
                                        latitude: Double?,
                                        longitude: Double?) -> Parameters {
        var parameters: Parameters = [:]

        if let locale,
           locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
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

        return parameters
    }
}
