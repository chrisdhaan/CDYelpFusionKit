//
//  CDYelpRouter.swift
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

fileprivate let CDYelpBaseURL = "https://api.yelp.com/v3/"

internal enum CDYelpRouter: URLRequestConvertible {
    
    case search(parameters: Parameters)
    case phone(parameters: Parameters)
    case transactions(type: String, parameters: Parameters)
    case business(id: String)
    case reviews(id: String, parameters: Parameters)
    case autocomplete(parameters: Parameters)
    
    var method: HTTPMethod {
        switch self {
        case .search(parameters: _),
             .phone(parameters: _),
             .transactions(type: _, parameters: _),
             .business(id: _),
             .reviews(id: _, parameters: _),
             .autocomplete(parameters: _):
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
        case .business(let id):
            return "businesses/\(id)"
        case .reviews(let id, parameters: _):
            return "businesses/\(id)/reviews"
        case .autocomplete(parameters: _):
            return "autocomplete"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try CDYelpBaseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .search(let parameters),
             .phone(let parameters),
             .transactions(type: _, let parameters),
             .reviews(id: _, let parameters),
             .autocomplete(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .business(id: _):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        }
        
        return urlRequest
    }
}
