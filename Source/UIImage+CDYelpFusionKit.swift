//
//  UIImage+CDYelpFusionKit.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/9/17.
//
//  Copyright © 2016-2018 Christopher de Haan <contact@christopherdehaan.me>
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

public extension CDImage {

    private class func cdImage(named name: String!) -> CDImage? {
#if os(iOS) || os(tvOS)
        return CDImage(named: name,
                       in: Bundle(identifier: CDYelpFusionKitBundleIdentifier),
                       compatibleWith: nil)
#elseif os(watchOS)
        return CDImage(named: name)
#else
#if swift(>=4.2)
        let bundle = Bundle(identifier: CDYelpFusionKitBundleIdentifier)
        return bundle?.image(forResource: name)
#elseif swift(>=4.0)
        let bundle = Bundle(identifier: CDYelpFusionKitBundleIdentifier)
        let resource = CDImage.Name(rawValue: name)
        return bundle?.image(forResource: resource)
#else
        let bundle = Bundle(identifier: CDYelpFusionKitBundleIdentifier)
        return bundle?.image(forResource: name)
#endif
#endif
    }

    class func yelpBurstLogoRed() -> CDImage? {
        return CDImage.cdImage(named: "yelp_burst_logo_red")
    }

    class func yelpBurstLogoWhite() -> CDImage? {
        return CDImage.cdImage(named: "yelp_burst_logo_white")
    }

    class func yelpLogo() -> CDImage? {
        return CDImage.cdImage(named: "yelp_logo")
    }

    class func yelpLogoOutline() -> CDImage? {
        return CDImage.cdImage(named: "yelp_logo_outline")
    }

    class func yelpStars(numberOfStars: CDYelpStars!,
                         forSize size: CDYelpStarsSize!) -> CDImage? {
        return CDImage.cdImage(named: "yelp_stars_\(numberOfStars.rawValue)_\(size.rawValue)")
    }
}
