//
//  CDYelpCacheConfiguration.swift
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

/// Configuration for CDYelpFusionKit's built-in response cache.
public struct CDYelpCacheConfiguration: Sendable {
    /// Time-to-live in seconds before a cached response is considered stale. Default: 300 (5 minutes).
    public let ttl: TimeInterval
    /// Maximum number of responses to hold in memory. 0 means unlimited. Default: 100.
    public let countLimit: Int
    /// Total cost limit in bytes. 0 means unlimited. Default: 0.
    public let totalCostLimit: Int

    public init(ttl: TimeInterval = 300, countLimit: Int = 100, totalCostLimit: Int = 0) {
        self.ttl = ttl
        self.countLimit = countLimit
        self.totalCostLimit = totalCostLimit
    }

    /// Caching disabled — the default when no configuration is provided.
    /// A `ttl` of 0 prevents the cache from being created, so `countLimit` and `totalCostLimit` have no effect.
    public static let disabled = CDYelpCacheConfiguration(ttl: 0, countLimit: 0, totalCostLimit: 0)
}
