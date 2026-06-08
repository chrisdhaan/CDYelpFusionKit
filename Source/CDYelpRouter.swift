//
//  CDYelpRouter.swift
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

import Alamofire

enum CDYelpRouter: URLRequestConvertible {
    case search(parameters: Parameters)
    case phone(parameters: Parameters)
    case transactions(type: String, parameters: Parameters)
    case business(id: String, parameters: Parameters)
    case matches(parameters: Parameters)
    case reviews(id: String, parameters: Parameters)
    case autocomplete(parameters: Parameters)
    case event(id: String, parameters: Parameters)
    case events(parameters: Parameters)
    case featuredEvent(parameters: Parameters)
    case allCategories(parameters: Parameters)
    case categoryDetails(alias: String, parameters: Parameters)
    case aiChat(request: CDYelpAIChatRequest)
    case engagement(parameters: Parameters)
    case serviceOfferings(id: String, parameters: Parameters)
    case businessInsights(parameters: Parameters)
    case reviewHighlights(id: String, parameters: Parameters)

    var method: HTTPMethod {
        switch self {
        case .search, .phone, .transactions, .business, .matches, .reviews, .autocomplete, .event, .events,
             .featuredEvent, .allCategories, .categoryDetails, .engagement, .serviceOfferings, .businessInsights,
             .reviewHighlights:
            return .get
        case .aiChat:
            return .post
        }
    }

    var path: String {
        switch self {
        case .search:
            return "businesses/search"
        case .phone:
            return "businesses/search/phone"
        case let .transactions(type, _):
            return "transactions/\(type)/search"
        case let .business(id, _):
            return "businesses/\(id)"
        case .matches:
            return "businesses/matches"
        case let .reviews(id, _):
            return "businesses/\(id)/reviews"
        case .autocomplete:
            return "autocomplete"
        case let .event(id, _):
            return "events/\(id)"
        case .events:
            return "events"
        case .featuredEvent:
            return "events/featured"
        case .allCategories:
            return "categories"
        case let .categoryDetails(alias, _):
            return "categories/\(alias)"
        case .aiChat:
            return "ai/chat/v2"
        case .engagement:
            return "businesses/engagement"
        case let .serviceOfferings(id, _):
            return "businesses/\(id)/service_offerings"
        case .businessInsights:
            return "businesses/insights"
        case let .reviewHighlights(id, _):
            return "businesses/\(id)/review_highlights"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try CDYelpURL.base.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        // Handle POST + JSON body cases before URL-encoding switch
        if case let .aiChat(request) = self {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(request)
            return urlRequest
        }

        switch self {
        case let .search(parameters),
             let .phone(parameters),
             .transactions(type: _, let parameters),
             .business(id: _, let parameters),
             let .matches(parameters),
             .reviews(id: _, let parameters),
             let .autocomplete(parameters),
             .event(id: _, let parameters),
             let .events(parameters),
             let .featuredEvent(parameters),
             let .allCategories(parameters),
             .categoryDetails(alias: _, let parameters),
             let .engagement(parameters),
             .serviceOfferings(id: _, let parameters),
             let .businessInsights(parameters),
             .reviewHighlights(id: _, let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .aiChat:
            break
        }

        return urlRequest
    }
}
