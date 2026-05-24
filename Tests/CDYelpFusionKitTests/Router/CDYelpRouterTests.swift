//
//  CDYelpRouterTests.swift
//  CDYelpFusionKitTests
//
//  Created by Christopher de Haan on 5/24/26.
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

import Testing
import Foundation
@testable import CDYelpFusionKit

@Suite struct CDYelpRouterTests {

    @Test func searchRouterProducesGetRequest() throws {
        let router = CDYelpRouter.search(parameters: ["term": "coffee", "location": "San Francisco"])
        let request = try router.asURLRequest()
        #expect(request.httpMethod == "GET")
        #expect(request.url?.host == "api.yelp.com")
    }

    @Test func businessRouterInterpolatesId() throws {
        let router = CDYelpRouter.business(id: "test-id-123", parameters: [:])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("test-id-123") == true)
    }

    @Test func searchRouterIncludesParameters() throws {
        let parameters = ["term": "pizza", "location": "New York", "limit": "10"]
        let router = CDYelpRouter.search(parameters: parameters)
        let request = try router.asURLRequest()
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("term") == true)
        #expect(urlString.contains("location") == true)
    }

    @Test func businessRouterConstructsCorrectPath() throws {
        let businessId = "gary-danko-san-francisco"
        let router = CDYelpRouter.business(id: businessId, parameters: [:])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains(businessId) == true)
    }

    @Test func routerProducesValidURL() throws {
        let router = CDYelpRouter.search(parameters: ["term": "restaurants"])
        let request = try router.asURLRequest()
        #expect(request.url?.scheme == "https")
        #expect(request.url?.host == "api.yelp.com")
    }

    @Test func routerHandlesEmptyParameters() throws {
        let router = CDYelpRouter.search(parameters: [:])
        let request = try router.asURLRequest()
        #expect(request.httpMethod == "GET")
        #expect(request.url != nil)
    }
}
