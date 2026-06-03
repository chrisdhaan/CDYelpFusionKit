//
//  CDYelpCacheConfiguration.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 6/3/26.
//

import Foundation

/// Configuration for CDYelpFusionKit's built-in response cache.
public struct CDYelpCacheConfiguration: Sendable {
    /// Time-to-live in seconds before a cached response is considered stale. Default: 300 (5 minutes).
    public let ttl: TimeInterval
    /// Maximum number of responses to hold in memory. Default: 100.
    public let countLimit: Int
    /// Total cost limit in bytes. 0 means unlimited. Default: 0.
    public let totalCostLimit: Int

    public init(ttl: TimeInterval = 300, countLimit: Int = 100, totalCostLimit: Int = 0) {
        self.ttl = ttl
        self.countLimit = countLimit
        self.totalCostLimit = totalCostLimit
    }

    /// Caching disabled — the default when no configuration is provided.
    public static let disabled = CDYelpCacheConfiguration(ttl: 0, countLimit: 0, totalCostLimit: 0)
}
