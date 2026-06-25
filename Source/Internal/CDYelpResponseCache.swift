//
//  CDYelpResponseCache.swift
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

final class CDYelpCacheEntry {
    let data: Data
    let expiresAt: Date
    init(data: Data, expiresAt: Date) {
        self.data = data
        self.expiresAt = expiresAt
    }
}

final class CDYelpResponseCache: @unchecked Sendable {
    // NSCache is thread-safe for all individual operations; no external lock is needed.
    private let cache = NSCache<NSString, CDYelpCacheEntry>()
    private let ttl: TimeInterval

    init(configuration: CDYelpCacheConfiguration) {
        ttl = configuration.ttl
        cache.countLimit = configuration.countLimit
        cache.totalCostLimit = configuration.totalCostLimit
    }

    func set(data: Data, forKey key: String) {
        guard ttl > 0 else { return }
        let entry = CDYelpCacheEntry(data: data, expiresAt: Date().addingTimeInterval(ttl))
        cache.setObject(entry, forKey: key as NSString, cost: data.count)
    }

    func data(forKey key: String) -> Data? {
        guard let entry = cache.object(forKey: key as NSString) else { return nil }
        guard entry.expiresAt > Date() else {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        return entry.data
    }

    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }

    func removeAll() {
        cache.removeAllObjects()
    }
}
