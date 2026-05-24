//
//  CDYelpBusinessTests.swift
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

@Suite struct CDYelpBusinessTests {

    @Test func businessSearchDecodesFromJSON() throws {
        let json = """
        {
            "id": "WavvLdfdP6g8aZTtbBQHTw",
            "name": "Gary Danko",
            "rating": 4.5,
            "price": "$$$$",
            "is_closed": false
        }
        """.data(using: .utf8)!
        let business = try JSONDecoder().decode(CDYelpBusiness.BusinessSearch.self, from: json)
        #expect(business.id == "WavvLdfdP6g8aZTtbBQHTw")
        #expect(business.name == "Gary Danko")
        #expect(business.rating == 4.5)
    }

    @Test func businessSearchHandlesMissingOptionals() throws {
        let json = """
        {
            "id": "abc123",
            "name": "Test Restaurant"
        }
        """.data(using: .utf8)!
        let business = try JSONDecoder().decode(CDYelpBusiness.BusinessSearch.self, from: json)
        #expect(business.id == "abc123")
        #expect(business.rating == nil)
        #expect(business.price == nil)
    }
}
