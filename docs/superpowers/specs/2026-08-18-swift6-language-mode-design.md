# v8.0.0 — Swift 6 Language Mode

## Goal

Ship CDYelpFusionKit v8.0.0: flip `swiftLanguageModes` from `[.v5]` to `[.v6]` in `Package.swift`, fix whatever strict-concurrency diagnostics that forces, and release under semver as a major version (the language-mode flip is itself a source-compatibility-affecting change for consumers who haven't opted into Swift 6 checking themselves).

## Scope

**In scope:**
- `Package.swift`: `swiftLanguageModes: [.v6]`
- Fixing any Swift 6 strict-concurrency compiler diagnostics that result
- Standard release bookkeeping (version strings, CHANGELOG, migration guide)

**Explicitly out of scope:**
- Platform minimum bumps (iOS 15 / macOS 12 / tvOS 15 / watchOS 8 / visionOS 1 stay as-is — independent of language mode)
- CI matrix changes — the oldest runner is already Xcode 16.0 (macos-15), which is already the Swift 6 toolchain floor; no "drop old Xcode" work is needed
- Any public API/behavior change not forced by the compiler under `.v6`
- The known, deliberately-deferred `CDYelpURLSession.perform()` tradeoff (actor-isolated setup serializes concurrent calls pre-first-`await`; a real fix requires the generic `T: Decodable` to also be `Sendable`, itself a breaking API change) — stays deferred unless the `.v6` compiler actually errors on it. No consumer has reported a real bottleneck.

## Context / why this is a smaller lift than a typical Swift 6 migration

An audit of the current source tree before writing this spec found the codebase already well-prepared:
- `CDYelpAPIClient` (Source/CDYelpAPIClient.swift:34) is `async`/`await`-only — no completion-handler closures to retrofit with `@Sendable` — and the class itself is already `Sendable`.
- Protocols consumers implement are already `Sendable`: `CDYelpEventMonitor` (Source/CDYelpEventMonitor.swift:31), `CDYelpRequestAdapter` (Source/CDYelpRequestAdapter.swift:44).
- Types with justified unchecked concurrency are already annotated and documented: `CDYelpResponseCache` (`@unchecked Sendable`), `CDYelpNetworkError` (`@unchecked Sendable`, with an explanatory doc comment).
- A repo-wide grep for `static var`, `DispatchQueue`, `NSLock`/`NSRecursiveLock`, and delegate patterns outside `CDYelpMockURLProtocol.swift` turned up nothing else of concern.

**One known concurrency-checker hit, found by inspection:**

`CDYelpMockURLProtocol` (Source/CDYelpMockURLProtocol.swift) holds `private static let lock = NSLock()` and `private static var stubs: [String: Stub] = [:]` (lines 29–30), manually synchronized by hand in every accessor. The Swift 6 checker can't verify manual `NSLock` synchronization, so it will flag `stubs` as a non-concurrency-safe static. `URLProtocol`'s override points (`canInit(with:)`, `startLoading()`) are synchronous, non-actor-isolated class methods defined by Foundation — converting the storage to an actor isn't an option. Fix: `nonisolated(unsafe) private static var stubs`, which tells the compiler to trust the existing (already-correct) manual lock. Smallest possible diff; no behavior change.

Beyond this, the plan is to let the compiler be the source of truth: flip the flag, build, and fix whatever else it reports — not to pre-enumerate every diagnostic here.

## Version & release bookkeeping

Per a lesson from the v7.0.0 release (a hardcoded version-pin miss caught only in final review, not any per-task review): grep for hardcoded version strings explicitly rather than asserting none need changing.

- `CDYelpFusionKit.xcodeproj/project.pbxproj`: `MARKETING_VERSION` is currently stale at `6.0.1` (missed during the v7.0.0 release). Correct it straight to `8.0.0` as part of this same edit.
- `README.md` / `Documentation/Usage.md`: bump the `.upToNextMajor(from: "7.0.0")` SPM dependency pin to `8.0.0`.
- `CHANGELOG.md`: new `[8.0.0]` entry + Table of Contents row. No "Fixed" section for the unreleased version — fold any pre-merge self-corrections into Added/Updated.
- New `Documentation/CDYelpFusionKit 8.0 Migration Guide.md`, matching the format of the existing 4.0/5.0/6.0/7.0 guides. Main content: minimum toolchain is now Swift 6 / Xcode 16 (already true in practice via CI, now enforced by the manifest), `swiftLanguageModes` is `.v6`, and what that means for a consumer's own strict-concurrency settings.

## Verification plan

- `swift build` and `swift test` under `.v6`
- `swiftlint lint --strict`
- `swiftformat Source Tests --lint`
- At least one `xcodebuild` scheme build — SPM-only checks have missed xcodeproj-level divergence before (access levels, deployment targets, target-level overrides)
- DocC regeneration (`bash scripts/generate-docs.sh`) is a separate follow-up commit after merge, matching the existing release pattern — not part of this PR

## Process notes

- This spec/plan/implementation work happens in an isolated worktree (branch `worktree-feat-swift6-language-mode`), not on local `master` — avoids the divergence pain hit during v7.0.0 when spec/plan commits landed on `master` before a worktree existed.
- `master` currently has an unrelated uncommitted `.gitignore` change (a `.claude/onlydiff/` entry) that predates this task — left alone, not carried into this branch.
