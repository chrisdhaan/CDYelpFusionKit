# CDYelpFusionKit

## Overview

CDYelpFusionKit is a Swift framework that wraps the Yelp Fusion REST API. It provides typed request/response models and an `Alamofire`-backed HTTP client.

## Repository Layout

| Path | Description |
|------|-------------|
| `Source/` | Framework source (55 Swift files) |
| `Tests/` | Unit tests (Swift Testing) |
| `Example/` | iOS example app |
| `Resources/` | Asset catalogs (Yelp brand colors, star ratings) |
| `Documentation/` | Usage guide, architecture, migration guide |
| `docs/` | DocC-generated API documentation (GitHub Pages) |
| `scripts/` | Developer scripts (e.g. `generate-docs.sh`) |
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
| macOS | macos-26 (×6), macos-15 (×5) | Build macOS scheme |
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

### Debugging CI Destination Failures

When an `xcodebuild` destination specifier fails (simulator not found, no matching device), check the runner's installed simulators at:

**https://github.com/actions/runner-images** → `images/macos/macos-26-arm64-Readme.md` → "Installed Simulators" table

The **OS** column in that table gives the exact version string required for the `OS=` parameter in xcodebuild destination specifiers. Key gotchas:

- **iOS/visionOS point releases**: the iOS 26.4 and visionOS 26.4 simulators have OS `26.4.1` (not `26.4`) — tvOS and watchOS 26.4 stay at `26.4`

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

# Generate DocC documentation (restores root redirect, adds .nojekyll and 404.html)
bash scripts/generate-docs.sh

# Preview documentation locally
swift package --disable-sandbox preview-documentation --target CDYelpFusionKit

# CocoaPods lint
bundle exec pod lib lint --allow-warnings
```
