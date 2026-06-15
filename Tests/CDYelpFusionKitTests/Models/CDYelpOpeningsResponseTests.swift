//
//  CDYelpOpeningsResponseTests.swift
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

@Suite(.serialized) struct CDYelpOpeningsResponseTests {
    @Test func responseDecodesFromJSON() throws {
        let json = """
        {
            "reservation_times": [
                {
                    "date": "2026-06-15",
                    "times": [
                        { "time": "18:00", "credit_card_required": true },
                        { "time": "19:00", "credit_card_required": false }
                    ]
                }
            ],
            "covers_range": {
                "min_party_size": 1,
                "max_party_size": 8
            }
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpOpeningsResponse.self, from: json)
        #expect(response.reservationTimes?.count == 1)
        let day = response.reservationTimes?.first
        #expect(day?.date == "2026-06-15")
        #expect(day?.times?.count == 2)
        #expect(day?.times?.first?.time == "18:00")
        #expect(day?.times?.first?.creditCardRequired == true)
        #expect(response.coversRange?.minPartySize == 1)
        #expect(response.coversRange?.maxPartySize == 8)
    }

    @Test func responseHandlesMissingOptionals() throws {
        let json = "{}".data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpOpeningsResponse.self, from: json)
        #expect(response.reservationTimes == nil)
        #expect(response.coversRange == nil)
        #expect(response.error == nil)
    }

    @Test func reservationTimeDecodesSnakeCaseCreditCardRequired() throws {
        let json = """
        { "time": "20:00", "credit_card_required": true }
        """.data(using: .utf8)!
        let time = try JSONDecoder().decode(CDYelpReservationTime.self, from: json)
        #expect(time.time == "20:00")
        #expect(time.creditCardRequired == true)
    }

    @Test func coversRangeDecodesSnakeCaseFields() throws {
        let json = """
        { "min_party_size": 2, "max_party_size": 6 }
        """.data(using: .utf8)!
        let range = try JSONDecoder().decode(CDYelpCoversRange.self, from: json)
        #expect(range.minPartySize == 2)
        #expect(range.maxPartySize == 6)
    }

    @Test func responseDecodesSnakeCaseReservationTimes() throws {
        let json = """
        {
            "reservation_times": [{ "date": "2026-06-20", "times": [] }]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpOpeningsResponse.self, from: json)
        #expect(response.reservationTimes?.first?.date == "2026-06-20")
    }

    @Test func reservationDayHandlesMissingOptionals() throws {
        let json = "{}".data(using: .utf8)!
        let day = try JSONDecoder().decode(CDYelpReservationDay.self, from: json)
        #expect(day.date == nil)
        #expect(day.times == nil)
    }
}
