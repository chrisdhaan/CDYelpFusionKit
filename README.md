<p align="center">
    <a href="https://github.com/chrisdhaan/CDYelpFusionKit">
        <img src="https://raw.githubusercontent.com/chrisdhaan/CDYelpFusionKit/master/Documentation/cdyelpfusionkit.png" alt="CDYelpFusionKit" width="850" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/chrisdhaan/CDYelpFusionKit/actions/workflows/ci.yml">
        <img src="https://github.com/chrisdhaan/CDYelpFusionKit/actions/workflows/ci.yml/badge.svg" alt="CI Status">
    </a>
    <a href="https://github.com/chrisdhaan/CDYelpFusionKit/releases">
        <img src="https://img.shields.io/github/release/chrisdhaan/CDYelpFusionKit.svg" alt="GitHub Release">
    </a>
    <a href="https://www.swift.org">
        <img src="https://img.shields.io/badge/Swift-5+-orange?style=flat" alt="Swift Versions">
    </a>
    <a href="http://cocoapods.org/pods/CDYelpFusionKit">
        <img src="https://img.shields.io/cocoapods/p/CDYelpFusionKit.svg?style=flat" alt="Platforms">
    </a>
    <a href="http://cocoapods.org/pods/CDYelpFusionKit">
        <img src="https://img.shields.io/cocoapods/v/CDYelpFusionKit.svg?style=flat" alt="CocoaPods Compatible">
    </a>
    <a href="https://www.swift.org/package-manager">
        <img src="https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat" alt="SPM Compatible">
    </a>
    <a href="http://cocoapods.org/pods/CDYelpFusionKit">
        <img src="https://img.shields.io/cocoapods/l/CDYelpFusionKit.svg?style=flat" alt="License">
    </a>
</p>

<br>

A comprehensive Swift wrapper for the Yelp Fusion REST API with full support for all endpoints, async/await concurrency, and cross-platform deployment.

## Features

- Complete Yelp Fusion API coverage (search, business details, reviews, events, categories, autocomplete, AI chat, engagement metrics, service offerings, business insights, review highlights, home services, reservations)
- Async/await API on all supported platforms (no completion handlers)
- Event monitoring and request adapters for logging, metrics, and header injection
- Built-in response caching with configurable TTL
- Automatic retry with exponential backoff
- Customizable JSON decoding strategies
- Mock networking utilities for unit testing (`CDYelpMockURLProtocol`, `CDYelpMockClientFactory`)
- Dependency-free — uses Apple's URLSession directly (no Alamofire)
- Full Swift concurrency support — `CDYelpAPIClient` is `Sendable`; dependency-free URLSession actor eliminates unsafe shared mutable state
- Privacy manifest for App Store compliance
- Comprehensive unit test suite (Swift Testing framework, 234 tests)
- Multi-platform support (iOS, macOS, tvOS, watchOS, visionOS)

## Quick Start

```swift
import CDYelpFusionKit

let client = CDYelpAPIClient(apiKey: "your-api-key")

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
            priceTiers: nil,
            openNow: nil,
            openAt: nil,
            attributes: nil
        )
        print("Found \(response.businesses?.count ?? 0) businesses")
    } catch {
        print("Search failed: \(error)")
    }
}
```

## Requirements

| Platform | Minimum Version |
|----------|-----------------|
| iOS | 15.0 |
| macOS | 12.0 |
| tvOS | 15.0 |
| watchOS | 8.0 |
| visionOS | 1.0 |

## Installation

### Swift Package Manager

Add CDYelpFusionKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/chrisdhaan/CDYelpFusionKit.git", .upToNextMajor(from: "6.0.0"))
]
```

Or in Xcode: **File → Add Packages** and enter the repository URL.

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'CDYelpFusionKit', '~> 6.0'
```

Then run `pod install`.

## Documentation

- **[Usage Guide](Documentation/Usage.md)** — Complete API reference with examples for all endpoints
- **[Architecture](Documentation/ARCHITECTURE.md)** — Technical design and implementation details
- **[Migration Guide](Documentation/CDYelpFusionKit%206.0%20Migration%20Guide.md)** — Upgrade from v5.x to v6.0
- **[API Documentation](https://chrisdhaan.github.io/CDYelpFusionKit/)** — Generated DocC reference

## Author

Christopher de Haan ([@chrisdhaan](https://twitter.com/chrisdhaan))

## License

CDYelpFusionKit is released under the MIT license. See [LICENSE](LICENSE) for details.
