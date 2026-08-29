//
//  CDYelpBusinessInsightsResponseTests.swift
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

import Foundation
import Testing
@testable import CDYelpFusionKit

@Suite(.serialized) struct CDYelpBusinessInsightsResponseTests {
    @Test func responseDecodesFromJSON() throws {
        let json = """
        {
            "insights": [
                {
                    "business_id": "biz-123",
                    "metrics": { "page_views": 800.0, "direction_requests": 45.0 }
                }
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpBusinessInsightsResponse.self, from: json)
        #expect(response.insights?.count == 1)
        #expect(response.insights?.first?.businessId == "biz-123")
        #expect(response.insights?.first?.metrics?["page_views"] == 800.0)
    }

    @Test func responseHandlesMultipleInsights() throws {
        let json = """
        {
            "insights": [
                { "business_id": "biz-1", "metrics": { "views": 100.0 } },
                { "business_id": "biz-2", "metrics": { "views": 200.0 } }
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpBusinessInsightsResponse.self, from: json)
        #expect(response.insights?.count == 2)
        #expect(response.insights?.last?.businessId == "biz-2")
    }

    @Test func responseHandlesMissingOptionals() throws {
        let json = "{}".data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpBusinessInsightsResponse.self, from: json)
        #expect(response.insights == nil)
        #expect(response.error == nil)
    }

    @Test func insightDecodesSnakeCaseBusinessId() throws {
        let json = """
        { "business_id": "snake-test" }
        """.data(using: .utf8)!
        let insight = try JSONDecoder().decode(CDYelpBusinessInsight.self, from: json)
        #expect(insight.businessId == "snake-test")
    }

    @Test func insightHandlesMissingMetrics() throws {
        let json = """
        { "business_id": "biz-no-metrics" }
        """.data(using: .utf8)!
        let insight = try JSONDecoder().decode(CDYelpBusinessInsight.self, from: json)
        #expect(insight.metrics == nil)
    }
}
