//
//  CDYelpBusinessResponseTests.swift
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

import Foundation
import Testing
@testable import CDYelpFusionKit

struct CDYelpBusinessResponseTests {
    @Test func businessResponseDecodesFromJSON() throws {
        let json = """
        {
            "business": {}
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpBusinessResponse.self, from: json)
        #expect(response.business != nil)
    }

    @Test func businessResponseHandlesMissingOptionals() throws {
        // CDYelpBusinessResponse decodes business from the root decoder directly.
        // With an empty JSON object, business is decoded as a Detailed with all nil fields.
        let json = """
        {}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpBusinessResponse.self, from: json)
        #expect(response.business?.id == nil)
        #expect(response.business?.name == nil)
        #expect(response.error?.code == nil)
    }

    @Test func businessResponseDecodesCompleteJSON() throws {
        // CDYelpBusinessResponse decodes business properties from the root level,
        // matching the Yelp Fusion /businesses/{id} API response format.
        let json = """
        {
            "id": "gary-danko-san-francisco",
            "name": "Gary Danko",
            "rating": 4.5,
            "is_closed": false
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpBusinessResponse.self, from: json)
        #expect(response.business?.id == "gary-danko-san-francisco")
        #expect(response.business?.name == "Gary Danko")
    }

    @Test func businessResponseDecodesRatingAndStatus() throws {
        let json = """
        {
            "id": "test-business",
            "rating": 4.5,
            "is_closed": true
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpBusinessResponse.self, from: json)
        #expect(response.business?.rating == 4.5)
        #expect(response.business?.isClosed == true)
    }
}
