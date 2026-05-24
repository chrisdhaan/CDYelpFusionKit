//
//  CDYelpCoordinatesTests.swift
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

@Suite struct CDYelpCoordinatesTests {

    @Test func coordinatesDecodesFromJSON() throws {
        let json = """
        {
            "latitude": 37.7749,
            "longitude": -122.4194
        }
        """.data(using: .utf8)!
        let coordinates = try JSONDecoder().decode(CDYelpCoordinates.self, from: json)
        #expect(coordinates.latitude == 37.7749)
        #expect(coordinates.longitude == -122.4194)
    }

    @Test func coordinatesHandlesMissingOptionals() throws {
        let json = """
        {}
        """.data(using: .utf8)!
        let coordinates = try JSONDecoder().decode(CDYelpCoordinates.self, from: json)
        #expect(coordinates.latitude == nil)
        #expect(coordinates.longitude == nil)
    }

    @Test func coordinatesHandlesEquatorialCoordinates() throws {
        let json = """
        {
            "latitude": 0.0,
            "longitude": 0.0
        }
        """.data(using: .utf8)!
        let coordinates = try JSONDecoder().decode(CDYelpCoordinates.self, from: json)
        #expect(coordinates.latitude == 0.0)
        #expect(coordinates.longitude == 0.0)
    }

    @Test func coordinatesHandlesExtremeMeridians() throws {
        let json = """
        {
            "latitude": 90.0,
            "longitude": 180.0
        }
        """.data(using: .utf8)!
        let coordinates = try JSONDecoder().decode(CDYelpCoordinates.self, from: json)
        #expect(coordinates.latitude == 90.0)
        #expect(coordinates.longitude == 180.0)
    }

    @Test func coordinatesHandlesNegativeCoordinates() throws {
        let json = """
        {
            "latitude": -33.8688,
            "longitude": -151.2093
        }
        """.data(using: .utf8)!
        let coordinates = try JSONDecoder().decode(CDYelpCoordinates.self, from: json)
        #expect(coordinates.latitude == -33.8688)
        #expect(coordinates.longitude == -151.2093)
    }

    @Test func coordinatesHandlesPrecisionValues() throws {
        let json = """
        {
            "latitude": 37.7749310,
            "longitude": -122.4194155
        }
        """.data(using: .utf8)!
        let coordinates = try JSONDecoder().decode(CDYelpCoordinates.self, from: json)
        #expect(coordinates.latitude != nil)
        #expect(coordinates.longitude != nil)
    }
}
