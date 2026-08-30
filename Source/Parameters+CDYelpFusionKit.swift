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
    static func categoriesParameters(withLocale locale: CDYelpLocale?) -> Parameters {
        var parameters: Parameters = [:]

        if let locale,
           locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }

        return parameters
    }

    static func engagementParameters(withBusinessIds businessIds: [String],
                                     dateRangeStart: String?,
                                     dateRangeEnd: String?)
        -> Parameters {
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
        -> Parameters {
        var parameters: Parameters = [:]
        parameters["business_ids"] = businessIds.joined(separator: ",")
        parameters["date_range_start"] = dateRangeStart
        parameters["date_range_end"] = dateRangeEnd
        return parameters
    }

    static func reviewHighlightsParameters(count: Int?,
                                           locale: CDYelpLocale?,
                                           devicePlatform: String?)
        -> Parameters {
        var parameters: Parameters = [:]
        if let count {
            parameters["count"] = count
        }
        if let locale, locale.rawValue != "" {
            parameters["locale"] = locale.rawValue
        }
        if let devicePlatform {
            parameters["device_platform"] = devicePlatform
        }
        return parameters
    }

    static func openingsParameters(covers: Int,
                                   date: String,
                                   time: String,
                                   getCoversRange: Bool?)
        -> Parameters {
        var parameters: Parameters = [:]
        parameters["covers"] = covers
        parameters["date"] = date
        parameters["time"] = time
        if let getCoversRange {
            parameters["get_covers_range"] = getCoversRange
        }
        return parameters
    }
}
