# v8.0.0 Swift 6 Language Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship CDYelpFusionKit v8.0.0 — flip the package to Swift 6 language mode, fix the resulting strict-concurrency diagnostics, and complete the standard release bookkeeping (version strings, CHANGELOG, migration guide).

**Architecture:** No architectural change. This is a compiler-mode flip (`swiftLanguageModes: [.v5]` → `[.v6]` in `Package.swift`) plus fixing whatever the Swift 6 strict-concurrency checker reports, followed by the release-bookkeeping steps every prior major version has required.

**Tech Stack:** Swift 6.0 toolchain (Xcode 16+), Swift Package Manager, SwiftLint, SwiftFormat, XCTest via Swift Testing (`swift test`).

**Spec:** `docs/superpowers/specs/2026-08-18-swift6-language-mode-design.md`

## Global Constraints

- Minimum toolchain becomes Swift 6 / Xcode 16 — already true in practice (CI's oldest runner is Xcode 16.0 / macos-15); this just makes the manifest enforce it.
- Platform minimums (iOS 15 / macOS 12 / tvOS 15 / watchOS 8 / visionOS 1) do **not** change.
- No public API/behavior change beyond what the Swift 6 compiler forces. Prefer the smallest diff that satisfies the checker (e.g. `nonisolated(unsafe)` over restructuring) unless a genuine bug is uncovered.
- The `CDYelpURLSession.perform()` pre-first-`await` serialization tradeoff stays deferred unless `.v6` actually errors on it.
- No "Fixed" section in the `[8.0.0]` CHANGELOG entry for pre-merge self-corrections — fold into Added/Updated.

---

### Task 1: Flip to Swift 6 language mode and resolve concurrency diagnostics

**Files:**
- Modify: `Package.swift:78`
- Modify: `Source/CDYelpMockURLProtocol.swift:30`
- Modify: any other `Source/**/*.swift` file the compiler flags (see Step 4)

**Interfaces:**
- Produces: a `.v6`-clean build — later tasks (test run, lint, xcodebuild) depend on this compiling successfully.

- [ ] **Step 1: Flip the language mode**

In `Package.swift`, change the last line:

```swift
    swiftLanguageModes: [.v5])
```

to:

```swift
    swiftLanguageModes: [.v6])
```

- [ ] **Step 2: Build and capture the diagnostic list**

Run: `swift build 2>&1 | tee /tmp/swift6-build.log`

Expected: build fails. At minimum, expect a concurrency-safety error/warning on `CDYelpMockURLProtocol`'s `static var stubs` (Source/CDYelpMockURLProtocol.swift:30) — the manually-`NSLock`-synchronized static store the Swift 6 checker can't verify.

- [ ] **Step 3: Fix the known diagnostic — `CDYelpMockURLProtocol`**

In `Source/CDYelpMockURLProtocol.swift`, change:

```swift
    private static let lock = NSLock()
    private static var stubs: [String: Stub] = [:]
```

to:

```swift
    private static let lock = NSLock()
    private nonisolated(unsafe) static var stubs: [String: Stub] = [:]
```

This tells the compiler to trust the existing manual `NSLock` synchronization (already correct — every read/write site in this file already lock-guards access) rather than restructuring the storage. No behavior change.

- [ ] **Step 4: Rebuild; fix any further diagnostics; repeat until clean**

Run: `swift build 2>&1 | tee /tmp/swift6-build.log`

If the log contains any more errors or warnings, fix each at its reported file/line using the narrowest fix that satisfies the checker, following the precedent already established in this codebase:
- A type that's genuinely safe but can't be proven so by the compiler (e.g. hand-synchronized state, or state that's provably never mutated after `init`) → `@unchecked Sendable` (types) or `nonisolated(unsafe)` (individual properties), with a one-line comment only if the reason isn't obvious from the surrounding code (see the existing pattern in `Source/CDYelpNetworkError.swift` and `Source/CDYelpResponseCache.swift` for the doc-comment style).
- A closure crossing an isolation boundary that isn't already `@Sendable` → mark it `@Sendable` at the point of definition, not the call site.
- A type stored/passed across isolation boundaries that isn't `Sendable` → add `Sendable` conformance directly if all its stored properties are already `Sendable`; do not add `@unchecked` unless the compiler proves it can't be checked normally.

Do **not** change any public method signature, add `@MainActor`, or introduce actors as part of this step — if a diagnostic seems to require one of those, stop and flag it rather than making an unplanned public API change (this would upgrade the task beyond this plan's scope).

Repeat this step until `swift build` ends with `Build complete!` and zero warnings.

- [ ] **Step 5: Commit**

```bash
git add Package.swift Source/
git commit -m "feat: switch to Swift 6 language mode"
```

---

### Task 2: Verify tests, lint, and format under Swift 6 mode

**Files:**
- Modify (only if diagnostics appear): `Tests/**/*.swift`

**Interfaces:**
- Consumes: the `.v6`-clean build from Task 1.
- Produces: a fully green `swift test` / `swiftlint` / `swiftformat --lint` baseline — later tasks (xcodebuild verification, release bookkeeping) assume this is green.

- [ ] **Step 1: Run the test suite**

Run: `swift test 2>&1 | tee /tmp/swift6-test.log`

Expected: all existing tests pass. If the Swift 6 checker flags anything in `Tests/`, fix it with the same narrowest-fix approach as Task 1 Step 4 (test code is not public API, so a fix here can be more liberal — e.g. marking a test helper `@Sendable` — but still prefer the smallest change).

- [ ] **Step 2: Run SwiftLint**

Run: `swiftlint lint --strict`

Expected: zero violations. If Swift 6 mode fixes introduced any new lint violations (e.g. line length from a longer type annotation), fix them directly — do not add new `// swiftlint:disable` comments (per this project's established preference: refactor over suppress).

- [ ] **Step 3: Run SwiftFormat check**

Run: `swiftformat Source Tests --lint`

Expected: zero violations. If violations appear, run `swiftformat Source Tests` (without `--lint`) to auto-fix, then re-run the `--lint` check to confirm clean.

- [ ] **Step 4: Commit (only if Step 1 required source changes)**

```bash
git add Tests/
git commit -m "test: fix Swift 6 concurrency diagnostics in test target"
```

If no test files changed, skip this commit — nothing to commit.

---

### Task 3: Set Xcode project language mode to Swift 6 and verify with xcodebuild

**Plan amendment (ruled during execution, not in the original spec draft):** `Package.swift`'s `swiftLanguageModes` only governs SPM-driven builds (`swift build`/`swift test`, and Xcode when it resolves the package directly). It does **not** propagate to `CDYelpFusionKit.xcodeproj`, which carries its own independent `SWIFT_VERSION` build setting per target/configuration. Of this project's 11 CI jobs (`.github/workflows/ci.yml`), 7 build via `xcodebuild` against this `.xcodeproj` (iOS, macOS, tvOS, watchOS, Catalyst, visionOS, CodeQL) — without this task, v8.0.0 would ship with those 7 silently still building under Swift 5, checked only by the SPM job (`swift test`) and the DocC job (`swift package generate-documentation`), both of which read `Package.swift` directly. This was caught by the Task 1 reviewer as a "cannot verify from diff" item and ruled in-scope for this task rather than out of scope for the plan.

**Files:**
- Modify: `CDYelpFusionKit.xcodeproj/project.pbxproj`

**Interfaces:**
- Consumes: the `.v6`-clean `swift build`/`swift test` baseline from Tasks 1–2.

- [ ] **Step 1: Bump SWIFT_VERSION in the Xcode project**

In `CDYelpFusionKit.xcodeproj/project.pbxproj`, there are 4 occurrences of `SWIFT_VERSION = 5.0;`. Replace all 4 with `SWIFT_VERSION = 6.0;`.

- [ ] **Step 2: Build the macOS scheme via xcodebuild**

Run:

```bash
xcodebuild build \
  -project "CDYelpFusionKit.xcodeproj" \
  -scheme "CDYelpFusionKit macOS" \
  -destination "platform=macOS" \
  | xcpretty || true
```

(If `xcpretty` isn't installed, drop the pipe and run the bare `xcodebuild` command — just confirm it ends with `** BUILD SUCCEEDED **`.)

Expected: `** BUILD SUCCEEDED **`, now genuinely under Swift 6 language mode. If this surfaces new concurrency diagnostics that `swift build` didn't (possible — `xcodebuild` compiles the platform-specific `UIKit`-linking code paths `swift build` may not exercise identically), fix them with the same narrowest-fix philosophy as Task 1 Step 4, then rebuild until `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**

```bash
git add CDYelpFusionKit.xcodeproj/project.pbxproj
git commit -m "feat: switch Xcode project to Swift 6 language mode"
```

---

### Task 4: Version bump bookkeeping

**Files:**
- Modify: `CDYelpFusionKit.xcodeproj/project.pbxproj`
- Modify: `README.md`
- Modify: `Documentation/Usage.md`

**Interfaces:** none — pure bookkeeping, no code interfaces.

- [ ] **Step 1: Bump MARKETING_VERSION in the Xcode project**

In `CDYelpFusionKit.xcodeproj/project.pbxproj`, there are 4 occurrences of `MARKETING_VERSION = 6.0.1;` (stale since the v7.0.0 release, which was missed at the time). Replace all 4 with `MARKETING_VERSION = 8.0.0;`.

- [ ] **Step 2: Bump the SPM version pin in README.md**

In `README.md:91`, change:

```swift
    .package(url: "https://github.com/chrisdhaan/CDYelpFusionKit.git", .upToNextMajor(from: "7.0.0"))
```

to:

```swift
    .package(url: "https://github.com/chrisdhaan/CDYelpFusionKit.git", .upToNextMajor(from: "8.0.0"))
```

- [ ] **Step 3: Bump the SPM version pin in Documentation/Usage.md**

In `Documentation/Usage.md:15`, apply the identical change (`7.0.0` → `8.0.0` in the same `.upToNextMajor(from:)` line).

- [ ] **Step 4: Verify no other hardcoded version strings were missed**

Run: `grep -rn "7\.0\.0" --include="*.md" --include="*.pbxproj" --include="*.plist" . | grep -v "docs/" | grep -v ".git/"`

Expected: no remaining hits referring to the package's own version (unrelated matches, e.g. a dependency version, are fine — inspect any hit before deciding).

- [ ] **Step 5: Commit**

```bash
git add CDYelpFusionKit.xcodeproj/project.pbxproj README.md "Documentation/Usage.md"
git commit -m "chore: bump version references to 8.0.0"
```

---

### Task 5: CHANGELOG entry and migration guide

**Files:**
- Modify: `CHANGELOG.md`
- Create: `Documentation/CDYelpFusionKit 8.0 Migration Guide.md`

**Interfaces:** none — documentation only.

- [ ] **Step 1: Add the CHANGELOG Table of Contents entry**

In `CHANGELOG.md`, change:

```markdown
## Table of Contents

- [7.0.0](#700---2026-08-07)
```

to:

```markdown
## Table of Contents

- [8.0.0](#800---2026-08-18)
- [7.0.0](#700---2026-08-07)
```

(Use today's actual merge date if this lands on a different day than 2026-08-18.)

- [ ] **Step 2: Add the CHANGELOG version entry**

Immediately above the existing `## [7.0.0] - 2026-08-07` heading, insert:

```markdown
## [8.0.0] - 2026-08-18

### Updated

- CDYelpFusionKit now builds under Swift 6 language mode (`swiftLanguageModes: [.v6]` in `Package.swift`). The minimum toolchain is now Swift 6 / Xcode 16 — already the practical floor via CI, now enforced by the package manifest. Platform minimums (iOS 15 / macOS 12 / tvOS 15 / watchOS 8 / visionOS 1) are unchanged. See the [8.0 Migration Guide](Documentation/CDYelpFusionKit%208.0%20Migration%20Guide.md) for details.

---

```

(Adjust the bullet if Task 1 turned up concurrency fixes beyond `CDYelpMockURLProtocol` that are visible to consumers — e.g. a new `Sendable` conformance on a previously-non-`Sendable` public type. If everything stayed internal/`@unchecked`/`nonisolated(unsafe)`, the single bullet above is sufficient.)

- [ ] **Step 3: Write the migration guide**

Create `Documentation/CDYelpFusionKit 8.0 Migration Guide.md`:

```markdown
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
```

- [ ] **Step 4: Commit**

```bash
git add CHANGELOG.md "Documentation/CDYelpFusionKit 8.0 Migration Guide.md"
git commit -m "docs: add 8.0.0 CHANGELOG entry and migration guide"
```
