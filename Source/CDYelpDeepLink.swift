//
//  CDYelpDeepLink.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/8/17.
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

#if os(iOS)

import UIKit

public class CDYelpDeepLink: NSObject {
    
    // MARK: - Internal Methods
    
    func addScheme(toPath path: String, openWebIfAppNotInstalled: Bool) {
        if self.isYelpInstalled() {
            self.openYelp(withPath: "\(CDYelpURL.deepLink)///\(path)")
        } else {
            if openWebIfAppNotInstalled {
                self.openYelp(withPath: "\(CDYelpURL.web)\(path)")
            } else {
                print("The Yelp application is not installed and the deep link being attempted is not available on web.")
            }
        }
    }
    
    func openYelp(withPath path: String) {
        if let url = URL(string: path) {
            UIApplication.shared.openURL(url)
        }
    }
    
    // MARK: - Public Methods
    
    ///
    /// Determines whether or not the Yelp application is installed on a device.
    ///
    /// - returns: Bool
    ///
    public func isYelpInstalled() -> Bool {
        guard let url = URL(string: CDYelpURL.deepLink) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    ///
    /// Open the Yelp application (if it is installed on a device). If the Yelp application is not installed the Yelp website is loaded.
    ///
    /// - returns: Void
    ///
    public func openYelp() {
        if self.isYelpInstalled() {
            self.openYelp(withPath: CDYelpURL.deepLink)
        } else {
            self.openYelp(withPath: CDYelpURL.web)
        }
    }
    
    ///
    /// Open the Yelp application (if it is installed on a device) to the search page. If the Yelp application is not installed the Yelp website is loaded.
    ///
    /// - parameters:
    ///   - withTerm: (Optional) Search terms for the Yelp application to query. Specifying no term will search for everything. Term can also be business names such as "Starbucks".
    ///   - category: (Optional) A category to filter the search results with. Use the **CDYelpBusinessCategoryFilter** enum to get the list of supported categories.
    ///   - location: A location to filter the search results with. Specifying no location will use current location.
    ///
    /// - returns: Void
    ///
    public func openYelpToSearch(withTerm term: String?,
                                 category: CDYelpBusinessCategoryFilter?,
                                 location: String?) {
        var path = "search"
        
        if term != nil || category != nil || location != nil {
            path += "?"
        }
        
        if let term = term?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            path += "terms=\(term)"
        }
        
        if let _ = term,
            let category = category?.rawValue {
            path += "&category=\(category)"
        } else if let category = category {
            path += "category=\(category)"
        }
        
        if let _ = term,
            let location = location?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            path += "&location=\(location)"
        } else if let _ = category,
            let location = location {
            path += "&location=\(location)"
        } else if let location = location {
            path += "location=\(location)"
        }
        
        self.addScheme(toPath: path, openWebIfAppNotInstalled: true)
    }
    
    ///
    /// Open the Yelp application (if it is installed on a device) to a business page. If the Yelp application is not installed the Yelp website is loaded.
    ///
    /// - parameters:
    ///   - forId: (**Required**) The identifier of the business for the Yelp application to query.
    ///
    /// - returns: Void
    ///
    public func openYelpToBusiness(forId id: String!) {
        assert((id != nil && id != ""), "A business id is to query the Yelp business deep link.")
        
        var path = "biz/"
        
        if let id = id {
            path += "\(id)"
        }
        
        self.addScheme(toPath: path, openWebIfAppNotInstalled: true)
    }
    
    ///
    /// Open the Yelp application (if it is installed on a device) to the check-in nearby page. If the Yelp application is not installed the Yelp website is **NOT** loaded.
    ///
    /// - returns: Void
    ///
    public func openYelpToCheckInNearby() {
        self.addScheme(toPath: "check_in/nearby", openWebIfAppNotInstalled: false)
    }
    
    ///
    /// Open the Yelp application (if it is installed on a device) to the check-ins page. If the Yelp application is not installed the Yelp website is **NOT** loaded.
    ///
    /// - returns: Void
    ///
    public func openYelpToCheckIns() {
        self.addScheme(toPath: "check_ins", openWebIfAppNotInstalled: false)
    }
    
    ///
    /// Open the Yelp application (if it is installed on a device) to the check-ins page sorted by rankings. If the Yelp application is not installed the Yelp website is **NOT** loaded.
    ///
    /// - returns: Void
    ///
    public func openYelpToCheckInRankings() {
        self.addScheme(toPath: "check_in/rankings", openWebIfAppNotInstalled: false)
    }
}

#endif
