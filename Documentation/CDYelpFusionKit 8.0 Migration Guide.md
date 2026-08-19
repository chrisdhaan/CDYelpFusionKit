# CDYelpFusionKit 8.0 Migration Guide

This guide covers migrating from CDYelpFusionKit 7.x to 8.0.

---

## Overview

CDYelpFusionKit 8.0 switches the package to Swift 6 language mode (`swiftLanguageModes: [.v6]`). The public API is unchanged — every type and method your code already calls has the same signature. What changes is the **minimum toolchain**: building this package now requires Swift 6 (Xcode 16 or later).

In practice this is not a new requirement — CDYelpFusionKit's CI has only tested against Xcode 16.0+ since well before this release. 8.0 makes that floor explicit in the package manifest rather than implicit in CI configuration.

---

## 1. Minimum toolchain is now Swift 6 / Xcode 16

If you're already building with Xcode 16 or later, this release requires no action.

If you're on an older Xcode version, upgrade to Xcode 16 or later before adopting CDYelpFusionKit 8.0. Stay on `7.0.0` if you need to remain on an older toolchain for now — it will continue to build under Swift 5 language mode indefinitely.

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
