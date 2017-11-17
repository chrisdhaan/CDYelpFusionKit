//
//  UIImage+CDYelpFusionKit.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/9/17.
//
//  Copyright (c) 2016-2017 Christopher de Haan <contact@christopherdehaan.me>
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

#if os(iOS) || os(tvOS)

import UIKit

public extension UIImage {
    
    class func yelpBurstLogoRed() -> UIImage? {
        return UIImage(named: "yelp_burst_logo_red",
                       in: Bundle(identifier: CDYelpFusionKitBundleIdentifier),
                       compatibleWith: nil)
    }
    
    class func yelpBurstLogoWhite() -> UIImage? {
        return UIImage(named: "yelp_burst_logo_white",
                       in: Bundle(identifier: CDYelpFusionKitBundleIdentifier),
                       compatibleWith: nil)
    }
    
    class func yelpLogo() -> UIImage? {
        return UIImage(named: "yelp_logo",
                       in: Bundle(identifier: CDYelpFusionKitBundleIdentifier),
                       compatibleWith: nil)
    }
    
    class func yelpLogoOutline() -> UIImage? {
        return UIImage(named: "yelp_logo_outline",
                       in: Bundle(identifier: CDYelpFusionKitBundleIdentifier),
                       compatibleWith: nil)
    }
    
    class func yelpStars(numberOfStars: CDYelpStars!,
                         forSize size: CDYelpStarsSize!) -> UIImage? {
        return UIImage(named: "yelp_stars_\(numberOfStars.rawValue)_\(size.rawValue)",
                       in: Bundle(identifier: CDYelpFusionKitBundleIdentifier),
                       compatibleWith: nil)
    }
}

#endif
