# Remove CocoaPods Support Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove CocoaPods as a supported distribution channel for CDYelpFusionKit, leaving SPM as the sole supported install method, and open a PR for a v7.0.0 release.

**Architecture:** This is a packaging/CI/documentation-only change — zero source code is touched. Work proceeds file-by-file: delete CocoaPods packaging artifacts and their CI job, update all consumer-facing install docs, update the project's own CLAUDE.md, then add the new version's CHANGELOG entry and migration guide. Each task is independently verifiable (no source compiles differently, so verification is build/lint/grep-based, not unit tests).

**Tech Stack:** Swift Package Manager, SwiftLint, SwiftFormat, GitHub Actions (YAML), Markdown.

## Global Constraints

- No source code in `Source/` or `Tests/` changes — this is packaging/CI/docs only, per spec.
- Historical migration guides (`Documentation/CDYelpFusionKit 4.0/5.0/6.0 Migration Guide.md`) must NOT be edited — left as historical record, per spec.
- `docs/` (DocC site) is out of scope — not touched in this plan.
- Do not run `pod trunk deprecate` or any other action against the public CocoaPods trunk registry as part of this plan — that is a separate, explicitly-gated follow-up per spec.
- Do not merge, tag, or create a GitHub Release as part of this plan — stop after opening the PR, per spec.
- Branch name: `remove/cocoapods-support`, created off `master`.

---

## Task 1: Create branch and remove CocoaPods packaging files + CI job

**Files:**
- Delete: `CDYelpFusionKit.podspec`
- Delete: `Gemfile`
- Delete: `Gemfile.lock`
- Modify: `.gitignore` (remove the `# Bundler` / `.bundle/` entry)
- Modify: `.github/workflows/ci.yml` (remove the `CocoaPods` job)

**Interfaces:** None (no code).

- [ ] **Step 1: Create the branch**

```bash
git checkout master
git pull
git checkout -b remove/cocoapods-support
```

- [ ] **Step 2: Delete the podspec and Ruby/Bundler files**

```bash
git rm CDYelpFusionKit.podspec Gemfile Gemfile.lock
```

- [ ] **Step 3: Remove the now-unused `.bundle/` gitignore entry**

Open `.gitignore` and remove these two lines (the blank line above `# Bundler` may stay or go — match surrounding spacing):

```
# Bundler
.bundle/
```

- [ ] **Step 4: Remove the CocoaPods CI job**

In `.github/workflows/ci.yml`, delete the entire `CocoaPods:` job block. It starts at the line `  CocoaPods:` and runs through the line `        run: bundle exec pod lib lint --allow-warnings` (the blank line immediately before the next job, `  SPM:`, marks the end — delete up to but not including that job).

- [ ] **Step 5: Verify no orphaned references remain in the workflow**

Run: `grep -n -i "cocoapods\|bundle exec\|pod lib lint" .github/workflows/ci.yml`
Expected: no output (empty match).

- [ ] **Step 6: Verify the YAML is still well-formed**

Run: `ruby -ryaml -e "YAML.load_file('.github/workflows/ci.yml')" && echo VALID`
Expected: `VALID` printed, no exception.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "chore: remove CocoaPods packaging files and CI job"
```

---

## Task 2: Update install-facing docs (README, Usage guide, issue template)

**Files:**
- Modify: `README.md`
- Modify: `Documentation/Usage.md`
- Modify: `.github/ISSUE_TEMPLATE/bug_report.md`

**Interfaces:** None (no code). Depends on Task 1 only in that it belongs on the same branch — no file overlap.

- [ ] **Step 1: Remove the CocoaPods badges from README.md**

In `README.md`, delete these three `<a>...</a>` blocks (each wraps a `shields.io/cocoapods/...` badge pointing at `cocoapods.org/pods/CDYelpFusionKit`):

```html
    <a href="http://cocoapods.org/pods/CDYelpFusionKit">
        <img src="https://img.shields.io/cocoapods/p/CDYelpFusionKit.svg?style=flat" alt="Platforms">
    </a>
    <a href="http://cocoapods.org/pods/CDYelpFusionKit">
        <img src="https://img.shields.io/cocoapods/v/CDYelpFusionKit.svg?style=flat" alt="CocoaPods Compatible">
    </a>
```

and

```html
    <a href="http://cocoapods.org/pods/CDYelpFusionKit">
        <img src="https://img.shields.io/cocoapods/l/CDYelpFusionKit.svg?style=flat" alt="License">
    </a>
```

- [ ] **Step 2: Remove the CocoaPods install section from README.md**

Delete this section (falls right after the SPM instructions, before "## Documentation"):

```markdown
### CocoaPods

Add to your `Podfile`:

```ruby
pod 'CDYelpFusionKit', '~> 6.0'
```

Then run `pod install`.

```

- [ ] **Step 3: Add the v7.0 migration guide link to README.md's Documentation list**

In the `## Documentation` list in `README.md`, add a new line following the existing v6.0 guide's pattern:

```markdown
- **[Migration Guide (v7.0)](Documentation/CDYelpFusionKit%207.0%20Migration%20Guide.md)** — Upgrade from v6.x to v7.0 (CocoaPods removal)
```

Place it directly above the existing `- **[Migration Guide](Documentation/CDYelpFusionKit%206.0%20Migration%20Guide.md)**` line, and reword that existing line's link text to `Migration Guide (v6.0)` so the two are distinguishable.

- [ ] **Step 4: Remove the CocoaPods install section from Documentation/Usage.md**

Delete the `#### CocoaPods` subsection (the same `pod 'CDYelpFusionKit', '~> 6.0'` / `pod install` content as README, immediately before `#### Carthage (Legacy)`).

- [ ] **Step 5: Update the issue template's installation-method line**

In `.github/ISSUE_TEMPLATE/bug_report.md`, change:

```markdown
- Installation method (SPM / CocoaPods / Carthage):
```

to:

```markdown
- Installation method (SPM):
```

- [ ] **Step 6: Verify no stray CocoaPods references remain in these three files**

Run: `grep -n -i cocoapods README.md Documentation/Usage.md .github/ISSUE_TEMPLATE/bug_report.md`
Expected: no output (empty match).

- [ ] **Step 7: Commit**

```bash
git add README.md Documentation/Usage.md .github/ISSUE_TEMPLATE/bug_report.md
git commit -m "docs: remove CocoaPods install instructions from README and Usage guide"
```

---

## Task 3: Update CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

**Interfaces:** None (no code).

- [ ] **Step 1: Remove podspec/Gemfile rows from the Repository Layout table**

In `CLAUDE.md`'s "## Repository Layout" table, delete the rows:

```markdown
| `CDYelpFusionKit.podspec` | CocoaPods spec |
```

and

```markdown
| `Gemfile` | Ruby dependencies (CocoaPods) |
```

(Match against the actual current row text in the file — the table's exact wording may differ slightly; remove whichever rows reference the podspec and Gemfile.)

- [ ] **Step 2: Remove the CocoaPods row from the CI Jobs table**

In the "## CI Jobs" table, delete the row:

```markdown
| CocoaPods | macos-15 | `bundle exec pod lib lint` |
```

- [ ] **Step 3: Remove the CocoaPods lint command from Build Commands**

In the "## Build Commands" code block, delete the line:

```bash
# CocoaPods lint
bundle exec pod lib lint --allow-warnings
```

- [ ] **Step 4: Verify no stray CocoaPods references remain**

Run: `grep -n -i cocoapods CLAUDE.md`
Expected: no output (empty match).

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: remove CocoaPods references from CLAUDE.md"
```

---

## Task 4: Add v7.0 migration guide and CHANGELOG entry

**Files:**
- Create: `Documentation/CDYelpFusionKit 7.0 Migration Guide.md`
- Modify: `CHANGELOG.md`

**Interfaces:** None (no code). The migration guide's filename must exactly match the link added in Task 2 Step 3: `Documentation/CDYelpFusionKit 7.0 Migration Guide.md`.

- [ ] **Step 1: Read the v6.0 migration guide to match its structure**

Run: `cat "Documentation/CDYelpFusionKit 6.0 Migration Guide.md"`

Note its section structure (intro, "What Changed" headers, migration steps, checklist, "## Support" footer) — the new guide should follow the same shape.

- [ ] **Step 2: Create the v7.0 migration guide**

Write `Documentation/CDYelpFusionKit 7.0 Migration Guide.md`:

```markdown
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

## Migration Checklist

- [ ] **Switch to SPM** — add the package via Xcode's **File → Add Packages**, or add a `.package(url:...)` entry to your own `Package.swift`
- [ ] **Remove CocoaPods integration** — delete the `pod 'CDYelpFusionKit'` line from your `Podfile` and run `pod install`
- [ ] **Run your test suite** to confirm no regressions (none are expected — this release has no source changes)

---

## Support

- [CDYelpFusionKit GitHub Issues](https://github.com/chrisdhaan/CDYelpFusionKit/issues)
- [Usage Guide](Usage.md)
```

- [ ] **Step 3: Add the 7.0.0 entry to CHANGELOG.md's table of contents**

In `CHANGELOG.md`, add a new line to the "## Table of Contents" list, immediately above the existing `6.0.1` entry:

```markdown
- [7.0.0](#700---2026-08-07)
```

(Adjust the date in the anchor/heading in Step 4 below to the actual PR-open date if it differs from today.)

- [ ] **Step 4: Add the 7.0.0 changelog entry**

Immediately below the `---` divider and above the existing `## [6.0.1] - 2026-08-06` heading, add:

```markdown
## [7.0.0] - 2026-08-07

### Removed

- CocoaPods is no longer a supported distribution channel. Swift Package Manager is now the only supported way to install CDYelpFusionKit. The last version published to CocoaPods trunk is `6.0.1`. See the [7.0 Migration Guide](Documentation/CDYelpFusionKit%207.0%20Migration%20Guide.md) for details.

```

- [ ] **Step 5: Verify the new migration guide file exists and the link target matches**

Run: `ls "Documentation/CDYelpFusionKit 7.0 Migration Guide.md" && grep -n "7.0 Migration Guide" README.md CHANGELOG.md`
Expected: the file listing succeeds, and both `README.md` and `CHANGELOG.md` show a matching link line.

- [ ] **Step 6: Commit**

```bash
git add "Documentation/CDYelpFusionKit 7.0 Migration Guide.md" CHANGELOG.md
git commit -m "docs: add v7.0 migration guide and CHANGELOG entry for CocoaPods removal"
```

---

## Task 5: Full verification sweep, push, and open PR

**Files:** None created/modified — verification and PR only.

**Interfaces:** None.

- [ ] **Step 1: Repo-wide sweep for stray CocoaPods references**

Run: `git grep -il cocoapods -- . ':!Documentation/CDYelpFusionKit 4.0 Migration Guide.md' ':!Documentation/CDYelpFusionKit 5.0 Migration Guide.md' ':!Documentation/CDYelpFusionKit 6.0 Migration Guide.md' ':!CHANGELOG.md'`

Expected: no output. (The three historical migration guides are deliberately excluded — they retain their original CocoaPods mentions per the spec. `CHANGELOG.md` is excluded because older entries legitimately mention "CocoaPods trunk published" for past releases.)

- [ ] **Step 2: SwiftLint**

Run: `swiftlint lint --strict`
Expected: no violations (this task made no source changes, so this should be unaffected — run it to confirm no environment drift).

- [ ] **Step 3: SwiftFormat check**

Run: `swiftformat Source Tests --lint`
Expected: no violations.

- [ ] **Step 4: SPM test suite**

Run: `swift test`
Expected: all tests pass.

- [ ] **Step 5: Xcode build for at least one scheme**

Run: `xcodebuild -project CDYelpFusionKit.xcodeproj -scheme "CDYelpFusionKit iOS" -destination "generic/platform=iOS Simulator" clean build`
Expected: `** BUILD SUCCEEDED **`. (Per project memory: `swift test` alone doesn't validate the `.xcodeproj`/podspec-adjacent build — with the podspec now gone, this confirms the Xcode project itself still builds cleanly without it.)

- [ ] **Step 6: Push and open the PR**

```bash
git push -u origin remove/cocoapods-support
gh pr create --title "Remove CocoaPods support (v7.0.0)" --body "$(cat <<'EOF'
## Summary
- Removes CocoaPods as a supported distribution channel; SPM is now the only supported install method
- Deletes `CDYelpFusionKit.podspec`, `Gemfile`, `Gemfile.lock`, and the `CocoaPods` CI job
- Removes CocoaPods install instructions/badges from README and Usage guide; historical migration guides (4.0/5.0/6.0) are left untouched
- Adds a v7.0 migration guide and CHANGELOG entry documenting the removal (last CocoaPods-published version: 6.0.1)

No source code changes — packaging/CI/docs only.

## Test plan
- [x] `swiftlint lint --strict`
- [x] `swiftformat Source Tests --lint`
- [x] `swift test`
- [x] `xcodebuild` (iOS scheme) clean build
- [x] Repo-wide grep sweep confirms no stray CocoaPods references outside historical migration guides

Merge, tag `7.0.0`, GitHub Release, and CocoaPods trunk deprecation are deliberately deferred to a follow-up once this PR is reviewed.
EOF
)"
```

- [ ] **Step 7: Report the PR URL back to the user**

The `gh pr create` command prints the PR URL on success — surface it directly; this is the handoff point for user review before any merge/tag/release/trunk-deprecate action.

---

## Post-plan (explicitly not part of this plan's tasks)

- Merging the PR, tagging `7.0.0`, publishing the GitHub Release, and regenerating DocC — deferred to a follow-up once the user reviews the PR.
- `pod trunk deprecate CDYelpFusionKit` — deferred to a follow-up, run only after explicit user go-ahead in the moment (per spec, this is a separate gate from PR review).
