//
//  CDYelpEngagementResponseTests.swift
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

@Suite(.serialized) struct CDYelpEngagementResponseTests {
    @Test func responseDecodesFromJSON() throws {
        let json = """
        {
            "data": [
                {
                    "business_id": "biz-abc",
                    "metrics": { "views": 1500.0, "clicks": 320.0 }
                }
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpEngagementResponse.self, from: json)
        #expect(response.data?.count == 1)
        #expect(response.data?.first?.businessId == "biz-abc")
        #expect(response.data?.first?.metrics?["views"] == 1500.0)
    }

    @Test func responseHandlesEmptyData() throws {
        let json = """
        { "data": [] }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpEngagementResponse.self, from: json)
        #expect(response.data?.isEmpty == true)
    }

    @Test func responseHandlesMissingOptionals() throws {
        let json = "{}".data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpEngagementResponse.self, from: json)
        #expect(response.data == nil)
        #expect(response.error == nil)
    }

    @Test func engagementDataDecodesSnakeCaseBusinessId() throws {
        let json = """
        { "business_id": "snake-case-biz" }
        """.data(using: .utf8)!
        let data = try JSONDecoder().decode(CDYelpEngagementData.self, from: json)
        #expect(data.businessId == "snake-case-biz")
    }

    @Test func engagementDataDecodesMultipleMetrics() throws {
        let json = """
        {
            "business_id": "biz-xyz",
            "metrics": { "impressions": 5000.0, "ctr": 0.12, "conversions": 42.0 }
        }
        """.data(using: .utf8)!
        let data = try JSONDecoder().decode(CDYelpEngagementData.self, from: json)
        #expect(data.metrics?.count == 3)
        #expect(data.metrics?["ctr"] == 0.12)
    }
}
