//
//  CDYelpLocationTests.swift
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

@Suite struct CDYelpLocationTests {

    @Test func locationDecodesFromJSON() throws {
        let json = """
        {
            "address1": "800 N Point St",
            "city": "San Francisco",
            "state": "CA",
            "zip_code": "94109",
            "country": "US"
        }
        """.data(using: .utf8)!
        let location = try JSONDecoder().decode(CDYelpLocation.self, from: json)
        #expect(location.addressOne == "800 N Point St")
        #expect(location.city == "San Francisco")
        #expect(location.state == "CA")
    }

    @Test func locationHandlesMissingOptionals() throws {
        let json = """
        {
            "city": "San Francisco"
        }
        """.data(using: .utf8)!
        let location = try JSONDecoder().decode(CDYelpLocation.self, from: json)
        #expect(location.city == "San Francisco")
        #expect(location.addressOne == nil)
        #expect(location.state == nil)
    }
}
