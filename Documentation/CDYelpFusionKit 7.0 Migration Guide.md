# CDYelpFusionKit 7.0 Migration Guide

This guide covers migrating from CDYelpFusionKit 6.x to 7.0.

---

## Overview

CDYelpFusionKit 7.0 removes CocoaPods as a supported distribution channel. **Swift Package Manager is now the only supported way to install CDYelpFusionKit.** There are no source or API changes in this release — if you already consume CDYelpFusionKit via SPM, this release requires no code changes on your part.

---

## 1. CocoaPods is no longer supported

As of 7.0.0, no new versions of CDYelpFusionKit will be published to CocoaPods trunk. The last version available via CocoaPods is `6.0.1`.

**If you currently install via CocoaPods, you have two options:**

- **Migrate to SPM (recommended).** In Xcode: **File → Add Packages**, enter `https://github.com/chrisdhaan/CDYelpFusionKit.git`, and select the "Up to Next Major Version" rule starting at `7.0.0`. Then remove `pod 'CDYelpFusionKit'` from your `Podfile` and run `pod install` to deintegrate it.
- **Stay on CocoaPods, pinned.** Keep `pod 'CDYelpFusionKit', '~> 6.0'` in your `Podfile`. Version `6.0.1` will remain resolvable indefinitely, but will not receive further bug fixes or updates.

---

## Migration Checklist (if switching to SPM)

- [ ] **Switch to SPM** — add the package via Xcode's **File → Add Packages**, or add a `.package(url:...)` entry to your own `Package.swift`
- [ ] **Remove CocoaPods integration** — delete the `pod 'CDYelpFusionKit'` line from your `Podfile` and run `pod install`
- [ ] **Run your test suite** to confirm no regressions (none are expected — this release has no source changes)

---

## Support

- [CDYelpFusionKit GitHub Issues](https://github.com/chrisdhaan/CDYelpFusionKit/issues)
- [Usage Guide](Usage.md)
