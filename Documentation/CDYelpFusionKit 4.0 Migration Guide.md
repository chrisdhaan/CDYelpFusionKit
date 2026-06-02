# CDYelpFusionKit 4.0 Migration Guide

Guide for upgrading from CDYelpFusionKit 3.2.0 to 4.0.0.

---

## Breaking Changes

### Deployment Target Changes

The minimum deployment targets have been raised to align with Swift Package Manager 6.0 requirements and Alamofire 5.9+ support.

| Platform | v3.x | v4.0 | Action Required |
|----------|------|------|-----------------|
| iOS | 10.0 | 12.0 | Update project minimum if targeting iOS 10–11 |
| macOS | 10.12 | 11.0 | Update project minimum if targeting macOS 10.x |
| tvOS | 10.0 | 12.0 | Update project minimum if targeting tvOS 10–11 |
| watchOS | 3.0 | 4.0 | Update project minimum if targeting watchOS 3 |
| visionOS | N/A | 1.0 | New platform support |

**How to Update:**

In Xcode:
1. Select your project → Target
2. General tab → Minimum Deployments
3. Update each platform to the new minimum

Or in `Package.swift`:
```swift
// v3.x
platforms: [
    .macOS(.v10_12),
    .iOS(.v10),
    .tvOS(.v10),
    .watchOS(.v3)
]

// v4.0
platforms: [
    .iOS(.v12),
    .macOS(.v11),
    .tvOS(.v12),
    .watchOS(.v4),
    .visionOS(.v1)
]
```

Or in `Podfile`:
```ruby
# v3.x
platform :ios, '10.0'

# v4.0
platform :ios, '12.0'
```

### CDYelpAPIClient No Longer Inherits NSObject

**Breaking Change (Binary Level)**

`CDYelpAPIClient` previously extended `NSObject`. In v4.0 it is a plain Swift class.

```swift
// v3.x
public class CDYelpAPIClient: NSObject {
    ...
}

// v4.0
public class CDYelpAPIClient {
    ...
}
```

**Impact:**

If you were using any of the following patterns, they no longer apply:

```swift
// ❌ No longer works in v4.0
let client = CDYelpAPIClient(apiKey: "key")
_ = NSStringFromClass(type(of: client))  // NSObject reflection
client.responds(to: selector)              // NSObject selector methods
```

**Migration:**

- Remove any Objective-C bridging code that relied on NSObject inheritance
- If you have Objective-C code calling `CDYelpAPIClient`, migrate to Swift
- Remove force-unwraps of NSObject methods (e.g., `.copy()`, `.mutableCopy()`)

**Note:** This change does not affect typical Swift usage. The vast majority of users will not be impacted.

### apiKey Parameter Is Now Non-Optional

**Breaking Change (Compile Level)**

The `apiKey` parameter changed from an implicitly-unwrapped optional to a non-optional string.

```swift
// v3.x
public init(apiKey: String!) {
    assert((apiKey != nil && apiKey.count > 0), "An apiKey is required...")
    self.apiKey = apiKey
    super.init()
}

// v4.0
public init(apiKey: String) {
    precondition(!apiKey.isEmpty, "An apiKey is required to query the Yelp Fusion API.")
    self.apiKey = apiKey
}
```

**Impact:**

Code that passes a nil or empty API key will now fail at compile time instead of runtime:

```swift
// ❌ No longer compiles in v4.0
let client = CDYelpAPIClient(apiKey: nil)
let key: String? = loadKeyFromUserDefaults()
let client = CDYelpAPIClient(apiKey: key)
```

**Migration:**

Ensure the API key is non-optional and non-empty before initializing:

```swift
// ✅ Correct for v4.0
let apiKey = "your-api-key"
let client = CDYelpAPIClient(apiKey: apiKey)

// ✅ Safe unwrapping
if let apiKey = loadKeyFromUserDefaults() {
    let client = CDYelpAPIClient(apiKey: apiKey)
} else {
    // Handle missing key
    fatalError("API key not configured")
}

// ✅ Using a default
let apiKey = loadKeyFromUserDefaults() ?? ""
if apiKey.isEmpty {
    fatalError("API key is required")
}
let client = CDYelpAPIClient(apiKey: apiKey)
```

### Alamofire Dependency Updated

**Breaking Change (Dependency)**

The minimum Alamofire version is now 5.9.x (from 5.6.1).

```swift
// v3.x
.package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1"))

// v4.0
.package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.0"))
```

**Impact:**

If your project has an explicit Alamofire version constraint, it must be updated to allow 5.9+.

**Migration:**

**Swift Package Manager:**
Update `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.0"))
]
```

**CocoaPods:**
Update `Podfile`:
```ruby
pod 'CDYelpFusionKit', '~> 4.0'
pod 'Alamofire', '~> 5.9'
```

**Carthage (Deprecated):**
Carthage is no longer supported in v4.0. Migrate to SPM or CocoaPods.

---

## New Features

### Async/Await API

All 12 Yelp Fusion API methods now have async/await overloads available on iOS 13+, macOS 10.15+, tvOS 13+, and watchOS 6+.

**Before (v3.x — Completion Handlers):**

```swift
client.searchBusinesses(
    byTerm: "coffee",
    location: "San Francisco",
    latitude: nil,
    longitude: nil,
    radius: nil,
    categories: nil,
    locale: nil,
    limit: 10,
    offset: nil,
    sortBy: .bestMatch,
    price: nil,
    openNow: nil,
    openAt: nil,
    attributes: nil
) { response in
    guard let businesses = response?.businesses else {
        print("No results")
        return
    }
    for business in businesses {
        print(business.name ?? "Unknown")
    }
}
```

**After (v4.0 — Async/Await):**

```swift
Task {
    do {
        let response = try await client.searchBusinesses(
            byTerm: "coffee",
            location: "San Francisco",
            latitude: nil,
            longitude: nil,
            radius: nil,
            categories: nil,
            locale: nil,
            limit: 10,
            offset: nil,
            sortBy: .bestMatch,
            price: nil,
            openNow: nil,
            openAt: nil,
            attributes: nil
        )
        let businesses = response.businesses ?? []
        for business in businesses {
            print(business.name ?? "Unknown")
        }
    } catch {
        print("Search failed: \(error)")
    }
}
```

**Benefits:**

- Cleaner, linear code flow (no nesting)
- Structured concurrency support
- Built-in error handling with `try/catch`
- Cancellation support via `Task`

**Availability:**

```swift
// Async overloads require iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func searchBusinesses(...) async throws -> CDYelpSearchResponse
```

You can safely call async methods in any iOS 13+ target. The compiler will enforce availability.

**Old Completion Handler Methods Still Work:**

Completion-handler-based methods are **not removed**, so you can migrate incrementally:

```swift
// v4.0 — both styles work
client.searchBusinesses(...) { response in ... }  // Still works

Task {
    let response = try await client.searchBusinesses(...)  // New style
}
```

---

## Migration Checklist

- [ ] **Deployment Targets:** Update iOS to 12.0+, macOS to 11.0+, tvOS to 12.0+, watchOS to 4.0+
- [ ] **Alamofire Dependency:** Update version constraint to `~> 5.9` (SPM) or `~> 5.9` (CocoaPods)
- [ ] **NSObject Inheritance:** Search codebase for uses of `CDYelpAPIClient` with NSObject-specific methods (reflection, KVO, selectors) and remove
- [ ] **API Key Parameter:** Remove force-unwraps (`!`) when creating `CDYelpAPIClient`; ensure non-empty string is passed
- [ ] **Async/Await Migration (Optional):** Incrementally migrate completion-handler calls to async/await for cleaner code
- [ ] **Testing:** Run full test suite to ensure no regressions
- [ ] **Objective-C Interop (if applicable):** Verify Objective-C bridging if your project uses it

---

## Migration Examples

### Example 1: Simple Search

**Before (v3.x):**

```swift
import CDYelpFusionKit

class SearchViewController: UIViewController {
    let client = CDYelpAPIClient(apiKey: apiKey)  // apiKey was String!
    
    func search() {
        client.searchBusinesses(
            byTerm: "coffee",
            location: "San Francisco",
            latitude: nil,
            longitude: nil,
            radius: nil,
            categories: nil,
            locale: nil,
            limit: 20,
            offset: nil,
            sortBy: .bestMatch,
            price: nil,
            openNow: nil,
            openAt: nil,
            attributes: nil
        ) { response in
            guard let businesses = response?.businesses else { return }
            DispatchQueue.main.async {
                self.businesses = businesses
                self.tableView.reloadData()
            }
        }
    }
}
```

**After (v4.0):**

```swift
import CDYelpFusionKit

class SearchViewController: UIViewController {
    let client: CDYelpAPIClient
    
    init(apiKey: String) {  // Now requires non-optional String
        self.client = CDYelpAPIClient(apiKey: apiKey)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func search() {
        Task {
            do {
                let response = try await client.searchBusinesses(
                    byTerm: "coffee",
                    location: "San Francisco",
                    latitude: nil,
                    longitude: nil,
                    radius: nil,
                    categories: nil,
                    locale: nil,
                    limit: 20,
                    offset: nil,
                    sortBy: .bestMatch,
                    price: nil,
                    openNow: nil,
                    openAt: nil,
                    attributes: nil
                )
                let businesses = response.businesses ?? []
                
                // UI updates on main thread automatically with async/await
                self.businesses = businesses
                self.tableView.reloadData()
            } catch {
                print("Search failed: \(error)")
                self.showError(error)
            }
        }
    }
}
```

### Example 2: Business Details Lookup

**Before (v3.x):**

```swift
client.fetchBusiness(byId: businessId, locale: nil) { response in
    guard let business = response?.business else {
        print("Business not found")
        return
    }
    print("Phone: \(business.phone ?? "N/A")")
    print("Hours: \(business.hours?.count ?? 0) entries")
}
```

**After (v4.0):**

```swift
Task {
    do {
        let response = try await client.fetchBusiness(
            byId: businessId,
            locale: nil
        )
        guard let business = response.business else {
            print("Business not found")
            return
        }
        print("Phone: \(business.phone ?? "N/A")")
        print("Hours: \(business.hours?.count ?? 0) entries")
    } catch {
        print("Failed to fetch business: \(error)")
    }
}
```

### Example 3: Concurrent Requests

A new feature in v4.0 is the ability to easily make concurrent requests with structured concurrency:

```swift
// Fetch business details and reviews concurrently
Task {
    async let businessResult = client.fetchBusiness(
        byId: businessId,
        locale: nil
    )
    async let reviewsResult = client.fetchReviews(
        forBusinessId: businessId,
        locale: nil
    )
    
    do {
        let business = try await businessResult
        let reviews = try await reviewsResult
        
        print("Business: \(business.business?.name ?? "Unknown")")
        print("Reviews: \(reviews.reviews?.count ?? 0)")
    } catch {
        print("Error: \(error)")
    }
}
```

---

## Troubleshooting

### "Cannot convert value of type 'String?' to expected argument type 'String'"

**Problem:** Passing optional string to `apiKey` parameter.

**Solution:**
```swift
// ❌ Won't compile
let apiKey: String? = loadFromConfig()
let client = CDYelpAPIClient(apiKey: apiKey)

// ✅ Correct
guard let apiKey = loadFromConfig() else {
    fatalError("API key required")
}
let client = CDYelpAPIClient(apiKey: apiKey)
```

### "Cannot find 'super.init()' in scope"

**Problem:** Old code calling `super.init()` after initializing `CDYelpAPIClient`.

**Solution:**
Remove the `super.init()` call — `CDYelpAPIClient` no longer inherits from `NSObject`.

```swift
// ❌ v3.x style (no longer works)
class MyClass {
    let client: CDYelpAPIClient
    
    init(apiKey: String) {
        self.client = CDYelpAPIClient(apiKey: apiKey)
        super.init()  // ❌ Error in v4.0
    }
}

// ✅ v4.0 style
class MyClass {
    let client: CDYelpAPIClient
    
    init(apiKey: String) {
        self.client = CDYelpAPIClient(apiKey: apiKey)
        // No super.init() call needed
    }
}
```

### "Target iOS 11 but CDYelpFusionKit requires iOS 12"

**Problem:** Project deployment target is below v4.0 minimums.

**Solution:**
Update your project's deployment target in Xcode:
1. Select project → Target
2. General tab → Minimum Deployments
3. Increase to iOS 12.0 or higher

Or specify a compatible version in `Podfile`:
```ruby
pod 'CDYelpFusionKit', '~> 3.2'  # Stay on v3.x if you need older targets
pod 'CDYelpFusionKit', '~> 4.0'  # Requires iOS 12+
```

### Async/Await Not Available

**Problem:** Getting compile error on async/await methods even on iOS 13+ project.

**Solution:**
Async methods are annotated with `@available(iOS 13.0, ...)`. Explicitly check availability or wrap in availability guard:

```swift
// ✅ Using @available attribute
@available(iOS 13.0, *)
func performSearch() {
    Task {
        let response = try await client.searchBusinesses(...)
    }
}

// ✅ Using availability guard
if #available(iOS 13.0, *) {
    Task {
        let response = try await client.searchBusinesses(...)
    }
}
```

---

## Support

For additional help:
- [CDYelpFusionKit GitHub Issues](https://github.com/chrisdhaan/CDYelpFusionKit/issues)
- [Usage Guide](Usage.md)
- [Architecture Documentation](ARCHITECTURE.md)
- [Yelp Fusion API Docs](https://www.yelp.com/developers/documentation/v3)
