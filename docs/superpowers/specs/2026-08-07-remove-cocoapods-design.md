# Remove CocoaPods Support — Design

**Date:** 2026-08-07
**Status:** Approved

## Summary

Drop CocoaPods as a supported distribution channel for CDYelpFusionKit. Swift Package Manager becomes the sole supported install method. Released as **v7.0.0** (major version bump — a previously-supported public distribution channel is being discontinued, even though no source/API changes are involved).

## Motivation

CocoaPods removal was flagged as planned future work during the v6.0.1 monthly-audit release (2026-08-06). The project is solo-maintained and in maintenance mode; CocoaPods adds Ruby/Bundler/`xcodeproj`-gem tooling overhead (a whole CI job, a Gemfile/Gemfile.lock, `pod trunk push` publish step) for a channel that's redundant with SPM, which is the sole channel used for the framework's own CI validation of source changes anyway.

## Scope

Packaging, CI, and documentation only. **No source code changes.** No behavior change for SPM consumers.

## Changes

### Files removed
- `CDYelpFusionKit.podspec`
- `Gemfile`
- `Gemfile.lock`
- `.bundle/` entry in `.gitignore` (nothing generates it once Bundler is gone)

### CI (`.github/workflows/ci.yml`)
- Delete the `CocoaPods` job (`pod lib lint`, `bundle install`, the `Pods` actions/cache step) entirely.

### Documentation
- `README.md` — remove the 3 CocoaPods shield badges (Platforms/CocoaPods Compatible/License badges that point at `cocoapods.org`) and the `### CocoaPods` install subsection. SPM install instructions remain as-is and become the only install method shown.
- `Documentation/Usage.md` — remove the `#### CocoaPods` install subsection (mirrors README's install section).
- `.github/ISSUE_TEMPLATE/bug_report.md` — change "Installation method (SPM / CocoaPods / Carthage)" to "Installation method (SPM)".
- `CLAUDE.md` — remove `CDYelpFusionKit.podspec`/`Gemfile` rows from the Repository Layout table, remove the `CocoaPods` row from the CI Jobs table, remove `bundle exec pod lib lint --allow-warnings` from Build Commands.
- Historical migration guides (`Documentation/CDYelpFusionKit 4.0/5.0/6.0 Migration Guide.md`) — **left untouched**. They're a historical record of what those versions supported at the time of their own release.
- New `Documentation/CDYelpFusionKit 7.0 Migration Guide.md` — documents the CocoaPods removal, tells existing pod users their options (pin to `6.0.1`, forever, via their `Podfile`, or migrate to SPM), and gives SPM setup instructions. Follows the structure of the existing migration guides (What Changed / Migration Steps / Checklist / Support).
- `README.md`'s Documentation list — add a link to the new v7.0 migration guide, following the existing pattern used for the v6.0 guide link.
- `CHANGELOG.md` — new `## [7.0.0]` entry with a `### Removed` section documenting the CocoaPods drop; add to the Table of Contents.

### Out of scope / explicitly not touched
- `docs/` (DocC-generated site) — no CocoaPods content lives there; a docs regen happens at release time per the existing `scripts/generate-docs.sh` process, not as part of this change.
- Source code — zero changes.
- CocoaPods trunk's already-published versions (up through 6.0.1) — they remain resolvable forever; this work only stops *future* publishes.

## Trunk deprecation (gated, separate from implementation)

CocoaPods trunk supports `pod trunk deprecate CDYelpFusionKit` to mark the pod as deprecated so `pod install`/`pod outdated` warn existing consumers, without unpublishing already-released versions. This is an external, irreversible action against a public registry (distinct from a local repo change), so it will be proposed as an explicit command for review and run only after separate, explicit go-ahead — not bundled into the PR-open step.

## Versioning note

No file in the repo carries a version string that needs bumping for this change (the podspec, which had `s.version = '6.0.1'`, is being deleted; `Package.swift` doesn't self-version). The v7.0.0 designation lives in the git tag, GitHub Release, and CHANGELOG at release time, same as prior releases.

## Workflow

1. New branch off `master` (e.g. `remove/cocoapods-support`).
2. Implement all changes above.
3. Verify: `swiftlint lint --strict`, `swiftformat Source Tests --lint`, `swift test`, at least one `xcodebuild` scheme build (SPM alone doesn't validate this project — see project memory), and a final `git grep -ri cocoapods` sweep to confirm no stray references remain outside the historical migration guides.
4. Commit, push, open PR. **Stop there.**
5. Merge, tag `7.0.0`, GitHub Release, DocC regen, and CocoaPods trunk deprecation all wait for explicit user go-ahead in a follow-up — matching the v6.0.1/v6.0.0 release pattern.

## Testing

No automated tests apply (no source changes). Verification is the build/lint/CI-sweep checklist above, run locally before pushing.
