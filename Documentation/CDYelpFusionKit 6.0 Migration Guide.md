# CDYelpFusionKit 6.0 Migration Guide

Guide for upgrading from CDYelpFusionKit 5.x to 6.0.0.

---

## Breaking Changes

### 1. Completion handlers removed

All `CDYelpAPIClient` methods previously offered both a completion-handler variant and an `async throws` variant. In v6.0.0, the completion-handler variants are removed entirely. All 19 API methods are now `async throws` only.

**Before (v5.x):**
```swift
client.searchBusinesses(byTerm: "coffee", location: "San Francisco", ...) { response in
    guard let businesses = response?.businesses else { return }
    print(businesses)
}
```

**After (v6.0):**
```swift
Task {
    do {
        let response = try await client.searchBusinesses(byTerm: "coffee", location: "San Francisco", ...)
        let businesses = response.businesses ?? []
        print(businesses)
    } catch {
        print("Error: \(error)")
    }
}
```

Every call site using the `completion:` form must be converted to `async throws`. The `Task { }` wrapper is only needed when calling from synchronous context (e.g., a `UIViewController` method). Inside an already-`async` function, call `try await` directly.

---

### 2. Error type changed: AFError → CDYelpNetworkError

v5.x async methods threw `AFError` (from Alamofire). v6.0 throws `CDYelpNetworkError`, a native Swift enum with four cases:

```swift
public enum CDYelpNetworkError: Error {
    case invalidRequest(underlying: Error)
    case networkFailure(underlying: Error)
    case httpError(statusCode: Int, data: Data)
    case decodingFailed(underlying: Error)
}
```

**Before (v5.x):**
```swift
} catch let error as AFError {
    switch error {
    case .responseValidationFailed(let reason):
        print("Validation failed: \(reason)")
    default:
        print("Alamofire error: \(error)")
    }
}
```

**After (v6.0):**
```swift
} catch let error as CDYelpNetworkError {
    switch error {
    case .httpError(let statusCode, _):
        print("HTTP \(statusCode)")
    case .networkFailure(let underlying):
        print("Network error: \(underlying.localizedDescription)")
    case .decodingFailed(let underlying):
        print("Decoding error: \(underlying)")
    case .invalidRequest(let underlying):
        print("Invalid request: \(underlying)")
    }
}
```

---

### 3. Alamofire dependency removed

CDYelpFusionKit no longer depends on Alamofire. If your app imports Alamofire only because CDYelpFusionKit pulled it in, you may now remove it. If your app uses Alamofire independently, no change is needed.

**Swift Package Manager:** Remove `import Alamofire` from any file that imported it solely for `AFError`. The Alamofire package reference in `Package.swift` can be removed if it is not used elsewhere.

**CocoaPods:** Remove `pod 'Alamofire'` from your `Podfile` if it was only transitively required.

---

### 4. Deployment targets raised

| Platform | v5.x minimum | v6.0 minimum |
|----------|-------------|-------------|
| iOS | 12.0 | **15.0** |
| macOS | 11.0 | **12.0** |
| tvOS | 12.0 | **15.0** |
| watchOS | 4.0 | **8.0** |
| visionOS | 1.0 | 1.0 (unchanged) |

If your app targets a platform version below these minimums, you must raise your own deployment target before adopting v6.0.

---

### 5. `isAuthenticated()` method removed

`init` already enforces a non-empty `apiKey` via `precondition`, so `isAuthenticated()` could never return `false` for a successfully constructed client. The method is removed as dead API surface — remove any call sites; a successfully constructed `CDYelpAPIClient` is always authenticated.

---

### 6. `cancelAllPendingAPIRequests()` is now `async`

Cancellation now suspends until it has actually been applied to in-flight tasks and retry backoff sleeps, instead of returning immediately and delivering cancellation on a later run loop turn.

**Before (v5.x):**
```swift
client.cancelAllPendingAPIRequests()
```

**After (v6.0):**
```swift
await client.cancelAllPendingAPIRequests()
```

---

### 7. Parameter validation now traps in Release builds too

In v5.x, most parameter validation (radius/limit bounds, required strings, coordinate ranges, etc. — see `API_SCHEMA.md` for the full per-endpoint list) used `assert`, which is compiled out in optimized Release builds; only the `apiKey` check in `init` used `precondition`. In v6.0, every one of these checks uses `precondition`, consistent with `init`'s existing `apiKey` check — they now trap in Release builds as well as Debug.

This is intentional: a request built from invalid input (e.g. a radius over 40,000, an empty required string, an out-of-range coordinate) was never going to succeed against the Yelp Fusion API, so failing fast at the call site is preferable to silently sending a malformed request in Debug and doing the same silently in Release. If your app has a code path that could pass out-of-range values to any `CDYelpAPIClient` method, fix the call site — it will now crash instead of silently proceeding.

---

## What Did Not Change

The following public API surface is **identical** in v6.0 — no call-site changes needed beyond the completion handler conversion:

- All `CDYelpAPIClient.init` parameters (`apiKey:`, `cacheConfiguration:`, `retryConfiguration:`, `decoderConfiguration:`, `eventMonitors:`, `requestAdapters:`)
- `CDYelpCacheConfiguration`, `CDYelpRetryConfiguration`, `CDYelpDecoderConfiguration`
- `CDYelpEventMonitor` and `CDYelpRequestAdapter` protocols
- `clearCache()` method
- All response model types (`CDYelpSearchResponse`, `CDYelpBusiness`, `CDYelpEvent`, etc.)
- All enum types (`CDYelpLocale`, `CDYelpBusinessSortType`, `CDYelpPriceTier`, etc.)
- `CDYelpMockURLProtocol` and `CDYelpMockClientFactory` testing utilities

---

## Migration Checklist

- [ ] **Convert all completion-handler calls** to `async throws` — search for `.searchBusinesses(`, `.fetchBusiness(`, etc. with `completion:` or trailing closure syntax
- [ ] **Update error handling** — replace `AFError` catch blocks with `CDYelpNetworkError`
- [ ] **Add `await` to `cancelAllPendingAPIRequests()` call sites** — now `async`
- [ ] **Remove `isAuthenticated()` call sites** — the method is removed; a constructed client is always authenticated
- [ ] **Remove `import Alamofire`** from files where it was only used for `AFError`
- [ ] **Raise deployment targets** if any of your targets are below iOS 15 / macOS 12 / tvOS 15 / watchOS 8
- [ ] **Remove Alamofire dependency** from `Package.swift` or `Podfile` if no longer needed by your own code
- [ ] **Update SPM version** from `"5.1.0"` to `"6.0.0"` in `Package.swift`, or run `File → Add Packages` in Xcode to fetch the new version
- [ ] **Update CocoaPods** — change `~> 5.1` to `~> 6.0` in your `Podfile` and run `pod update CDYelpFusionKit`
- [ ] **Run your test suite** to confirm no regressions

---

## Support

- [CDYelpFusionKit GitHub Issues](https://github.com/chrisdhaan/CDYelpFusionKit/issues)
- [Usage Guide](Usage.md)
- [Architecture Documentation](ARCHITECTURE.md)
- [Yelp Fusion API Docs](https://www.yelp.com/developers/documentation/v3)
