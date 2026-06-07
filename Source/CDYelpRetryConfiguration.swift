//
//  CDYelpRetryConfiguration.swift
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

/// Configures automatic retry behaviour for CDYelpFusionKit network requests.
public struct CDYelpRetryConfiguration: Sendable {
    /// Maximum number of retry attempts before giving up. Default: 3.
    public let retryLimit: UInt
    /// Initial wait interval before the first retry. Doubles each attempt. Default: 0.5 seconds.
    public let initialDelay: TimeInterval
    /// HTTP status codes that should trigger a retry. Defaults to Alamofire's standard set
    /// ([408, 500, 502, 503, 504]) plus 429 (Too Many Requests) for Yelp rate-limit handling.
    public let retryableHTTPStatusCodes: Set<Int>

    public init(
        retryLimit: UInt = 3,
        initialDelay: TimeInterval = 0.5,
        retryableHTTPStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504]
    ) {
        self.retryLimit = retryLimit
        self.initialDelay = initialDelay
        self.retryableHTTPStatusCodes = retryableHTTPStatusCodes
    }

    /// Retry disabled — the default when no configuration is provided.
    public static let disabled = CDYelpRetryConfiguration(retryLimit: 0, initialDelay: 0)
}
