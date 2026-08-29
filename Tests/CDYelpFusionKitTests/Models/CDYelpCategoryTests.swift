//
//  CDYelpCategoryTests.swift
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

struct CDYelpCategoryTests {
    @Test func categoryDecodesFromJSON() throws {
        let json = """
        {
            "alias": "coffee",
            "title": "Coffee"
        }
        """.data(using: .utf8)!
        let category = try JSONDecoder().decode(CDYelpCategory.self, from: json)
        #expect(category.alias == "coffee")
        #expect(category.title == "Coffee")
    }

    @Test func categoryHandlesMissingOptionals() throws {
        let json = """
        {
            "alias": "restaurants"
        }
        """.data(using: .utf8)!
        let category = try JSONDecoder().decode(CDYelpCategory.self, from: json)
        #expect(category.alias == "restaurants")
        #expect(category.title == nil)
    }

    @Test func categoryDecodesMultipleCategories() throws {
        let categories = [
            ("fastfood", "Fast Food"),
            ("pizza", "Pizza"),
            ("chinese", "Chinese"),
            ("japanese", "Japanese"),
            ("indian", "Indian")
        ]

        for (alias, title) in categories {
            let json = """
            {
                "alias": "\(alias)",
                "title": "\(title)"
            }
            """.data(using: .utf8)!
            let category = try JSONDecoder().decode(CDYelpCategory.self, from: json)
            #expect(category.alias == alias)
            #expect(category.title == title)
        }
    }

    @Test func categoryHandlesEmptyTitle() throws {
        let json = """
        {
            "alias": "empty",
            "title": ""
        }
        """.data(using: .utf8)!
        let category = try JSONDecoder().decode(CDYelpCategory.self, from: json)
        #expect(category.title == "")
    }

    @Test func categoryHandlesUnicodeCharacters() throws {
        let json = """
        {
            "alias": "french",
            "title": "Français Cuisine"
        }
        """.data(using: .utf8)!
        let category = try JSONDecoder().decode(CDYelpCategory.self, from: json)
        #expect(category.title == "Français Cuisine")
    }

    @Test func categoryHandlesHyphenatedAlias() throws {
        let json = """
        {
            "alias": "hot-dogs",
            "title": "Hot Dogs"
        }
        """.data(using: .utf8)!
        let category = try JSONDecoder().decode(CDYelpCategory.self, from: json)
        #expect(category.alias == "hot-dogs")
    }
}
