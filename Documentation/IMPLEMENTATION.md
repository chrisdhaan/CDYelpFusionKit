# CDYelpFusionKit 4.0.0 Modernization Implementation Plan

This document describes every change required to modernize CDYelpFusionKit from its current 3.2.0 state (last updated August 2022) to a fully modern 4.0.0 release. The reference standard is the CDMarkdownKit v3.0.0 modernization commit (`4ece4c7`) and its companion changelog commit (`f835225`), performed in May 2026.

---

## Table of Contents

- [Overview](#overview)
- [Section 1: GitHub Community Files](#section-1-github-community-files)
- [Section 2: Ruby and Documentation Tooling](#section-2-ruby-and-documentation-tooling)
- [Section 3: CI/CD Pipeline Modernization](#section-3-cicd-pipeline-modernization)
- [Section 4: Package.swift Modernization](#section-4-packageswift-modernization)
- [Section 5: Remove Versioned Package Files](#section-5-remove-versioned-package-files)
- [Section 6: CocoaPods Podspec Modernization](#section-6-cocoapods-podspec-modernization)
- [Section 7: Privacy Manifest](#section-7-privacy-manifest)
- [Section 8: Xcode Project Modernization](#section-8-xcode-project-modernization)
- [Section 9: Source Code Modernization](#section-9-source-code-modernization)
- [Section 10: Unit Tests](#section-10-unit-tests)
- [Section 11: Documentation](#section-11-documentation)
- [Section 12: CHANGELOG.md Reformat](#section-12-changelogmd-reformat)
- [Section 13: README.md Restructure](#section-13-readmemd-restructure)
- [Section 14: Dependency Updates](#section-14-dependency-updates)
- [Section 15: Version Bump and Release](#section-15-version-bump-and-release)
- [Section 16: visionOS Support](#section-16-visionos-support)
- [Section 17: DocC Documentation](#section-17-docc-documentation)
- [Section 18: SwiftFormat](#section-18-swiftformat)
- [Breaking Changes Summary](#breaking-changes-summary)

---

## Overview

### Current State (3.2.0 — August 2022)

| Area | Current Value |
|------|--------------|
| swift-tools-version | 5.6 |
| iOS minimum | 10.0 |
| macOS minimum | 10.12 |
| tvOS minimum | 10.0 |
| watchOS minimum | 3.0 |
| Xcode project SWIFT_VERSION | 5.0 |
| Alamofire | 5.6.1 (pinned) |
| CI runners | macOS-10.15, macOS-11, macOS-12 |
| CI Xcode | 12.4 – 13.4.1 |
| CI formatter | xcpretty |
| CI dep manager | Carthage |
| Actions checkout | v3 |
| Privacy manifest | None |
| Test target | None |
| SwiftLint CI job | None |
| CodeQL CI job | None |
| CocoaPods CI | Inline gem install |
| Documentation | README only |
| Gemfile | None |
| CLAUDE.md | None |

### Target State (4.0.0)

| Area | Target Value |
|------|-------------|
| swift-tools-version | 6.0 |
| iOS minimum | 12.0 |
| macOS minimum | 10.13 |
| tvOS minimum | 12.0 |
| watchOS minimum | 4.0 |
| visionOS minimum | 1.0 |
| Xcode project SWIFT_VERSION | 5.0 (retained; swiftLanguageModes governs) |
| Alamofire | Latest stable (≥ 5.9) |
| CI runners | macOS-15, macos-26 |
| CI Xcode | 16.4 (macOS-15), 26.x (macos-26) |
| CI formatter | xcbeautify |
| CI dep manager | SPM only (Carthage removed) |
| Actions checkout | v4 |
| Privacy manifest | Source/PrivacyInfo.xcprivacy |
| Test target | CDYelpFusionKitTests |
| SwiftLint CI job | Yes |
| CodeQL CI job | Yes |
| visionOS CI job | Yes |
| SwiftFormat CI job | Yes |
| DocC CI job | Yes |
| CocoaPods CI | bundle exec (Gemfile-managed) |
| Documentation | Usage.md, ARCHITECTURE.md, Migration Guide, CLAUDE.md |
| API docs | DocC (chrisdhaan.github.io/CDYelpFusionKit) |
| Gemfile | Yes |
| CLAUDE.md | Yes |

### Why These Targets?

iOS 12.0, macOS 10.13, tvOS 12.0, and watchOS 4.0 are the lowest floors SPM 6.0 accepts without deprecation warnings. They also satisfy Alamofire 5.9+'s minimum requirements. Going lower is not possible without adding version-specific Package files (which we are removing). visionOS 1.0 is the first visionOS release and is supported by Alamofire 5.9+ and all modern Xcode toolchains on macos-26 CI runners.

---

## Section 1: GitHub Community Files

### 1.1 Replace Monolithic Issue Template ✅

**Current:** `.github/ISSUE_TEMPLATE.md` — a single flat file  
**Target:** A structured directory `.github/ISSUE_TEMPLATE/` with three files

**Delete:**
```
.github/ISSUE_TEMPLATE.md
```

**Create `.github/ISSUE_TEMPLATE/config.yml`:**
```yaml
blank_issues_enabled: false
contact_links:
  - name: Usage Question
    url: https://stackoverflow.com/questions/tagged/cdyelpfusionkit
    about: Ask usage questions on Stack Overflow.
  - name: Yelp Fusion API Issue
    url: https://github.com/Yelp/yelp-fusion/issues
    about: Report Yelp Fusion API issues to the Yelp team.
```

**Create `.github/ISSUE_TEMPLATE/bug_report.md`:**
```markdown
---
name: Bug Report
about: Report a bug in CDYelpFusionKit
title: ''
labels: bug
assignees: chrisdhaan
---

## Description

> A clear and concise description of the bug.

## Steps to Reproduce

> Steps to reproduce the behavior.

## Expected Behavior

> A clear and concise description of what you expected to happen.

## Actual Behavior

> A clear and concise description of what actually happened.

## Environment

- CDYelpFusionKit version:
- Xcode version:
- Swift version:
- iOS/macOS/tvOS/watchOS version:
- Installation method (SPM / CocoaPods / Carthage):
```

**Create `.github/ISSUE_TEMPLATE/feature_request.md`:**
```markdown
---
name: Feature Request
about: Suggest an enhancement for CDYelpFusionKit
title: ''
labels: enhancement
assignees: chrisdhaan
---

## Summary

> A concise description of the feature you'd like to see.

## Motivation

> Why would this feature be valuable? What problem does it solve?

## Proposed Solution

> If you have a specific implementation in mind, describe it here.
```

### 1.2 Update Pull Request Template ✅

**File:** `.github/PULL_REQUEST_TEMPLATE.md`

Replace the existing content with the CDMarkdownKit v3.0.0 standard format:

```markdown
## Issue

> Link the issue(s) this PR resolves, or explain the motivation if there is no issue.

## Goals

> Describe what this PR accomplishes.

## Implementation Details

> Describe the technical approach and any important decisions made.

## Testing Details

> Describe how the changes were tested.
```

**Changes:**
- Remove emoji from section headers
- Replace comment instructions with blockquote guidance
- Standardize to four sections: Issue, Goals, Implementation Details, Testing Details

### 1.3 Add GitHub Funding Configuration ✅

**Create `.github/FUNDING.yml`:**
```yaml
github: chrisdhaan
```

---

## Section 2: Ruby and Documentation Tooling

### 2.1 Add Gemfile ✅

**Create `Gemfile`** in the repository root:
```ruby
source 'https://rubygems.org'

gem 'cocoapods'
```

**Note:** `jazzy` is intentionally omitted. API documentation is now generated via DocC, which is integrated directly into SPM and does not require a Ruby gem. See Section 17.

### 2.2 Generate Gemfile.lock ✅

After creating the Gemfile, run `bundle lock` to generate `Gemfile.lock`. This pins exact versions of CocoaPods, Jazzy, and their transitive dependencies for reproducible CI builds.

### 2.3 Add .ruby-version ✅

**Create `.ruby-version`** in the repository root:
```
ruby-4.0.3
```

Adjust the version to match the local Homebrew-installed Ruby version (`ruby --version`).

### 2.4 API Documentation Tooling: DocC (not Jazzy) ✅

**Do not create `.jazzy.yaml`.** This plan originally proposed Jazzy for API documentation, but the CDMarkdownKit 3.1.0 modernization established DocC as the new standard — removing Jazzy entirely in favor of Apple's native documentation system.

See **Section 17** for the complete DocC setup: the `.docc` bundle structure, SPM `swift-docc-plugin` dependency, static site generation, and CI job.

### 2.5 Update .gitignore ✅

Add the following entries to `.gitignore` (or create it if missing):

```
# Bundler
.bundle/

# DocC build artifacts (docs/ is tracked intentionally for GitHub Pages)
/tmp/docc-output/

# Carthage (being removed)
Carthage/Build/
```

**Note on Carthage:** The `Carthage/` directory is currently present because CI uses Carthage. Once CI is migrated to SPM-only builds (Section 3), the `Carthage/Checkouts/` and `Carthage/Build/` directories can be removed. The `Cartfile` and `Cartfile.resolved` files should be deleted as well.

---

## Section 3: CI/CD Pipeline Modernization

The existing `.github/workflows/ci.yml` is a complete rewrite. Below is a detailed breakdown of every change and the target configuration.

### 3.1 Trigger Path Filters ✅

**Current:**
```yaml
on:
  push:
    paths:
      - "Source/**"
      - ".github/workflows/**"
      - "Package.swift"
  pull_request:
    paths:
      - "Source/**"
      - ".github/workflows/**"
      - "Package.swift"
```

**Target:** Add `Tests/**` to both push and pull_request path filters.
```yaml
on:
  push:
    branches:
      - master
    paths:
      - ".github/workflows/**"
      - "Package.swift"
      - "Source/**"
      - "Tests/**"
  pull_request:
    paths:
      - ".github/workflows/**"
      - "Package.swift"
      - "Source/**"
      - "Tests/**"
```

### 3.2 Concurrency Group ✅

**Current:**
```yaml
concurrency:
  group: ci
  cancel-in-progress: true
```

**Target:** Use `github.ref_name` so different branches don't cancel each other:
```yaml
concurrency:
  group: ${{ github.ref_name }}
  cancel-in-progress: true
```

### 3.3 Replace Carthage with SPM / Remove Carthage Entirely ✅

All existing CI jobs use Carthage to resolve Alamofire before building with Xcode. This must be removed because:
1. Carthage is slow and adds unnecessary complexity
2. Alamofire ships as an SPM-native package
3. Xcode can resolve SPM dependencies automatically during `xcodebuild`

**Changes per job:**
- Remove all `actions/cache` steps that cache `Carthage/`
- Remove all `Dependencies` steps that run `carthage update`
- Remove `Cartfile` and `Cartfile.resolved` from the repository root

### 3.4 Update `actions/checkout` from v3 to v4 ✅

All `uses: actions/checkout@v3` occurrences become `uses: actions/checkout@v4`.

### 3.5 Update `actions/cache` from v3 to v4 ✅

The CocoaPods job uses `actions/cache@v3`. Update to `actions/cache@v4`.

### 3.6 Update macOS Runners and Xcode Versions ✅

**Current runners:** macOS-10.15, macOS-11, macOS-12  
**Target runners:** macos-15, macos-26

**Current Xcode versions:** 12.4, 12.5.1, 13.1, 13.2.1, 13.3.1, 13.4, 13.4.1  
**Target Xcode versions:**
- `macos-15`: Xcode 16.4 (`/Applications/Xcode_16.4.app/Contents/Developer`)
- `macos-26`: Xcode 26.1.1, 26.2, 26.3, 26.4.1

### 3.7 Replace xcpretty with xcbeautify ✅

All `| xcpretty` usages become `2>&1 | xcbeautify --renderer github-actions`. Add an `Install xcbeautify` step before any xcodebuild step:
```yaml
- name: Install xcbeautify
  run: brew install xcbeautify
```

Also prefix every `xcodebuild` command with `set -o pipefail`:
```yaml
run: |
  set -o pipefail
  env NSUnbufferedIO=YES xcodebuild ... 2>&1 | xcbeautify --renderer github-actions
```

### 3.8 Add `Select Xcode` Step ✅

Every job that uses xcodebuild must include an explicit Xcode selection step before building:
```yaml
- name: Select Xcode
  run: sudo xcode-select -s ${{ matrix.xcode }}
```

### 3.9 Restructure Platform Jobs with Matrix Strategy ✅

**Current:** Separate named jobs (`Latest`, `iOS`, `macOS`, `tvOS`, `watchOS`, `Catalyst`, `SPM`)  
**Target:** One job per platform, each with a `matrix` that tests multiple Xcode versions

#### iOS Job

```yaml
iOS:
  name: Test ${{ matrix.name }}
  runs-on: ${{ matrix.runner }}
  timeout-minutes: 15
  strategy:
    fail-fast: false
    matrix:
      include:
        - runner: macos-26
          xcode: /Applications/Xcode_26.4.1.app/Contents/Developer
          destination: "OS=26.2,name=iPhone 17 Pro"
          name: "iOS 26 (Xcode 26.4.1)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.3.app/Contents/Developer
          destination: "OS=26.2,name=iPhone 17 Pro"
          name: "iOS 26 (Xcode 26.3)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.2.app/Contents/Developer
          destination: "OS=26.2,name=iPhone 17 Pro"
          name: "iOS 26 (Xcode 26.2)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.1.1.app/Contents/Developer
          destination: "OS=26.1,name=iPhone 17 Pro"
          name: "iOS 26 (Xcode 26.1.1)"
        - runner: macos-15
          xcode: /Applications/Xcode_16.4.app/Contents/Developer
          destination: "OS=18.6,name=iPhone 16 Pro"
          name: "iOS 18 (Xcode 16.4)"
  steps:
    - uses: actions/checkout@v4
    - name: Select Xcode
      run: sudo xcode-select -s ${{ matrix.xcode }}
    - name: List available simulators
      run: xcrun simctl list
    - name: Install xcbeautify
      run: brew install xcbeautify
    - name: ${{ matrix.name }} - Debug
      run: |
        set -o pipefail
        env NSUnbufferedIO=YES xcodebuild -project "CDYelpFusionKit.xcodeproj" \
          -scheme "CDYelpFusionKit iOS" \
          -destination "${{ matrix.destination }}" \
          -configuration Debug clean build 2>&1 | xcbeautify --renderer github-actions
    - name: ${{ matrix.name }} - Release
      run: |
        set -o pipefail
        env NSUnbufferedIO=YES xcodebuild -project "CDYelpFusionKit.xcodeproj" \
          -scheme "CDYelpFusionKit iOS" \
          -destination "${{ matrix.destination }}" \
          -configuration Release clean build 2>&1 | xcbeautify --renderer github-actions
```

#### macOS Job

```yaml
macOS:
  name: Test ${{ matrix.name }}
  runs-on: ${{ matrix.runner }}
  timeout-minutes: 10
  strategy:
    fail-fast: false
    matrix:
      include:
        - runner: macos-26
          xcode: /Applications/Xcode_26.4.1.app/Contents/Developer
          name: "macOS 26 (Xcode 26.4.1)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.3.app/Contents/Developer
          name: "macOS 26 (Xcode 26.3)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.2.app/Contents/Developer
          name: "macOS 26 (Xcode 26.2)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.1.1.app/Contents/Developer
          name: "macOS 26 (Xcode 26.1.1)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.0.1.app/Contents/Developer
          name: "macOS 26 (Xcode 26.0.1)"
        - runner: macos-15
          xcode: /Applications/Xcode_16.4.app/Contents/Developer
          name: "macOS 15 (Xcode 16.4)"
        - runner: macos-15
          xcode: /Applications/Xcode_16.3.app/Contents/Developer
          name: "macOS 15 (Xcode 16.3)"
        - runner: macos-15
          xcode: /Applications/Xcode_16.2.app/Contents/Developer
          name: "macOS 15 (Xcode 16.2)"
        - runner: macos-15
          xcode: /Applications/Xcode_16.1.app/Contents/Developer
          name: "macOS 15 (Xcode 16.1)"
        - runner: macos-15
          xcode: /Applications/Xcode_16.0.app/Contents/Developer
          name: "macOS 15 (Xcode 16.0)"
  steps:
    - uses: actions/checkout@v4
    - name: Select Xcode
      run: sudo xcode-select -s ${{ matrix.xcode }}
    - name: Install xcbeautify
      run: brew install xcbeautify
    - name: ${{ matrix.name }} - Debug
      run: |
        set -o pipefail
        env NSUnbufferedIO=YES xcodebuild -project "CDYelpFusionKit.xcodeproj" \
          -scheme "CDYelpFusionKit macOS" \
          -destination "platform=macOS" \
          -configuration Debug clean build 2>&1 | xcbeautify --renderer github-actions
    - name: ${{ matrix.name }} - Release
      run: |
        set -o pipefail
        env NSUnbufferedIO=YES xcodebuild -project "CDYelpFusionKit.xcodeproj" \
          -scheme "CDYelpFusionKit macOS" \
          -destination "platform=macOS" \
          -configuration Release clean build 2>&1 | xcbeautify --renderer github-actions
```

#### tvOS Job

```yaml
tvOS:
  name: Test ${{ matrix.name }}
  runs-on: ${{ matrix.runner }}
  timeout-minutes: 10
  strategy:
    fail-fast: false
    matrix:
      include:
        - runner: macos-26
          xcode: /Applications/Xcode_26.4.1.app/Contents/Developer
          destination: "OS=26.4,name=Apple TV 4K (3rd generation) (at 1080p)"
          name: "tvOS 26 (Xcode 26.4.1)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.3.app/Contents/Developer
          destination: "OS=26.2,name=Apple TV 4K (3rd generation) (at 1080p)"
          name: "tvOS 26 (Xcode 26.3)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.2.app/Contents/Developer
          destination: "OS=26.2,name=Apple TV 4K (3rd generation) (at 1080p)"
          name: "tvOS 26 (Xcode 26.2)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.1.1.app/Contents/Developer
          destination: "OS=26.1,name=Apple TV 4K (3rd generation) (at 1080p)"
          name: "tvOS 26 (Xcode 26.1.1)"
        - runner: macos-15
          xcode: /Applications/Xcode_16.4.app/Contents/Developer
          destination: "OS=18.5,name=Apple TV 4K (3rd generation) (at 1080p)"
          name: "tvOS 18 (Xcode 16.4)"
  steps:
    - uses: actions/checkout@v4
    - name: Select Xcode
      run: sudo xcode-select -s ${{ matrix.xcode }}
    - name: List available simulators
      run: xcrun simctl list
    - name: Install xcbeautify
      run: brew install xcbeautify
    - name: ${{ matrix.name }} - Debug
      run: |
        set -o pipefail
        env NSUnbufferedIO=YES xcodebuild -project "CDYelpFusionKit.xcodeproj" \
          -scheme "CDYelpFusionKit tvOS" \
          -destination "${{ matrix.destination }}" \
          -configuration Debug clean build 2>&1 | xcbeautify --renderer github-actions
    - name: ${{ matrix.name }} - Release
      run: |
        set -o pipefail
        env NSUnbufferedIO=YES xcodebuild -project "CDYelpFusionKit.xcodeproj" \
          -scheme "CDYelpFusionKit tvOS" \
          -destination "${{ matrix.destination }}" \
          -configuration Release clean build 2>&1 | xcbeautify --renderer github-actions
```

#### watchOS Job

```yaml
watchOS:
  name: Test ${{ matrix.name }}
  runs-on: ${{ matrix.runner }}
  timeout-minutes: 10
  strategy:
    fail-fast: false
    matrix:
      include:
        - runner: macos-26
          xcode: /Applications/Xcode_26.4.1.app/Contents/Developer
          destination: "OS=26.4,name=Apple Watch Series 11 (46mm)"
          name: "watchOS 26 (Xcode 26.4.1)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.3.app/Contents/Developer
          destination: "OS=26.2,name=Apple Watch Series 11 (46mm)"
          name: "watchOS 26 (Xcode 26.3)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.2.app/Contents/Developer
          destination: "OS=26.2,name=Apple Watch Series 11 (46mm)"
          name: "watchOS 26 (Xcode 26.2)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.1.1.app/Contents/Developer
          destination: "OS=26.1,name=Apple Watch Series 11 (46mm)"
          name: "watchOS 26 (Xcode 26.1.1)"
        - runner: macos-15
          xcode: /Applications/Xcode_16.4.app/Contents/Developer
          destination: "OS=11.5,name=Apple Watch Series 10 (46mm)"
          name: "watchOS 11 (Xcode 16.4)"
  steps:
    - uses: actions/checkout@v4
    - name: Select Xcode
      run: sudo xcode-select -s ${{ matrix.xcode }}
    - name: List available simulators
      run: xcrun simctl list
    - name: Install xcbeautify
      run: brew install xcbeautify
    - name: ${{ matrix.name }} - Debug
      run: |
        set -o pipefail
        env NSUnbufferedIO=YES xcodebuild -project "CDYelpFusionKit.xcodeproj" \
          -scheme "CDYelpFusionKit watchOS" \
          -destination "${{ matrix.destination }}" \
          -configuration Debug clean build 2>&1 | xcbeautify --renderer github-actions
    - name: ${{ matrix.name }} - Release
      run: |
        set -o pipefail
        env NSUnbufferedIO=YES xcodebuild -project "CDYelpFusionKit.xcodeproj" \
          -scheme "CDYelpFusionKit watchOS" \
          -destination "${{ matrix.destination }}" \
          -configuration Release clean build 2>&1 | xcbeautify --renderer github-actions
```

#### Catalyst Job

```yaml
Catalyst:
  name: Test Catalyst
  runs-on: macos-15
  timeout-minutes: 10
  steps:
    - uses: actions/checkout@v4
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
    - name: Install xcbeautify
      run: brew install xcbeautify
    - name: Catalyst - Debug
      run: |
        set -o pipefail
        env NSUnbufferedIO=YES xcodebuild -project "CDYelpFusionKit.xcodeproj" \
          -scheme "CDYelpFusionKit iOS" \
          -destination "platform=macOS" \
          -configuration Debug clean build 2>&1 | xcbeautify --renderer github-actions
    - name: Catalyst - Release
      run: |
        set -o pipefail
        env NSUnbufferedIO=YES xcodebuild -project "CDYelpFusionKit.xcodeproj" \
          -scheme "CDYelpFusionKit iOS" \
          -destination "platform=macOS" \
          -configuration Release clean build 2>&1 | xcbeautify --renderer github-actions
```

#### CocoaPods Job (Promoted to Standalone)

Move pod lib lint out of the iOS job and into its own dedicated job using `bundle exec`:

```yaml
CocoaPods:
  name: pod lib lint
  runs-on: macos-15
  timeout-minutes: 15
  steps:
    - uses: actions/checkout@v4
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
    - uses: actions/cache@v4
      with:
        path: Pods
        key: ${{ runner.os }}-pods-${{ hashFiles('**/Podfile.lock') }}
        restore-keys: |
          ${{ runner.os }}-pods-
    - name: Install Gems
      run: bundle install
    - name: pod lib lint
      run: bundle exec pod lib lint --allow-warnings
```

**Key changes from current:**
- `gem install cocoapods` → `bundle install` (uses Gemfile-pinned version)
- `pod lib lint` → `bundle exec pod lib lint`
- Remove `--use-libraries` flag (not needed for modern pods)
- Dedicated job instead of nested in the iOS platform job

#### SPM Job

```yaml
SPM:
  name: Test with SPM
  runs-on: macos-15
  timeout-minutes: 10
  steps:
    - uses: actions/checkout@v4
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
    - name: Install xcbeautify
      run: brew install xcbeautify
    - name: swift test
      run: set -o pipefail && swift test -c debug 2>&1 | xcbeautify --renderer github-actions
```

**Key changes from current:**
- Remove the 6-entry matrix (all ran identical builds with misleading names)
- Single run on macOS-15 / Xcode 16.4
- `swift build` → `swift test -c debug` (once tests exist per Section 10)
- Add xcbeautify formatting
- Add `2>&1` to capture stderr

### 3.10 Add SwiftLint CI Job ✅

```yaml
swiftlint:
  name: SwiftLint
  runs-on: macos-15
  timeout-minutes: 10
  steps:
    - uses: actions/checkout@v4
    - name: Install SwiftLint
      run: brew install swiftlint
    - name: Lint
      run: swiftlint lint --strict
```

### 3.11 Add CodeQL Security Scanning Job ✅

```yaml
codeql:
  name: CodeQL
  runs-on: macos-15
  timeout-minutes: 20
  permissions:
    security-events: write
  steps:
    - uses: actions/checkout@v4
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_16.4.app/Contents/Developer
    - name: Initialize CodeQL
      uses: github/codeql-action/init@v3
      with:
        languages: swift
    - name: Build
      run: |
        xcodebuild -project CDYelpFusionKit.xcodeproj \
          -scheme "CDYelpFusionKit iOS" \
          -destination "generic/platform=iOS" \
          -configuration Debug \
          clean build
    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v3
```

### 3.12 Add SwiftFormat CI Job ✅

```yaml
swiftformat:
  name: SwiftFormat
  runs-on: macos-15
  timeout-minutes: 10
  steps:
    - uses: actions/checkout@v4
    - name: Install SwiftFormat
      run: brew install swiftformat
    - name: Check formatting
      run: swiftformat Source Tests --lint
```

`--lint` mode reports formatting violations without modifying files. The job fails if the code does not match SwiftFormat's expected output.

### 3.13 Add visionOS CI Job ✅

```yaml
visionOS:
  name: Test ${{ matrix.name }}
  runs-on: ${{ matrix.runner }}
  timeout-minutes: 10
  strategy:
    fail-fast: false
    matrix:
      include:
        - runner: macos-26
          xcode: /Applications/Xcode_26.4.1.app/Contents/Developer
          destination: "OS=26.2,name=Apple Vision Pro"
          name: "visionOS 26 (Xcode 26.4.1)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.3.app/Contents/Developer
          destination: "OS=26.2,name=Apple Vision Pro"
          name: "visionOS 26 (Xcode 26.3)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.2.app/Contents/Developer
          destination: "OS=26.2,name=Apple Vision Pro"
          name: "visionOS 26 (Xcode 26.2)"
        - runner: macos-26
          xcode: /Applications/Xcode_26.1.1.app/Contents/Developer
          destination: "OS=26.1,name=Apple Vision Pro"
          name: "visionOS 26 (Xcode 26.1.1)"
  steps:
    - uses: actions/checkout@v4
    - name: Select Xcode
      run: sudo xcode-select -s ${{ matrix.xcode }}
    - name: Install xcbeautify
      run: brew install xcbeautify
    - name: ${{ matrix.name }} - Debug
      run: |
        set -o pipefail
        env NSUnbufferedIO=YES xcodebuild -project "CDYelpFusionKit.xcodeproj" \
          -scheme "CDYelpFusionKit visionOS" \
          -destination "${{ matrix.destination }}" \
          -configuration Debug clean build 2>&1 | xcbeautify --renderer github-actions
    - name: ${{ matrix.name }} - Release
      run: |
        set -o pipefail
        env NSUnbufferedIO=YES xcodebuild -project "CDYelpFusionKit.xcodeproj" \
          -scheme "CDYelpFusionKit visionOS" \
          -destination "${{ matrix.destination }}" \
          -configuration Release clean build 2>&1 | xcbeautify --renderer github-actions
```

**Note:** The visionOS job only runs on macos-26 runners (4 entries). Xcode 16.x on macos-15 does not include visionOS simulators.

### 3.14 Add DocC Build CI Job ✅

```yaml
documentation:
  name: DocC Build
  runs-on: macos-15
  timeout-minutes: 10
  steps:
    - uses: actions/checkout@v4
    - name: Build DocC
      run: |
        swift package --disable-sandbox generate-documentation \
          --target CDYelpFusionKit \
          --output-path /tmp/docc-output \
          --transform-for-static-hosting \
          --hosting-base-path CDYelpFusionKit \
          2>&1 | tee docc.log
    - name: Fail on DocC warnings
      run: grep -qE "^warning:" docc.log && exit 1 || exit 0
```

This job verifies that the DocC bundle compiles cleanly and all doc-comment cross-references (`\`\`TypeName\`\``) resolve correctly.

---

## Section 4: Package.swift Modernization ✅

### Current State

```swift
// swift-tools-version:5.6
...
let package = Package(
    name: "CDYelpFusionKit",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "CDYelpFusionKit", targets: ["CDYelpFusionKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1"))
    ],
    targets: [
        .target(
            name: "CDYelpFusionKit",
            dependencies: [.product(name: "Alamofire", package: "Alamofire")],
            path: "Source",
            exclude: ["Info.plist"],
            linkerSettings: [
                .linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS]))
            ])
    ],
    swiftLanguageVersions: [.v5])
```

### Target State

```swift
// swift-tools-version:6.0
...
let package = Package(
    name: "CDYelpFusionKit",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
        .watchOS(.v4),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "CDYelpFusionKit",
            targets: ["CDYelpFusionKit"]),
        .library(
            name: "CDYelpFusionKitDynamic",
            type: .dynamic,
            targets: ["CDYelpFusionKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "CDYelpFusionKit",
            dependencies: [.product(name: "Alamofire", package: "Alamofire")],
            path: "Source",
            exclude: ["Info.plist"],
            resources: [.process("PrivacyInfo.xcprivacy")],
            linkerSettings: [
                .linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS, .watchOS, .visionOS]))
            ]),
        .testTarget(
            name: "CDYelpFusionKitTests",
            dependencies: ["CDYelpFusionKit"]
        )
    ],
    swiftLanguageModes: [.v5])
```

### Change-by-Change Breakdown

| Change | From | To | Why |
|--------|------|----|-----|
| swift-tools-version | 5.6 | 6.0 | Required for `swiftLanguageModes` parameter |
| platforms: iOS | .v10 | .v12 | Lowest SPM floor without deprecation; Alamofire 5.9+ requirement |
| platforms: macOS | .v10_12 | .v10_13 | Lowest SPM floor without deprecation |
| platforms: tvOS | .v10 | .v12 | Lowest SPM floor without deprecation |
| platforms: watchOS | .v3 | .v4 | Lowest SPM floor without deprecation |
| swiftLanguageVersions | [.v5] | removed | Replaced by swiftLanguageModes |
| swiftLanguageModes | (missing) | [.v5] | Correct parameter for swift-tools-version 6.0 |
| Dynamic library product | (missing) | CDYelpFusionKitDynamic | Enables dynamic linking option |
| PrivacyInfo.xcprivacy resource | (missing) | .process(...) | Apple App Store privacy manifest requirement |
| Test target | (missing) | CDYelpFusionKitTests | Enables `swift test` |
| Alamofire version | 5.6.1 | 5.9.0 (or latest) | Security/feature updates; 5.6.1 is from 2022 |
| watchOS UIKit linker | (missing) | Added | watchOS supports UIKit from watchOS 7+ |
| platforms: visionOS | (missing) | .visionOS(.v1) | New platform supported by Alamofire 5.9+ |
| visionOS UIKit linker | (missing) | Added | visionOS is UIKit-based |
| swift-docc-plugin | (missing) | 1.3.0+ | Required for DocC documentation generation (build-tool plugin only; not a library dependency) |

---

## Section 5: Remove Versioned Package Files ✅

**Delete the following files:**
- `Package@swift-5.3.swift`
- `Package@swift-5.4.swift`
- `Package@swift-5.5.swift`

**Rationale:** These versioned manifest files were created as compatibility shims to support SPM clients running older Swift toolchains. With swift-tools-version 6.0 as the single manifest, the versioned files are redundant. All supported clients are expected to run a Swift 6-compatible toolchain.

---

## Section 6: CocoaPods Podspec Modernization ✅

### Current State

```ruby
s.ios.deployment_target = '10.0'
s.osx.deployment_target = '10.12'
s.tvos.deployment_target = '10.0'
s.watchos.deployment_target = '3.0'

s.swift_versions = ['5.3', '5.4', '5.5']

s.source_files = 'Source/*.swift'
s.resources = ['Resources/*.xcassets']

s.dependency 'Alamofire', '5.6.1'
```

### Target State

```ruby
Pod::Spec.new do |s|
  s.name = 'CDYelpFusionKit'
  s.version = '4.0.0'
  s.cocoapods_version = '>= 1.13.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'An extensive Swift wrapper for the Yelp Fusion API.'
  s.description = <<-DESC
    This Swift wrapper covers all possible network endpoints and responses for the Yelp Fusion API.
  DESC
  s.homepage = 'https://github.com/chrisdhaan/CDYelpFusionKit'
  s.author = { 'Christopher de Haan' => 'contact@christopherdehaan.me' }
  s.source = { :git => 'https://github.com/chrisdhaan/CDYelpFusionKit.git', :tag => s.version.to_s }
  s.documentation_url = 'https://chrisdhaan.github.io/CDYelpFusionKit/'

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.13'
  s.tvos.deployment_target = '12.0'
  s.watchos.deployment_target = '4.0'
  s.visionos.deployment_target = '1.0'

  s.swift_versions = ['5']

  s.source_files = 'Source/*.swift'
  s.resource_bundles = { 'CDYelpFusionKit' => ['Source/PrivacyInfo.xcprivacy'] }
  s.resources = ['Resources/*.xcassets']

  s.dependency 'Alamofire', '~> 5.9'
end
```

### Change-by-Change Breakdown

| Change | From | To | Why |
|--------|------|----|-----|
| version | 3.2.0 | 4.0.0 | Major version bump |
| cocoapods_version | (missing) | '>= 1.13.0' | Required for PrivacyInfo.xcprivacy resource bundling |
| documentation_url | (missing) | Jazzy GitHub Pages URL | Links to generated API docs |
| ios deployment_target | '10.0' | '12.0' | Match Package.swift |
| osx deployment_target | '10.12' | '10.13' | Match Package.swift |
| tvos deployment_target | '10.0' | '12.0' | Match Package.swift |
| watchos deployment_target | '3.0' | '4.0' | Match Package.swift |
| swift_versions | ['5.3', '5.4', '5.5'] | ['5'] | Simplified; all Swift 5.x releases are compatible |
| resource_bundles | (missing) | PrivacyInfo.xcprivacy | Apple App Store privacy requirement; requires cocoapods >= 1.13.0 |
| visionos deployment_target | (missing) | '1.0' | New platform; matches Package.swift |
| Alamofire dependency | '5.6.1' (pinned) | '~> 5.9' (minor-flexible) | Allows patch updates; aligns with SPM upToNextMajor |

---

## Section 7: Privacy Manifest ✅

Apple requires that all SDKs distributed via CocoaPods or SPM include a privacy manifest file declaring their data collection practices.

**Create `Source/PrivacyInfo.xcprivacy`:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array/>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
</dict>
</plist>
```

**Notes:**
- CDYelpFusionKit itself does not collect data or track users.
- The `api.yelp.com` requests are made by the **host application** using the key the developer provides. The SDK is a networking wrapper; actual data collection policies belong to the host app's manifest.
- If the Yelp API calls are considered "tracking" in the host app's context, the host app's manifest (not the SDK manifest) is the appropriate place to declare that.

---

## Section 8: Xcode Project Modernization

File: `CDYelpFusionKit.xcodeproj/project.pbxproj`

### 8.1 Update Deployment Targets ✅

Search for all occurrences of the following build settings and update:

| Setting | Current | Target |
|---------|---------|--------|
| `IPHONEOS_DEPLOYMENT_TARGET` | `10.0` | `12.0` |
| `MACOSX_DEPLOYMENT_TARGET` | `10.12` | `10.13` |
| `TVOS_DEPLOYMENT_TARGET` | `10.0` | `12.0` |
| `WATCHOS_DEPLOYMENT_TARGET` | `3.0` | `4.0` |

Apply to all targets: the framework target and the Example app target.

### 8.2 Update LastUpgradeCheck ✅

```
LastUpgradeCheck = 1410;  →  LastUpgradeCheck = 2640;
LastUpgradeVersion = 1410;  →  LastUpgradeVersion = 2640;
```

This suppresses Xcode's "upgrade project" prompt and signals Xcode 16.x compatibility.

### 8.3 Enable BuildIndependentTargetsInParallel ✅

In the top-level project settings:
```
BuildIndependentTargetsInParallel = YES;
```

### 8.4 Fix SwiftLint Build Phase ✅

The existing SwiftLint run script build phase in each scheme should be updated to:
```bash
export PATH="$PATH:/opt/homebrew/bin"
cd "$SRCROOT"
if which swiftlint > /dev/null; then
    swiftlint
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

Also set `ENABLE_USER_SCRIPT_SANDBOXING = NO` for targets that include a SwiftLint build phase, as sandboxing prevents SwiftLint from reading source files outside the target's immediate directory.

### 8.5 Update xcscheme Files ✅

In each `.xcscheme` file, update:
```xml
<!-- Before -->
buildForRunning = "YES" parallelizeBuildables = "NO"
<!-- After -->
buildForRunning = "YES" parallelizeBuildables = "YES"
```

### 8.6 SWIFT_VERSION ✅

The Xcode project currently has `SWIFT_VERSION = 5.0`. This is a mismatch with Package.swift's swift-tools-version 6.0 and swiftLanguageModes. However, the SWIFT_VERSION build setting in the Xcode project controls the language version used when building via xcodebuild — it should be updated to `5.0` retained as-is since `swiftLanguageModes: [.v5]` governs SPM builds. For Xcode project builds, verify that the schemes build without Swift 6 strict concurrency warnings and update SWIFT_VERSION if needed.

---

## Section 9: Source Code Modernization

### 9.1 Update Copyright Year ✅

All 40 source files have `Copyright © 2016-2022`. Update to `Copyright © 2016-2026`.

**Files to update (all of `Source/*.swift`):**
- CDColor+CDYelpFusionKit.swift
- CDColor.swift
- CDImage+CDYelpFusionKit.swift
- CDImage.swift
- CDYelpAPIClient.swift
- CDYelpAutoCompleteResponse.swift
- CDYelpBusiness.swift
- CDYelpBusinessResponse.swift
- CDYelpCategoriesResponse.swift
- CDYelpCategory.swift
- CDYelpCategoryResponse.swift
- CDYelpCenter.swift
- CDYelpConstants.swift
- CDYelpCoordinates.swift
- CDYelpEnums.swift
- CDYelpError.swift
- CDYelpEvent.swift
- CDYelpEventResponse.swift
- CDYelpEventsResponse.swift
- CDYelpFusionKit.swift
- CDYelpHour.swift
- CDYelpLocation.swift
- CDYelpMessaging.swift
- CDYelpOpen.swift
- CDYelpRegion.swift
- CDYelpReview.swift
- CDYelpReviewsResponse.swift
- CDYelpRouter.swift
- CDYelpSearchResponse.swift
- CDYelpSpecialHour.swift
- CDYelpTerm.swift
- CDYelpUser.swift
- DateFormatter+CDYelpFusionKit.swift
- Parameters+CDYelpFusionKit.swift
- String+CDYelpFusionKit.swift
- URL+CDYelpFusionKit.swift

Also update Example app source files:
- Example/Source/*.swift

And the LICENSE file (line 1):
```
Copyright (c) 2016-2022  →  Copyright (c) 2016-2026
```

### 9.2 Fix Platform Conditional Imports ✅

**Current (both `CDYelpAPIClient.swift` and `CDYelpRouter.swift`):**
```swift
#if !os(OSX)
    import UIKit
#else
    import Foundation
#endif
```

**Target:**
```swift
#if os(macOS)
    import Foundation
#else
    import UIKit
#endif
```

**Rationale:** The `!os(OSX)` idiom is an Objective-C-era convention. Modern Swift code uses `#if os(macOS)`. The positive form is clearer and more idiomatic.

**Note:** Also update any `#if !os(OSX)` occurrences that appear in other source files.

### 9.3 Remove NSObject Inheritance from CDYelpAPIClient ✅

**Current (`CDYelpAPIClient.swift:36`):**
```swift
public class CDYelpAPIClient: NSObject {
```

**Target:**
```swift
public class CDYelpAPIClient {
```

**Also remove:**
```swift
super.init()  // line 70
```

**Rationale:** NSObject inheritance is unnecessary for a pure-Swift API client. It was historically required for Objective-C bridging but adds overhead and forces `init()` semantics that are not needed. Removing it is a breaking change (binary-level), which is acceptable in a major version bump.

**Impact:** Any Objective-C code that instantiates `CDYelpAPIClient` using `alloc/init` will need to migrate to Swift, but this is expected for a v4.0 release.

### 9.4 Fix apiKey Force-Unwrap ✅

**Current:**
```swift
private let apiKey: String!

public init(apiKey: String!) {
    assert((apiKey != nil && apiKey.count > 0), "An apiKey is required...")
    self.apiKey = apiKey
    super.init()
}
```

**Target:**
```swift
private let apiKey: String

public init(apiKey: String) {
    precondition(!apiKey.isEmpty, "An apiKey is required to query the Yelp Fusion API.")
    self.apiKey = apiKey
}
```

**Changes:**
- `String!` → `String` (eliminate implicit optional)
- `assert` → `precondition` (precondition is not stripped in release builds; assert is)
- Remove `super.init()` (no longer inherits from NSObject)

### 9.5 Add Async/Await API Overloads (Major Feature) ✅

This is the most significant source code change. All 22 `@escaping` completion-based API methods in `CDYelpAPIClient.swift` should have async/await overloads added alongside them.

**Pattern:** For each existing completion-based method, add an async counterpart that wraps the completion handler using `withCheckedThrowingContinuation`.

**Example — current:**
```swift
public func searchBusinesses(
    byTerm term: String?,
    location: String?,
    latitude: Double?,
    longitude: Double?,
    ...
    completion: @escaping (CDYelpSearchResponse?) -> Void
) {
    manager.request(CDYelpRouter.search(parameters: parameters))
        .responseDecodable(of: CDYelpSearchResponse.self) { response in
            switch response.result {
            case .success(let value):
                completion(value)
            case .failure(let error):
                print("searchBusinesses failure: ", error.localizedDescription)
                completion(nil)
            }
        }
}
```

**Example — target (add async overload):**
```swift
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public func searchBusinesses(
    byTerm term: String?,
    location: String?,
    latitude: Double?,
    longitude: Double?,
    ...
) async throws -> CDYelpSearchResponse {
    try await withCheckedThrowingContinuation { continuation in
        manager.request(CDYelpRouter.search(parameters: parameters))
            .responseDecodable(of: CDYelpSearchResponse.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
    }
}
```

**All 22 methods to wrap (from `CDYelpAPIClient.swift`):**

Business Endpoints:
1. `searchBusinesses(byTerm:location:latitude:longitude:radius:categories:locale:limit:offset:sortBy:price:openNow:openAt:attributes:completion:)`
2. `searchBusinesses(byPhoneNumber:completion:)`
3. `searchBusinesses(byType:latitude:longitude:completion:)`
4. `fetchBusiness(byId:locale:completion:)`
5. `fetchBusinesses(byMatchType:name:addressOne:addressTwo:city:state:country:latitude:longitude:phone:zipCode:yelpBusinessId:limit:threshold:completion:)`
6. `fetchReviews(forBusinessId:locale:completion:)`
7. `fetchAutocompleteResults(byText:latitude:longitude:locale:completion:)`

Event Endpoints:
8. `fetchEvent(byId:locale:completion:)`
9. `searchEvents(byLocale:offset:limit:sortBy:sortOn:categories:startDate:endDate:isFree:location:latitude:longitude:radius:completion:)`
10. `fetchFeaturedEvent(byLocale:location:latitude:longitude:completion:)`

Category Endpoints:
11. `fetchAllCategories(locale:completion:)`
12. `fetchCategoryDetails(byAlias:locale:completion:)`

**Availability annotation:** Use `@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)` on all async overloads to ensure back-deployment is safe (Alamofire's completion handlers work on all targets; only `async throws` requires the newer availability).

**Error handling:** The async overloads throw `AFError` from Alamofire. Consider defining a `CDYelpError` enum (see 9.6) for a cleaner public API.

### 9.6 Improve Error Handling ✅

**Current:** The existing `CDYelpError.swift` should be reviewed and potentially updated. Replace `print()` error logging in completion handlers with proper error propagation.

**Current pattern in completion callbacks:**
```swift
case .failure(let error):
    print("searchBusinesses(byTerm) failure: ", error.localizedDescription)
    completion(nil)
```

**Target pattern:**
```swift
case .failure(let error):
    completion(nil)  // Keep completion nil for backward compat
    // OR for new async overloads: continuation.resume(throwing: error)
```

Remove `print()` statements from the library entirely — library code should never print to the console unless explicitly configured by the host app.

### 9.7 Add Sendable Conformance ✅

For Swift 6 concurrency safety, mark appropriate types:

- `CDYelpAPIClient`: Since it holds mutable state (`manager`) and is designed to be used across async boundaries, consider marking it with `@unchecked Sendable` initially, with a comment explaining that `manager` is thread-safe (Alamofire `Session` is Sendable).

```swift
public class CDYelpAPIClient: @unchecked Sendable {
```

- All `Decodable` response model structs are already value types and can be marked `Sendable` explicitly (though Swift will infer it for frozen structs).
- All enum types (`CDYelpEnums.swift`) should add `Sendable` conformance.

### 9.8 Add Documentation Comments to All Public API ✅

Every public declaration in `Source/*.swift` should have a documentation comment using `///`. The existing `CDYelpAPIClient.swift` already has thorough triple-slash comments on its methods — this pattern should be extended to:

- All response model structs and their properties (`CDYelpBusiness`, `CDYelpEvent`, `CDYelpReview`, etc.)
- All enum cases in `CDYelpEnums.swift`
- `CDYelpRouter` enum cases
- `CDYelpConstants` declarations
- Extension methods in `Parameters+CDYelpFusionKit.swift`, `String+CDYelpFusionKit.swift`, `URL+CDYelpFusionKit.swift`, `DateFormatter+CDYelpFusionKit.swift`

**Format:** One-line `///` summaries per CDMarkdownKit standard. Multi-parameter methods should use `- Parameter` and `- Returns` doc tags.

### 9.9 Update Example App ✅

**File:** `Example/Source/ViewController.swift` (and related files)

**Changes:**
1. Remove `didReceiveMemoryWarning()` override (SwiftLint: `override_in_extension`)
2. If still using `UIApplication.openURL()` (deprecated in iOS 10), update to `UIApplication.shared.open(_:)`
3. Adopt UIScene lifecycle (add `SceneDelegate.swift`, update `AppDelegate.swift`, update `Info.plist`) — see CDMarkdownKit commit for exact pattern
4. Update any example code to use async/await API overloads in `Task {}` blocks

---

## Section 10: Unit Tests

CDYelpFusionKit currently has zero unit tests. The CDMarkdownKit modernization added 109+ tests. CDYelpFusionKit's test surface is different (an API client vs. a parser), so the focus is on **model deserialization** tests.

### 10.1 Create Tests Directory Structure ✅

```
Tests/
└── CDYelpFusionKitTests/
    ├── Models/
    │   ├── CDYelpBusinessTests.swift
    │   ├── CDYelpEventTests.swift
    │   ├── CDYelpReviewTests.swift
    │   ├── CDYelpLocationTests.swift
    │   ├── CDYelpCategoryTests.swift
    │   ├── CDYelpCoordinatesTests.swift
    │   ├── CDYelpSearchResponseTests.swift
    │   ├── CDYelpBusinessResponseTests.swift
    │   ├── CDYelpReviewsResponseTests.swift
    │   ├── CDYelpEventsResponseTests.swift
    │   └── CDYelpAutoCompleteResponseTests.swift
    ├── Router/
    │   └── CDYelpRouterTests.swift
    └── Utilities/
        └── CDYelpEnumsTests.swift
```

### 10.2 Model Deserialization Tests ✅

Use Swift Testing (`import Testing`) per the CDMarkdownKit modernization standard.

**Pattern for each model:**
```swift
import Testing
import Foundation
@testable import CDYelpFusionKit

@Suite struct CDYelpBusinessTests {

    @Test func businessSearchDecodesFromJSON() throws {
        let json = """
        {
            "id": "WavvLdfdP6g8aZTtbBQHTw",
            "name": "Gary Danko",
            "rating": 4.5,
            "price": "$$$$",
            "is_closed": false
        }
        """.data(using: .utf8)!
        let business = try JSONDecoder().decode(CDYelpBusiness.BusinessSearch.self, from: json)
        #expect(business.id == "WavvLdfdP6g8aZTtbBQHTw")
        #expect(business.name == "Gary Danko")
        #expect(business.rating == 4.5)
    }

    @Test func businessSearchHandlesMissingOptionals() throws {
        let json = """
        {
            "id": "abc123",
            "name": "Test Restaurant"
        }
        """.data(using: .utf8)!
        let business = try JSONDecoder().decode(CDYelpBusiness.BusinessSearch.self, from: json)
        #expect(business.id == "abc123")
        #expect(business.rating == nil)
        #expect(business.price == nil)
    }
}
```

### 10.3 Router Tests ✅

```swift
@Suite struct CDYelpRouterTests {

    @Test func searchRouterProducesGetRequest() throws {
        let router = CDYelpRouter.search(parameters: ["term": "coffee", "location": "San Francisco"])
        let request = try router.asURLRequest()
        #expect(request.httpMethod == "GET")
        #expect(request.url?.host == "api.yelp.com")
    }

    @Test func businessRouterInterpolatesId() throws {
        let router = CDYelpRouter.business(id: "test-id-123", parameters: [:])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("test-id-123") == true)
    }
}
```

### 10.4 Enum Tests ✅

```swift
@Suite struct CDYelpEnumsTests {

    @Test func businessSortTypeHasCorrectRawValues() {
        #expect(CDYelpBusinessSortType.bestMatch.rawValue == "best_match")
        #expect(CDYelpBusinessSortType.rating.rawValue == "rating")
        #expect(CDYelpBusinessSortType.reviewCount.rawValue == "review_count")
        #expect(CDYelpBusinessSortType.distance.rawValue == "distance")
    }

    @Test func priceTierHasCorrectRawValues() {
        #expect(CDYelpPriceTier.oneDollarSign.rawValue == "1")
        #expect(CDYelpPriceTier.fourDollarSigns.rawValue == "4")
    }
}
```

### 10.5 Test Framework Note ✅

CDMarkdownKit uses Swift Testing (`import Testing`) introduced in Xcode 16. This is the modern replacement for XCTest for unit tests. All new tests should use Swift Testing syntax (`@Suite`, `@Test`, `#expect`).

---

## Section 11: Documentation

### 11.1 Create CLAUDE.md ✅

**Create `CLAUDE.md`** in the repository root. This file documents the project for Claude Code users.

```markdown
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
| `docs/` | Jazzy-generated API documentation (GitHub Pages) |
| `CDYelpFusionKit.xcodeproj` | Xcode project |
| `CDYelpFusionKit.podspec` | CocoaPods spec |
| `Package.swift` | Swift Package Manager manifest |
| `.github/workflows/ci.yml` | GitHub Actions CI |
| `Gemfile` | Ruby dependencies (CocoaPods, Jazzy) |

## Platform Targets

| Platform | Minimum |
|----------|---------|
| iOS | 12.0 |
| macOS | 10.13 |
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

# Preview documentation locally
swift package --disable-sandbox preview-documentation --target CDYelpFusionKit

# CocoaPods lint
bundle exec pod lib lint --allow-warnings
```

### 11.2 Create Documentation/Usage.md ✅

**Create `Documentation/Usage.md`** with a comprehensive usage guide:

Structure:
- **Basic Setup** — Installation instructions for SPM, CocoaPods, Carthage (legacy note)
- **Authentication** — How to initialize `CDYelpAPIClient` with an API key
- **Business Endpoints** — Examples for each search/fetch method
- **Event Endpoints** — Examples for event search/fetch
- **Category Endpoints** — Examples for category browsing
- **Async/Await Usage** — How to use the new async overloads with `Task {}`
- **Error Handling** — How to catch `AFError` / `CDYelpError`
- **Enums Reference** — Key enum types and their usage
- **Platform Notes** — watchOS considerations (no UIKit image rendering)

### 11.3 Create Documentation/ARCHITECTURE.md ✅

**Create `Documentation/ARCHITECTURE.md`** covering:

- **Dependency Graph** — CDYelpFusionKit → Alamofire → URLSession
- **Request Lifecycle** — `CDYelpAPIClient` → `CDYelpRouter.asURLRequest()` → `Alamofire.Session.request()` → `responseDecodable()` → `Decodable` model
- **Authentication** — How `HTTPHeaders.default` + Bearer token are wired into `Session`
- **Model Hierarchy** — Explain the nested struct pattern (e.g., `CDYelpBusiness.BusinessSearch` vs `CDYelpBusiness.Detailed`)
- **Enum Design** — Why `CDYelpEnums.swift` is a single large file (historical) and future split plan
- **Resource Files** — `CDColor`, `CDImage`, `Resources/*.xcassets` for Yelp brand assets

### 11.4 Create Migration Guide ✅

**Create `Documentation/CDYelpFusionKit 4.0 Migration Guide.md`**:

```markdown
# CDYelpFusionKit 4.0 Migration Guide

## Breaking Changes

### Deployment Target Changes

| Platform | v3.x | v4.0 |
|----------|------|------|
| iOS | 10.0 | 12.0 |
| macOS | 10.12 | 10.13 |
| tvOS | 10.0 | 12.0 |
| watchOS | 3.0 | 4.0 |

### CDYelpAPIClient No Longer Inherits NSObject

`CDYelpAPIClient` previously extended `NSObject`. In v4.0 it is a plain Swift class.

If you were using Objective-C KVO, key-value coding, or Objective-C runtime introspection on `CDYelpAPIClient`, those patterns no longer apply.

### apiKey Parameter Is Now Non-Optional

```swift
// v3.x
let client = CDYelpAPIClient(apiKey: "your-key")  // accepted String!

// v4.0
let client = CDYelpAPIClient(apiKey: "your-key")  // String (non-optional)
```

### Alamofire Dependency Updated

The minimum Alamofire version is now 5.9.x. If you have explicit Alamofire version pins in your project, update them accordingly.

## New Features

### Async/Await API

All 12 API methods now have async/await overloads available on iOS 13+, macOS 10.15+, tvOS 13+, watchOS 6+:

```swift
// v3.x (completion handler)
client.searchBusinesses(byTerm: "coffee", location: "San Francisco", ...) { response in
    guard let businesses = response?.businesses else { return }
    // handle result
}

// v4.0 (async/await)
Task {
    do {
        let response = try await client.searchBusinesses(
            byTerm: "coffee",
            location: "San Francisco",
            ...
        )
        let businesses = response.businesses ?? []
    } catch {
        // handle error
    }
}
```

## Migration Checklist

- [ ] Update deployment targets in your project if needed (iOS 10/11 → 12, macOS 10.12 → 10.13, etc.)
- [ ] Update Alamofire version constraint to `~> 5.9`
- [ ] Remove any Objective-C bridging code that relied on NSObject inheritance
- [ ] Update `apiKey` parameter to be non-optional `String` (remove force-unwraps)
- [ ] Optionally migrate to async/await overloads for cleaner call sites

---

## Section 12: CHANGELOG.md Reformat ✅

Reformat `CHANGELOG.md` to the CDMarkdownKit v3.0.0 semantic versioning standard:

**Format changes:**
- Replace versioned release groupings with a flat Table of Contents
- Remove checkboxes (`- [x]`) from all entries
- Remove subtitles from release entries
- Standardize to three categories per release: **Added**, **Updated**, **Fixed**
- Use YYYY-MM-DD date format throughout (not US-style MM/DD/YYYY)
- Flatten nested bullet points to concise one-line descriptions

**Example target format:**
```markdown
# Changelog

## Table of Contents

- [4.0.0](#400---2026-05-xx)
- [3.2.0](#320---2022-08-02)
- [3.1.0](#310---2022-06-xx)
...

---

## [4.0.0] - 2026-05-XX

### Added
- Async/await overloads for all 12 Yelp Fusion API methods (iOS 13+)
- Unit test target with model deserialization and router tests
- Privacy manifest (PrivacyInfo.xcprivacy) for App Store compliance
- CLAUDE.md, Usage.md, ARCHITECTURE.md, and migration guide documentation
- Dynamic library product (CDYelpFusionKitDynamic) for SPM consumers
- SwiftLint and CodeQL enforcement in CI pipeline
- Jazzy API documentation at chrisdhaan.github.io/CDYelpFusionKit

### Updated
- swift-tools-version from 5.6 to 6.0
- Minimum deployment targets: iOS 12, macOS 10.13, tvOS 12, watchOS 4
- Alamofire dependency from 5.6.1 to 5.9+
- CI runners to macOS-15 and macos-26 with Xcode 16.4 and 26.x
- CI output formatter from xcpretty to xcbeautify
- CocoaPods CI to use bundle exec with Gemfile-managed versions
- GitHub Actions from v3 to v4
- Copyright headers to 2026
- Removed NSObject inheritance from CDYelpAPIClient

### Fixed
- #if !os(OSX) conditional imports replaced with modern #if os(macOS) pattern
- apiKey parameter changed from implicitly-unwrapped optional to non-optional String
- assert replaced with precondition for production-safe validation
- Print-based error logging removed from library code

---

## [3.2.0] - 2022-08-02
...
```

---

## Section 13: README.md Restructure ✅

Restructure `README.md` as a lean navigation hub, following the CDMarkdownKit v3.0.0 pattern. The full README is currently 37,503 bytes — replace with a focused hub that points to `Documentation/Usage.md`.

**Target README structure:**
1. Logo image (existing `Documentation/cdyelpfusionkit.png`)
2. Badges (Swift version, platforms, license, CocoaPods, SPM, CI status)
3. One-sentence description
4. Feature bullet list (high-level)
5. Quick example (5–10 lines of code)
6. Requirements table

| Platform | Minimum |
|----------|---------|
| iOS | 12.0+ |
| macOS | 10.13+ |
| tvOS | 12.0+ |
| watchOS | 4.0+ |

7. Installation section (SPM, CocoaPods) — **remove Carthage** (Carthage has effectively been abandoned; the CDMarkdownKit modernization removed it as well)
8. Links to full documentation (`Documentation/Usage.md`)
9. Author and license

**What to remove:**
- The exhaustive parameter-by-parameter API documentation (move to Usage.md)
- The giant usage example blocks (condense to a 10-line quick-start)
- Carthage installation instructions

---

## Section 14: Dependency Updates

### 14.1 Alamofire ✅

**Current:** `5.6.1` (pinned — released May 2022)  
**Target:** `~> 5.9` (flexible patch updates within the 5.x major)

Check the [Alamofire Releases](https://github.com/Alamofire/Alamofire/releases) page for the latest stable 5.x version at implementation time. As of May 2026, verify that:
1. The latest 5.x release is compatible with iOS 12+ / macOS 10.13+
2. No breaking API changes exist in the `responseDecodable()` method signature used throughout `CDYelpAPIClient.swift`
3. Alamofire's own `Sendable` conformances are satisfied

Update both `Package.swift` and `CDYelpFusionKit.podspec` to the same version constraint.

### 14.2 Remove Carthage ✅

Delete from the repository root:
- `Cartfile`
- `Cartfile.resolved`

Remove the `Carthage/` directory from version control:
```bash
git rm -r --cached Carthage/
```

Add to `.gitignore`:
```
Carthage/Build/
Carthage/Checkouts/
```

**Rationale:** Alamofire 5.x is fully SPM-native and CocoaPods-native. Carthage adds complexity to CI with binary framework building that provides no benefit over SPM's package resolution.

---

## Section 15: Version Bump and Release

### 15.1 Update Version Number ✅

Update the version string `3.2.0` → `4.0.0` in:
- `CDYelpFusionKit.podspec` (`s.version = '4.0.0'`)
- `.jazzy.yaml` (`module_version: "4.0.0"`)
- `CDYelpFusionKit.xcodeproj` (MARKETING_VERSION in build settings)
- `CDYelpFusionKit.xcodeproj` (CURRENT_PROJECT_VERSION if present)

### 15.2 Generate DocC Documentation ✅

After all documentation comments are finalized (Section 9.8) and the DocC bundle is in place (Section 17):

```bash
swift package --disable-sandbox generate-documentation \
  --target CDYelpFusionKit \
  --output-path docs \
  --transform-for-static-hosting \
  --hosting-base-path CDYelpFusionKit
```

Commit the generated `docs/` directory. Configure GitHub Pages (repository Settings → Pages) to serve from the `docs/` directory on the `master` branch. The documentation site becomes available at `https://chrisdhaan.github.io/CDYelpFusionKit/`.

To preview documentation locally before publishing:
```bash
swift package --disable-sandbox preview-documentation --target CDYelpFusionKit
```

### 15.3 Update README Badges ✅

Update the Swift version badge to `Swift 5+` and the requirements table to the new deployment targets.

### 15.4 Create GitHub Release

After pushing the 4.0.0 tag, create a GitHub release with:
- Title: `CDYelpFusionKit 4.0.0`
- Body: the CHANGELOG.md `4.0.0` section
- Tag: `4.0.0`

### 15.5 Publish to CocoaPods Trunk

```bash
bundle exec pod trunk push CDYelpFusionKit.podspec --allow-warnings
```

---

## Section 16: visionOS Support

CDMarkdownKit 3.1.0 added visionOS as a supported platform. CDYelpFusionKit should follow the same pattern to support Apple Vision Pro.

### 16.1 Package.swift: Add visionOS Platform ✅

See Section 4 (Package.swift Modernization) — the updated target state already includes `.visionOS(.v1)` in the platforms array and adds visionOS to the UIKit linker settings.

### 16.2 CocoaPods Podspec: Add visionOS ✅

See Section 6 (CocoaPods Podspec Modernization) — the updated target state already includes `s.visionos.deployment_target = '1.0'`.

### 16.3 Source Code: Platform Guards Already Cover visionOS ✅

The platform guard pattern from Section 9.2 covers visionOS automatically because visionOS uses UIKit and falls through the `#else` branch:

```swift
#if os(macOS)
    import Foundation
#else
    import UIKit  // covers iOS, tvOS, watchOS, and visionOS
#endif
```

No additional `|| os(visionOS)` guards are needed in CDYelpFusionKit's source because the existing `#else` branch is already inclusive. Verify this compiles cleanly with `swift build` after adding `.visionOS(.v1)` to Package.swift.

### 16.4 Xcode Project: Add visionOS Target and Scheme

**Note:** This step requires manual Xcode GUI interaction and cannot be scripted.

1. In Xcode, select **File → New → Target**
2. Choose **Framework** under the visionOS platform tab
3. Name it `CDYelpFusionKit visionOS`
4. Set deployment target to `visionOS 1.0`
5. Delete the auto-generated source file (the target shares the existing `Source/` directory)
6. In **Build Phases → Compile Sources**, add all `.swift` files from `Source/`
7. Add the SwiftLint build phase script (per Section 8.4)
8. Verify the scheme **CDYelpFusionKit visionOS** builds in Debug and Release

A step-by-step guide (`Documentation/XCODE_VISION_OS_SETUP.md`) should be created alongside this work, following the CDMarkdownKit pattern.

### 16.5 CI: Add visionOS Job ✅

See Section 3.13 for the full `visionOS` CI job definition.

### 16.6 README: Add visionOS to Requirements Table ✅

Update the requirements table (Section 13):

| Platform | Minimum |
|----------|---------|
| iOS | 12.0+ |
| macOS | 10.13+ |
| tvOS | 12.0+ |
| watchOS | 4.0+ |
| visionOS | 1.0+ |

### 16.7 Podspec: swift-docc-plugin Does Not Need visionOS Entry

`swift-docc-plugin` is a build-tool plugin only — it generates documentation and is never linked into any target. No visionOS platform entry is needed for it in the podspec.

---

## Section 17: DocC Documentation

CDMarkdownKit 3.1.0 replaced Jazzy with Apple's native DocC documentation system. CDYelpFusionKit should adopt the same migration. DocC integrates directly into SPM, produces a GitHub Pages-compatible static site, and does not require a Ruby gem.

### 17.1 Gemfile: Remove jazzy

The Gemfile (Section 2.1) already reflects this — `gem 'jazzy'` is not included. Run `bundle lock` after any gem changes to regenerate `Gemfile.lock`.

### 17.2 Do Not Create .jazzy.yaml

See Section 2.4 — this file is explicitly not created. If it was ever created, delete it.

### 17.3 swift-docc-plugin Dependency

The `swift-docc-plugin` dependency is already reflected in the Package.swift target state (Section 4). It is a build-tool plugin: it does not become a dependency of the `CDYelpFusionKit` library target and is invisible to consumers.

### 17.4 Create DocC Bundle

**Create `Source/CDYelpFusionKit.docc/`** directory containing three files:

#### `Source/CDYelpFusionKit.docc/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>CDYelpFusionKit</string>
    <key>CFBundleIdentifier</key>
    <string>me.christopherdehaan.CDYelpFusionKit</string>
    <key>CFBundleVersion</key>
    <string>4.0.0</string>
</dict>
</plist>
```

#### `Source/CDYelpFusionKit.docc/CDYelpFusionKit.md` (Landing Page)

```markdown
# ``CDYelpFusionKit``

A comprehensive Swift wrapper for the Yelp Fusion API.

## Overview

CDYelpFusionKit provides a fully typed, Alamofire-backed HTTP client for every endpoint
of the Yelp Fusion REST API. It covers business search, event search, business details,
reviews, autocomplete, and category browsing — with both completion-handler and async/await APIs.

## Topics

### Getting Started

- <doc:GettingStarted>

### API Client

- ``CDYelpAPIClient``

### Models

- ``CDYelpBusiness``
- ``CDYelpEvent``
- ``CDYelpReview``
- ``CDYelpLocation``
- ``CDYelpCategory``
- ``CDYelpSearchResponse``
- ``CDYelpBusinessResponse``
- ``CDYelpReviewsResponse``
- ``CDYelpEventsResponse``
- ``CDYelpAutoCompleteResponse``

### Routing

- ``CDYelpRouter``

### Enumerations

- ``CDYelpEnums``
```

#### `Source/CDYelpFusionKit.docc/GettingStarted.md` (Getting Started Article)

```markdown
# Getting Started

Authenticate and query the Yelp Fusion API in three steps.

## Initialize the Client

```swift
import CDYelpFusionKit

let client = CDYelpAPIClient(apiKey: "your-api-key-here")
```

## Search for Businesses (Completion Handler)

```swift
client.searchBusinesses(
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
    price: nil,
    openNow: nil,
    openAt: nil,
    attributes: nil
) { response in
    guard let businesses = response?.businesses else { return }
    for business in businesses {
        print(business.name ?? "Unknown")
    }
}
```

## Search for Businesses (Async/Await, iOS 13+)

```swift
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
            price: nil,
            openNow: nil,
            openAt: nil,
            attributes: nil
        )
        let businesses = response.businesses ?? []
        print("Found \(businesses.count) businesses")
    } catch {
        print("Search failed: \(error)")
    }
}
```
```

### 17.5 DocC-Compatible Doc Comments

The documentation comments in Section 9.8 should use DocC's double-backtick cross-reference syntax for inter-type links:

```swift
/// Searches for businesses using the Yelp Fusion Search API.
/// - Parameter term: Search term (e.g. "coffee", "restaurants").
/// - Parameter location: Location string (e.g. "San Francisco").
/// - Returns: A ``CDYelpSearchResponse`` containing matching businesses.
/// - Throws: ``AFError`` if the network request fails.
```

Use `\`\`TypeName\`\`` for cross-references to other types in the module. DocC resolves these at build time; unresolvable links become CI warnings (the DocC CI job treats warnings as failures per Section 3.14).

### 17.6 Generate and Publish DocC Static Site

See Section 15.2 for the generation command and GitHub Pages configuration.

### 17.7 CI Job

See Section 3.14 for the `documentation` CI job definition.

---

## Section 18: SwiftFormat

CDMarkdownKit 3.1.0 introduced a SwiftFormat CI job for automated formatting enforcement. CDYelpFusionKit should adopt the same standard to ensure consistent code style across all contributors.

### 18.1 CI Job

See Section 3.12 for the `swiftformat` CI job definition. The job runs `swiftformat Source Tests --lint`, which fails if any file does not match SwiftFormat's expected output.

### 18.2 Format Source Files Before 4.0.0 Release

Before the final 4.0.0 tag, run SwiftFormat to reformat all source files in one clean commit:

```bash
swiftformat Source Tests
```

Review the diff and commit all formatting changes. This establishes the baseline so that subsequent `swiftformat --lint` CI runs pass on clean code.

### 18.3 (Optional) Add .swiftformat Configuration

If any SwiftFormat defaults require project-specific overrides (e.g., to align with SwiftLint's line-length rule), create `.swiftformat` in the repository root:

```
--maxwidth 149
--indent 4
--linebreaks lf
```

If no overrides are needed, SwiftFormat's built-in defaults are used and no configuration file is required. Check whether CDMarkdownKit uses a `.swiftformat` file and mirror it for consistency.

---

## Breaking Changes Summary

For consumer-facing release notes, here are the breaking changes introduced in v4.0.0:

| Breaking Change | Impact | Migration |
|----------------|--------|-----------|
| iOS minimum raised to 12.0 | Apps targeting iOS 10 or 11 cannot use v4.0 | Update app deployment target or stay on v3.x |
| macOS minimum raised to 10.13 | Apps targeting macOS 10.12 cannot use v4.0 | Update app deployment target or stay on v3.x |
| tvOS minimum raised to 12.0 | Apps targeting tvOS 10 or 11 cannot use v4.0 | Update app deployment target or stay on v3.x |
| watchOS minimum raised to 4.0 | Apps targeting watchOS 3 cannot use v4.0 | Update app deployment target or stay on v3.x |
| `CDYelpAPIClient` no longer inherits `NSObject` | Objective-C bridging patterns break | Migrate to Swift usage |
| `apiKey` is now `String` not `String!` | Force-unwrapped usage patterns fail at compile time | Remove force-unwraps |
| Alamofire 5.9+ required | Older Alamofire versions incompatible | Update Alamofire version constraint |
| Versioned Package files removed | Clients on Swift < 5.3 toolchain cannot resolve | Update toolchain to Swift 5.3+ |
| Carthage support dropped | Carthage users cannot integrate via binary | Migrate to SPM or CocoaPods |

---

*This implementation plan was prepared on 2026-05-12 based on a thorough audit of CDYelpFusionKit 3.2.0 and the CDMarkdownKit v3.0.0 modernization commits (`4ece4c7` and `f835225`). Sections 16–18 and updates to Sections 2, 3, 4, 6, 11, and 15 were added on 2026-05-15 based on a review of CDMarkdownKit v3.1.0 (commits `41fc92f` and `944a0b8`), which introduced visionOS support, DocC documentation replacing Jazzy, and SwiftFormat CI enforcement.*
