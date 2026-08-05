//
//  CDYelpCacheKey.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 6/3/26.
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

enum CDYelpCacheKey {
    static func key(for urlRequest: URLRequest) -> String {
        let method = urlRequest.httpMethod ?? "GET"
        guard let url = urlRequest.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return "\(method):"
        }
        // Sort query items so parameter order from Dictionary iteration doesn't affect the key.
        components.queryItems = components.queryItems?.sorted { $0.name < $1.name }
        let canonicalURL = components.url?.absoluteString ?? url.absoluteString
        return "\(method):\(canonicalURL)"
    }
}
