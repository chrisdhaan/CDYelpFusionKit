// swift-tools-version:5.5
//
//  Package.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 6/10/2022.
//
//  Copyright © 2016-2022 Christopher de Haan <contact@christopherdehaan.me>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import PackageDescription

let package = Package(
    name: "CDYelpFusionKit",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "CDYelpFusionKit",
            targets: ["CDYelpFusionKit"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1"))
    ],
    targets: [
        .target(
            name: "CDYelpFusionKit",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire")
            ],
            path: "Source",
            exclude: ["Info.plist"],
            linkerSettings: [
                .linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS]))
            ])
    ],
    swiftLanguageVersions: [.v5])

