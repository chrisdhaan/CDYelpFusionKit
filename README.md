# CDYelpFusionKit

[![CI Status](http://img.shields.io/travis/chrisdhaan/CDYelpFusionKit.svg?style=flat)](https://travis-ci.org/chrisdhaan/CDYelpFusionKit)
[![Version](https://img.shields.io/cocoapods/v/CDYelpFusionKit.svg?style=flat)](http://cocoapods.org/pods/CDYelpFusionKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/CDYelpFusionKit.svg?style=flat)](http://cocoapods.org/pods/CDYelpFusionKit)
[![Platform](https://img.shields.io/cocoapods/p/CDYelpFusionKit.svg?style=flat)](http://cocoapods.org/pods/CDYelpFusionKit)

---

## Requirements

- iOS 8.0+
- Xcode 8.1+
- Swift 3.0+
- [Yelp API Access](https://www.yelp.com/developers/v3/manage_app)

---

## Installation

### Installation via CocoaPods

CDYelpFusionKit is available through [CocoaPods](http://cocoapods.org). CocoaPods is a dependency manager that automates and simplifies the process of using 3rd-party libraries like CDYelpFusionKit in your projects. You can install CocoaPods with the following command:

```ruby
gem install cocoapods
```

To integrate CDYelpFusionKit into your Xcode project using CocoaPods, simply add the following line to your Podfile:

```ruby
pod "CDYelpFusionKit" "~> 1.0.0"
```

Afterwards, run the following command:

```ruby
pod install
```

### Installation via Carthage

CDYelpFusionKit is available through [Carthage](https://github.com/Carthage/Carthage). Carthage is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage via [Homebrew](http://brew.sh) with the following commands:

```ruby
brew update
brew install carthage
```

To integrate CDYelpFusionKit into your Xcode project using Carthage, simply add the following line to your Cartfile:

```ruby
github "chrisdhaan/CDYelpFusionKit" ~> 1.0.0
```

Afterwards, run the following command:

```ruby
carthage update
```

Next, add the built CDYelpFusionKit.framework into your Xcode project.

### Installation via Swift Package Manager

CDYelpFusionKit is available through the [Swift Package Manager](https://swift.org/package-manager). The Swift Package Manager is a tool for automating the distribution of Swift code.

The Swift Package Manager is in early development, but CDYelpFusionKit does support its use on supported platforms. Until the Swift Package Manager supports non-host platforms, it is recommended to use CocoaPods, Carthage, or Git Submodules to build iOS, watchOS, and tvOS apps.

The Swift Package Manager is integrated into the Swift compiler.

To integrate CDYelpFusionKit into your Xcode project using The Swift Package Manager, simply add the following line to your Package.swift file:

```swift
dependencies: [
    .Package(url: "https://github.com/chrisdhaan/CDYelpFusionKit.git", majorVersion: 1)
]
```

Afterwards, run the following command:

```ruby
swift package fetch
```

### Git Submodule

CDYelpFusionKit is available through [Git Submodule](https://git-scm.com/docs/git-submodule) Git Submodule allows you to keep another Git repository in a subdirectory of your repository.

If your project is not initialized as a git repository, navigate into your top-level project directory, and install Git Submodule with the following command:

```git
git init
```

To integrate CDYelpFusionKit into your Xcode project using Git Submodule, simply run the following command:

```git
git submodule add https://github.com/chrisdhaan/CDYelpFusionKit.git
```

Afterwards, open the new **CDYelpFusionKit** folder, and drag the **CDYelpFusionKit.xcodeproj** into the **Project Navigator** of your Xcode project. A common location for the **CDYelpFusionKit.xcodeproj** is directly below the **Products** folder.

Next, select your application project in the **Project Navigator** to navigate to the target configuration window and select the application target under the **Targets** heading in the sidebar. In the tab bar at the top of that window, open the **General** panel. Click on the **+** button under the **Embedded Binaries** section. You will see two different CDYelpFusionKit.xcodeproj folders, each with a version of the CDYelpFusionKit.framework nested inside a Products folder. It does not matter which Products folder you choose from, select the CDYelpFusionKit.framework for iOS.

---

## Author

Christopher de Haan, contact@christopherdehaan.me

## Resources

Visit the [Yelp Developers](https://www.yelp.com/developers) portal for additional resources regarding the Yelp API.

## License

CDYelpFusionKit is available under the MIT license. See the LICENSE file for more info.

---
