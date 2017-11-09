//
//  CDYelpRouter.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/10/16.
//
//  Copyright (c) 2016-2017 Christopher de Haan <contact@christopherdehaan.me>
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

enum CDYelpRouter: URLRequestConvertible {
    
    case search(parameters: Parameters)
    case phone(parameters: Parameters)
    case transactions(type: String, parameters: Parameters)
    case business(id: String, parameters: Parameters)
    case matches(type: String, parameters: Parameters)
    case reviews(id: String, parameters: Parameters)
    case autocomplete(parameters: Parameters)
    case event(id: String, parameters: Parameters)
    case events(parameters: Parameters)
    case featuredEvent(parameters: Parameters)
    
    var method: HTTPMethod {
        switch self {
        case .search(parameters: _),
             .phone(parameters: _),
             .transactions(type: _, parameters: _),
             .business(id: _, parameters: _),
             .matches(type: _, parameters: _),
             .reviews(id: _, parameters: _),
             .autocomplete(parameters: _),
             .event(id: _, parameters: _),
             .events(parameters: _),
             .featuredEvent(parameters: _):
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .search(parameters: _):
            return "businesses/search"
        case .phone(parameters: _):
            return "businesses/search/phone"
        case .transactions(let type, parameters: _):
            return "transactions/\(type)/search"
        case .business(let id, parameters: _):
            return "businesses/\(id)"
        case .matches(let type, parameters: _):
            return "businesses/matches/\(type)"
        case .reviews(let id, parameters: _):
            return "businesses/\(id)/reviews"
        case .autocomplete(parameters: _):
            return "autocomplete"
        case .event(let id, parameters: _):
            return "events/\(id)"
        case .events(parameters: _):
            return "events"
        case .featuredEvent(parameters: _):
            return "events/featured"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try CDYelpURL.base.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .search(let parameters),
             .phone(let parameters),
             .transactions(type: _, let parameters),
             .business(id: _, let parameters),
             .matches(type: _, let parameters),
             .reviews(id: _, let parameters),
             .autocomplete(let parameters),
             .event(id: _, let parameters),
             .events(let parameters),
             .featuredEvent(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        }
        
        return urlRequest
    }
}
