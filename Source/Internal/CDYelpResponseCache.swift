//
//  CDYelpResponseCache.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 6/3/26.
//

import Foundation

struct CDYelpCacheEntry {
    let data: Data
    let expiresAt: Date
}

final class CDYelpResponseCache: @unchecked Sendable {
    private let cache = NSCache<NSString, AnyObject>()
    private let ttl: TimeInterval
    private let lock = NSLock()

    init(configuration: CDYelpCacheConfiguration) {
        ttl = configuration.ttl
        cache.countLimit = configuration.countLimit
        cache.totalCostLimit = configuration.totalCostLimit
    }

    func set(data: Data, forKey key: String) {
        guard ttl > 0 else { return }
        let entry = CDYelpCacheEntry(data: data, expiresAt: Date().addingTimeInterval(ttl))
        lock.lock()
        cache.setObject(entry as AnyObject, forKey: key as NSString)
        lock.unlock()
    }

    func data(forKey key: String) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        guard let entry = cache.object(forKey: key as NSString) as? CDYelpCacheEntry else { return nil }
        guard entry.expiresAt > Date() else {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        return entry.data
    }

    func remove(forKey key: String) {
        lock.lock()
        cache.removeObject(forKey: key as NSString)
        lock.unlock()
    }

    func removeAll() {
        lock.lock()
        cache.removeAllObjects()
        lock.unlock()
    }
}
