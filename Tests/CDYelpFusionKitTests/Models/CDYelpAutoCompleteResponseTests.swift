//
//  CDYelpAutoCompleteResponseTests.swift
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

@Suite struct CDYelpAutoCompleteResponseTests {

    @Test func autoCompleteResponseDecodesFromJSON() throws {
        let json = """
        {
            "businesses": [],
            "categories": [],
            "terms": []
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpAutoCompleteResponse.self, from: json)
        #expect(response.businesses != nil)
        #expect(response.categories != nil)
        #expect(response.terms != nil)
    }

    @Test func autoCompleteResponseHandlesMissingOptionals() throws {
        let json = """
        {}
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpAutoCompleteResponse.self, from: json)
        #expect(response.businesses == nil)
        #expect(response.categories == nil)
        #expect(response.terms == nil)
    }

    @Test func autoCompleteResponseDecodesWithSuggestions() throws {
        let json = """
        {
            "businesses": [
                {"id": "biz1", "name": "Business One"}
            ],
            "categories": [
                {"alias": "coffee", "title": "Coffee"}
            ],
            "terms": [
                {"text": "pizza"}
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpAutoCompleteResponse.self, from: json)
        #expect(response.businesses?.count == 1)
        #expect(response.categories?.count == 1)
        #expect(response.terms?.count == 1)
    }

    @Test func autoCompleteResponseHandlesOnlyBusinesses() throws {
        let json = """
        {
            "businesses": [
                {"id": "b1"},
                {"id": "b2"}
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpAutoCompleteResponse.self, from: json)
        #expect(response.businesses?.count == 2)
        #expect(response.categories == nil)
        #expect(response.terms == nil)
    }

    @Test func autoCompleteResponseHandlesOnlyCategories() throws {
        let json = """
        {
            "categories": [
                {"alias": "pizza"},
                {"alias": "burgers"}
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpAutoCompleteResponse.self, from: json)
        #expect(response.categories?.count == 2)
        #expect(response.businesses == nil)
    }

    @Test func autoCompleteResponseHandlesOnlyTerms() throws {
        let json = """
        {
            "terms": [
                {"text": "sushi"},
                {"text": "ramen"},
                {"text": "tempura"}
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpAutoCompleteResponse.self, from: json)
        #expect(response.terms?.count == 3)
        #expect(response.businesses == nil)
        #expect(response.categories == nil)
    }
}
