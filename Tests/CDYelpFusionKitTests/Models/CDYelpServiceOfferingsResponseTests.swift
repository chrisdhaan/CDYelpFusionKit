//
//  CDYelpServiceOfferingsResponseTests.swift
//  CDYelpFusionKitTests
//
//  Created by Christopher de Haan on 6/8/26.
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

@testable import CDYelpFusionKit
import Foundation
import Testing

@Suite(.serialized) struct CDYelpServiceOfferingsResponseTests {
    @Test func responseDecodesFromJSON() throws {
        let json = """
        {
            "service_offerings": [
                {
                    "id": "offer-1",
                    "name": "Catering",
                    "description": "Full-service catering for events.",
                    "url": "https://www.yelp.com/biz/example"
                }
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpServiceOfferingsResponse.self, from: json)
        #expect(response.serviceOfferings?.count == 1)
        let offering = response.serviceOfferings?.first
        #expect(offering?.id == "offer-1")
        #expect(offering?.name == "Catering")
        #expect(offering?.description == "Full-service catering for events.")
    }

    @Test func responseHandlesEmptyOfferings() throws {
        let json = """
        { "service_offerings": [] }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpServiceOfferingsResponse.self, from: json)
        #expect(response.serviceOfferings?.isEmpty == true)
    }

    @Test func responseHandlesMissingOptionals() throws {
        let json = "{}".data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpServiceOfferingsResponse.self, from: json)
        #expect(response.serviceOfferings == nil)
        #expect(response.error == nil)
    }

    @Test func responseDecodesSnakeCaseServiceOfferings() throws {
        let json = """
        { "service_offerings": [{ "id": "s1" }] }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpServiceOfferingsResponse.self, from: json)
        #expect(response.serviceOfferings?.first?.id == "s1")
    }

    @Test func offeringHandlesMissingOptionals() throws {
        let json = "{}".data(using: .utf8)!
        let offering = try JSONDecoder().decode(CDYelpServiceOffering.self, from: json)
        #expect(offering.id == nil)
        #expect(offering.name == nil)
        #expect(offering.description == nil)
        #expect(offering.url == nil)
    }
}
