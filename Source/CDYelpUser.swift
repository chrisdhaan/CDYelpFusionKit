//
//  CDYelpUser.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 5/7/17.
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

#if !os(OSX)
    import UIKit
#else
    import Foundation
#endif

public struct CDYelpUser: Decodable {

    public let id: String?
    public let profileUrl: String?
    public let name: String?
    public let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case profileUrl = "profile_url"
        case name
        case imageUrl = "image_url"
    }

    public func profileUrlAsUrl() -> URL? {
        if let profileUrl = self.profileUrl,
           let asUrl = URL(string: profileUrl) {
            return asUrl
        }
        return nil
    }

    public func imageUrlAsUrl() -> URL? {
        if let imageUrl = self.imageUrl,
           let asUrl = URL(string: imageUrl) {
            return asUrl
        }
        return nil
    }
}
