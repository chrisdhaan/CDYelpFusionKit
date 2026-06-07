//
//  CDYelpReviewTests.swift
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

@testable import CDYelpFusionKit
import Foundation
import Testing

@Suite(.serialized) struct CDYelpReviewTests {
    @Test func reviewDecodesFromJSON() throws {
        let json = """
        {
            "id": "review123",
            "text": "Great food!",
            "rating": 5
        }
        """.data(using: .utf8)!
        let review = try JSONDecoder().decode(CDYelpReview.self, from: json)
        #expect(review.id == "review123")
        #expect(review.text == "Great food!")
        #expect(review.rating == 5)
    }

    @Test func reviewHandlesMissingOptionals() throws {
        let json = """
        {
            "id": "review456"
        }
        """.data(using: .utf8)!
        let review = try JSONDecoder().decode(CDYelpReview.self, from: json)
        #expect(review.id == "review456")
        #expect(review.text == nil)
        #expect(review.rating == nil)
    }

    @Test func reviewDecodesCompleteJSON() throws {
        let json = """
        {
            "id": "full-review",
            "text": "Amazing experience from start to finish.",
            "rating": 4,
            "time_created": "2016-05-21 19:42:51",
            "user": {
                "id": "user123",
                "profile_url": "https://www.yelp.com/user_details?userid=user123",
                "image_url": "https://example.com/user.jpg",
                "name": "John D."
            },
            "url": "https://www.yelp.com/biz/review"
        }
        """.data(using: .utf8)!
        let review = try JSONDecoder().decode(CDYelpReview.self, from: json)
        #expect(review.id == "full-review")
        #expect(review.rating == 4)
    }

    @Test func reviewHandlesRatingRange() throws {
        for rating in 1 ... 5 {
            let json = """
            {
                "id": "review-\(rating)",
                "rating": \(rating)
            }
            """.data(using: .utf8)!
            let review = try JSONDecoder().decode(CDYelpReview.self, from: json)
            #expect(review.rating == rating)
        }
    }

    @Test func reviewHandlesEmptyText() throws {
        let json = """
        {
            "id": "empty-review",
            "text": ""
        }
        """.data(using: .utf8)!
        let review = try JSONDecoder().decode(CDYelpReview.self, from: json)
        #expect(review.text == "")
    }

    @Test func reviewHandlesLongText() throws {
        let longText = String(repeating: "A", count: 1000)
        let json = """
        {
            "id": "long-review",
            "text": "\(longText)"
        }
        """.data(using: .utf8)!
        let review = try JSONDecoder().decode(CDYelpReview.self, from: json)
        #expect(review.text?.count == 1000)
    }

    @Test func decodesLanguageField() throws {
        let json = """
        {
          "id": "abc123",
          "text": "Great place!",
          "url": "https://www.yelp.com/biz/foo",
          "rating": 5,
          "time_created": "2020-11-18 22:30:48",
          "language": "en",
          "user": null
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let review = try decoder.decode(CDYelpReview.self, from: json)
        #expect(review.language == "en")
    }

    @Test func languageIsNilWhenAbsent() throws {
        let json = """
        {
          "id": "abc123",
          "text": "Great place!",
          "url": "https://www.yelp.com/biz/foo",
          "rating": 5,
          "time_created": "2020-11-18 22:30:48",
          "user": null
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let review = try decoder.decode(CDYelpReview.self, from: json)
        #expect(review.language == nil)
    }
}
