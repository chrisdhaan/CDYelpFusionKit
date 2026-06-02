# CDYelpFusionKit

## Overview

CDYelpFusionKit is a Swift framework that wraps the Yelp Fusion REST API. It provides typed request/response models and an `Alamofire`-backed HTTP client.

## Repository Layout

| Path | Description |
|------|-------------|
| `Source/` | Framework source (40 Swift files) |
| `Tests/` | Unit tests (Swift Testing) |
| `Example/` | iOS example app |
| `Resources/` | Asset catalogs (Yelp brand colors, star ratings) |
| `Documentation/` | Usage guide, architecture, migration guide |
| `docs/` | DocC-generated API documentation (GitHub Pages) |
| `CDYelpFusionKit.xcodeproj` | Xcode project |
| `CDYelpFusionKit.podspec` | CocoaPods spec |
| `Package.swift` | Swift Package Manager manifest |
| `.github/workflows/ci.yml` | GitHub Actions CI |
| `Gemfile` | Ruby dependencies (CocoaPods) |

## Platform Targets

| Platform | Minimum |
|----------|---------|
| iOS | 12.0 |
| macOS | 11.0 |
| tvOS | 12.0 |
| watchOS | 4.0 |
| visionOS | 1.0 |

## Key Source Files

| File | Role |
|------|------|
| `CDYelpAPIClient.swift` | Public API client class; all Yelp Fusion endpoints |
| `CDYelpRouter.swift` | Alamofire URLRequestConvertible enum for routing |
| `CDYelpEnums.swift` | All public enum types (categories, locales, filters) |
| `Parameters+CDYelpFusionKit.swift` | Request parameter building |
| `CDYelpBusiness.swift` | Business model and nested response types |
| `CDYelpEvent.swift` | Event model |
| `CDYelpSearchResponse.swift` | Search response model |

## CI Jobs

| Job | Runner | Purpose |
|-----|--------|---------|
| iOS | macos-26 (×4), macos-15 | Build iOS scheme |
| macOS | macos-26 (×5), macos-15 (×5) | Build macOS scheme |
| tvOS | macos-26 (×4), macos-15 | Build tvOS scheme |
| watchOS | macos-26 (×4), macos-15 | Build watchOS scheme |
| visionOS | macos-26 (×4) | Build visionOS scheme |
| Catalyst | macos-15 | Build iOS scheme for macOS |
| CocoaPods | macos-15 | `bundle exec pod lib lint` |
| SPM | macos-15 | `swift test` |
| SwiftLint | macos-15 | `swiftlint lint --strict` |
| SwiftFormat | macos-15 | `swiftformat Source Tests --lint` |
| DocC Build | macos-15 | Verify documentation compiles |
| CodeQL | macos-15 | Security scanning |

## Build Commands

```bash
# Build via SPM
swift build

# Run tests
swift test

# Lint
swiftlint lint --strict

# Check formatting (CI mode — reports violations without modifying)
swiftformat Source Tests --lint

# Fix formatting
swiftformat Source Tests

# Generate DocC documentation
swift package --disable-sandbox generate-documentation \
  --target CDYelpFusionKit \
  --output-path docs \
  --transform-for-static-hosting \
  --hosting-base-path CDYelpFusionKit
# After generating, restore the root redirect (generation overwrites docs/index.html):
# Replace docs/index.html with a meta-refresh redirect to /CDYelpFusionKit/documentation/cdyelpfusionkit/

# Preview documentation locally
swift package --disable-sandbox preview-documentation --target CDYelpFusionKit

# CocoaPods lint
bundle exec pod lib lint --allow-warnings
```
