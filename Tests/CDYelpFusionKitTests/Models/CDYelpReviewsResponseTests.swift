//
//  CDYelpReviewsResponseTests.swift
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

struct CDYelpReviewsResponseTests {
    @Test func reviewsResponseDecodesFromJSON() throws {
        let json = """
        {
            "reviews": []
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpReviewsResponse.self, from: json)
        #expect(response.reviews != nil)
    }

    @Test func reviewsResponseHandlesMissingOptionals() throws {
        let json = """
        {}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpReviewsResponse.self, from: json)
        #expect(response.reviews == nil)
    }

    @Test func reviewsResponseDecodesMultipleReviews() throws {
        let json = """
        {
            "reviews": [
                {
                    "id": "review1",
                    "rating": 5,
                    "text": "Excellent!"
                },
                {
                    "id": "review2",
                    "rating": 4,
                    "text": "Very good"
                }
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpReviewsResponse.self, from: json)
        #expect(response.reviews?.count == 2)
    }

    @Test func reviewsResponseHandlesEmptyReviews() throws {
        let json = """
        {
            "reviews": []
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpReviewsResponse.self, from: json)
        #expect(response.reviews?.count == 0)
    }

    @Test func reviewsResponseHandlesTotalCount() throws {
        let json = """
        {
            "reviews": [
                {"id": "r1"},
                {"id": "r2"}
            ],
            "total": 150
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpReviewsResponse.self, from: json)
        #expect(response.reviews?.count == 2)
        #expect(response.total == 150)
    }
}
