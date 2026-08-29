//
//  CDYelpEventTests.swift
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

struct CDYelpEventTests {
    @Test func eventDecodesFromJSON() throws {
        let json = """
        {
            "id": "test-event-id",
            "name": "Test Event",
            "description": "A test event"
        }
        """.data(using: .utf8)!
        let event = try JSONDecoder().decode(CDYelpEvent.self, from: json)
        #expect(event.id == "test-event-id")
        #expect(event.name == "Test Event")
    }

    @Test func eventHandlesMissingOptionals() throws {
        let json = """
        {
            "id": "event123"
        }
        """.data(using: .utf8)!
        let event = try JSONDecoder().decode(CDYelpEvent.self, from: json)
        #expect(event.id == "event123")
        #expect(event.name == nil)
    }

    @Test func eventDecodesCompleteJSON() throws {
        let json = """
        {
            "id": "yelp-elite-week",
            "name": "Yelp Elite Week",
            "description": "Annual celebration",
            "url": "https://www.yelp.com/events",
            "image_url": "https://example.com/image.jpg",
            "is_free": true,
            "category": "nightlife"
        }
        """.data(using: .utf8)!
        let event = try JSONDecoder().decode(CDYelpEvent.self, from: json)
        #expect(event.id == "yelp-elite-week")
        #expect(event.name == "Yelp Elite Week")
        #expect(event.isFree == true)
    }

    @Test func eventHandlesEmptyDescription() throws {
        let json = """
        {
            "id": "event456",
            "name": "Event Name",
            "description": ""
        }
        """.data(using: .utf8)!
        let event = try JSONDecoder().decode(CDYelpEvent.self, from: json)
        #expect(event.description == "")
    }

    @Test func eventHandlesNullValues() throws {
        let json = """
        {
            "id": "event789",
            "name": "Event",
            "is_free": null
        }
        """.data(using: .utf8)!
        let event = try JSONDecoder().decode(CDYelpEvent.self, from: json)
        #expect(event.id == "event789")
        #expect(event.isFree == nil)
    }
}
