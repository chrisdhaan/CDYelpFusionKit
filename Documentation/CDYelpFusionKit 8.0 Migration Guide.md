# CDYelpFusionKit 8.0 Migration Guide

This guide covers migrating from CDYelpFusionKit 7.x to 8.0.

---

## Overview

CDYelpFusionKit 8.0 switches the package's **language mode** to Swift 6 (`swiftLanguageModes: [.v6]`), so the library's own source is now built and type-checked under the Swift 6 strict-concurrency checker. The Xcode project's `SWIFT_VERSION` build setting was bumped to `6.0` to match, for consumers who build via the Xcode project / `xcodebuild` rather than pure SwiftPM. The public API is unchanged — every type and method your code already calls has the same signature.

This does **not** change the minimum toolchain needed to resolve the package. CDYelpFusionKit's `Package.swift` has declared `// swift-tools-version:6.0` since the 4.0.0 release, and 7.0.0 (the immediately prior release) already required it — so a Swift 6 SwiftPM toolchain (Xcode 16 or later) has been necessary to even resolve this package's manifest for several major versions now, not starting with 8.0.

---

## 1. Minimum toolchain: unchanged, and it's been Swift 6 / Xcode 16 for a while

If you're already building with Xcode 16 or later — which has been true for anyone successfully resolving CDYelpFusionKit since well before this release — this release requires no toolchain action.

If you're on an older Xcode version and have not yet been able to adopt any recent CDYelpFusionKit release, upgrading to Xcode 16 or later is not optional for 8.0 specifically — it was already required by the SwiftPM manifest as of 7.0.0 (and earlier). Downgrading to 7.0.0 will not restore compatibility with an older toolchain. If you need a release whose manifest supports an older Swift toolchain, check the `Package.swift` of prior tagged releases for the declared `swift-tools-version` that matches what your toolchain supports — CDYelpFusionKit 3.2.0 was the last release with a pre-6.0 manifest (`swift-tools-version:5.6`).

---

## 2. What Swift 6 language mode means for your project

CDYelpFusionKit's own source now builds under the Swift 6 strict-concurrency checker. This does **not** require your consuming project to also be in Swift 6 language mode — a Swift 5 language mode project can depend on a Swift 6 language mode package without issue. If your project *is* also in Swift 6 language mode (or has `StrictConcurrency` enabled under Swift 5), CDYelpFusionKit's public types were already `Sendable`-annotated as of earlier releases, so no new concurrency warnings are expected at your call sites.

---

## Migration Checklist

- [ ] **Upgrade to Xcode 16+** if you haven't already
- [ ] **Run your test suite** to confirm no regressions (none are expected — this release has no public API or behavior changes)

---

## Support

- [CDYelpFusionKit GitHub Issues](https://github.com/chrisdhaan/CDYelpFusionKit/issues)
- [Usage Guide](Usage.md)
