//
//  CDYelpAIChatRequest.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 6/7/26.
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

public struct CDYelpAIChatRequest: Encodable, Sendable {
    public let query: String
    public let chatId: String?
    public let userContext: UserContext?
    public let requestContext: [String: String]?

    public struct UserContext: Encodable, Sendable {
        public let latitude: Double
        public let longitude: Double

        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    enum CodingKeys: String, CodingKey {
        case query
        case chatId = "chat_id"
        case userContext = "user_context"
        case requestContext = "request_context"
    }

    public init(query: String,
                chatId: String? = nil,
                userContext: UserContext? = nil,
                requestContext: [String: String]? = nil) {
        self.query = query
        self.chatId = chatId
        self.userContext = userContext
        self.requestContext = requestContext
    }
}
