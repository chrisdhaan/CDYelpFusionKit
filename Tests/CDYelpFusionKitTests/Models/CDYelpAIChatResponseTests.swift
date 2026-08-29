//
//  CDYelpAIChatResponseTests.swift
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

@Suite(.serialized) struct CDYelpAIChatResponseTests {
    @Test func responseDecodesFromJSON() throws {
        let json = """
        {
            "chat_id": "conv-abc123",
            "response": "Here are some great taco spots near you."
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpAIChatResponse.self, from: json)
        #expect(response.chatId == "conv-abc123")
        #expect(response.response == "Here are some great taco spots near you.")
    }

    @Test func responseHandlesMissingOptionals() throws {
        let json = "{}".data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpAIChatResponse.self, from: json)
        #expect(response.chatId == nil)
        #expect(response.response == nil)
        #expect(response.businesses == nil)
        #expect(response.error == nil)
    }

    @Test func responseDecodesSnakeCaseChatId() throws {
        let json = """
        {
            "chat_id": "snake-case-test"
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDYelpAIChatResponse.self, from: json)
        #expect(response.chatId == "snake-case-test")
    }

    @Test func requestEncodesQueryAsJSON() throws {
        let request = CDYelpAIChatRequest(query: "best pizza")
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(dict?["query"] as? String == "best pizza")
    }

    @Test func requestEncodesChatIdWithSnakeCase() throws {
        let request = CDYelpAIChatRequest(query: "tacos", chatId: "chat-456")
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(dict?["chat_id"] as? String == "chat-456")
    }

    @Test func requestEncodesRequestContext() throws {
        let request = CDYelpAIChatRequest(query: "pizza", requestContext: ["session": "xyz"])
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let context = dict?["request_context"] as? [String: String]
        #expect(context?["session"] == "xyz")
    }

    @Test func requestOmitsNilFieldsFromJSON() throws {
        let request = CDYelpAIChatRequest(query: "tacos")
        let data = try JSONEncoder().encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(dict?["chat_id"] == nil)
        #expect(dict?["user_context"] == nil)
        #expect(dict?["request_context"] == nil)
    }
}
