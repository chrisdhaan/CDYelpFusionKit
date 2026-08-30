//
//  CDYelpJobsResponseTests.swift
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

@Suite(.serialized) struct CDYelpJobsResponseTests {
    @Test func responseDecodesFromJSON() throws {
        let json = """
        {
            "jobs": [
                {
                    "id": "job-1",
                    "name": "Plumber",
                    "alias": "plumber",
                    "description": "Licensed plumbing services."
                }
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpJobsResponse.self, from: json)
        #expect(response.jobs?.count == 1)
        let job = response.jobs?.first
        #expect(job?.id == "job-1")
        #expect(job?.name == "Plumber")
        #expect(job?.alias == "plumber")
        #expect(job?.description == "Licensed plumbing services.")
    }

    @Test func responseHandlesEmptyJobs() throws {
        let json = """
        { "jobs": [] }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpJobsResponse.self, from: json)
        #expect(response.jobs?.isEmpty == true)
    }

    @Test func responseHandlesMissingOptionals() throws {
        let json = "{}".data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpJobsResponse.self, from: json)
        #expect(response.jobs == nil)
        #expect(response.error == nil)
    }

    @Test func jobHandlesMissingOptionals() throws {
        let json = "{}".data(using: .utf8)!
        let job = try JSONDecoder().decode(CDYelpJob.self, from: json)
        #expect(job.id == nil)
        #expect(job.name == nil)
        #expect(job.alias == nil)
        #expect(job.description == nil)
    }

    @Test func responseHandlesMultipleJobs() throws {
        let json = """
        {
            "jobs": [
                { "id": "j1", "name": "Plumber" },
                { "id": "j2", "name": "Electrician" },
                { "id": "j3", "name": "HVAC Technician" }
            ]
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpJobsResponse.self, from: json)
        #expect(response.jobs?.count == 3)
        #expect(response.jobs?.last?.name == "HVAC Technician")
    }
}
