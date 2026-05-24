//
//  CDYelpSearchResponseTests.swift
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

@Suite struct CDYelpSearchResponseTests {

    @Test func searchResponseDecodesFromJSON() throws {
        let json = """
        {
            "businesses": [],
            "total": 0
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpSearchResponse.self, from: json)
        #expect(response.businesses != nil)
        #expect(response.total == 0)
    }

    @Test func searchResponseHandlesMissingOptionals() throws {
        let json = """
        {}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpSearchResponse.self, from: json)
        #expect(response.businesses == nil)
        #expect(response.total == nil)
    }

    @Test func searchResponseDecodesWithBusinesses() throws {
        let json = """
        {
            "businesses": [
                {
                    "id": "business1",
                    "name": "Restaurant A"
                },
                {
                    "id": "business2",
                    "name": "Restaurant B"
                }
            ],
            "total": 2
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpSearchResponse.self, from: json)
        #expect(response.businesses?.count == 2)
        #expect(response.total == 2)
    }

    @Test func searchResponseDecodesLargeTotal() throws {
        let json = """
        {
            "businesses": [],
            "total": 1000
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpSearchResponse.self, from: json)
        #expect(response.total == 1000)
    }

    @Test func searchResponseHandlesRegionData() throws {
        let json = """
        {
            "region": {
                "center": {
                    "latitude": 37.7749,
                    "longitude": -122.4194
                }
            },
            "businesses": [],
            "total": 0
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpSearchResponse.self, from: json)
        #expect(response.region != nil)
    }
}
