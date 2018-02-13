//
//  URL+CDYelpFusionKit.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/16/17.
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

public extension URL {

    // MARK: - Private Methods
    
    static private func addScheme(toPath path: String,
                                  forWeb: Bool) -> URL? {
        if forWeb {
            return self.yelpURL(withPath: "\(CDYelpURL.web)\(path)")
        } else {
            return self.yelpURL(withPath: "\(CDYelpURL.deepLink)///\(path)")
        }
    }
    
    static private func yelpURL(withPath path: String) -> URL? {
        if let url = URL(string: path) {
            return url
        }
        return nil
    }
    
    // MARK: - Public Methods
    
    ///
    /// Initializes a URL that can be used to open the Yelp application (if it is installed on a device).
    ///
    /// - returns: URL?
    ///
    static func yelpDeepLink() -> URL? {
        return self.yelpURL(withPath: CDYelpURL.deepLink)
    }
    
    ///
    /// Initializes a URL that can be used to open the Yelp website.
    ///
    /// - returns: URL?
    ///
    static func yelpWebLink() -> URL? {
        return self.yelpURL(withPath: CDYelpURL.web)
    }
    
    ///
    /// Initializes a URL that can be used to open the Yelp application (if it is installed on a device) to the search page.
    ///
    /// - parameters:
    ///   - withTerm: (Optional) Search terms for the Yelp application to query. Specifying no term will search for everything. Term can also be business names such as "Starbucks".
    ///   - category: (Optional) A category to filter the search results with. Use the **CDYelpBusinessCategoryFilter** enum to get the list of supported categories.
    ///   - location: A location to filter the search results with. Specifying no location will use current location.
    ///
    /// - returns: URL?
    ///
    static func yelpSearchDeepLink(withTerm term: String?,
                                   category: CDYelpBusinessCategoryFilter?,
                                   location: String?) -> URL? {
        let path = String.searchLinkPath(withTerm: term,
                                         category: category,
                                         location: location)
        
        return self.addScheme(toPath: path,
                              forWeb: false)
    }
    
    ///
    /// Initializes a URL that can be used to open the Yelp website to the search page.
    ///
    /// - parameters:
    ///   - withTerm: (Optional) Search terms for the Yelp application to query. Specifying no term will search for everything. Term can also be business names such as "Starbucks".
    ///   - category: (Optional) A category to filter the search results with. Use the **CDYelpBusinessCategoryFilter** enum to get the list of supported categories.
    ///   - location: A location to filter the search results with. Specifying no location will use current location.
    ///
    /// - returns: URL?
    ///
    static func yelpSearchWebLink(withTerm term: String?,
                                  category: CDYelpBusinessCategoryFilter?,
                                  location: String?) -> URL? {
        let path = String.searchLinkPath(withTerm: term,
                                         category: category,
                                         location: location)
        
        return self.addScheme(toPath: path,
                              forWeb: true)
    }
    
    ///
    /// Initializes a URL that can be used to open the Yelp application (if it is installed on a device) to a business page.
    ///
    /// - parameters:
    ///   - forId: (**Required**) The identifier of the business for the Yelp application to query.
    ///
    /// - returns: URL?
    ///
    static func yelpBusinessDeepLink(forId id: String!) -> URL? {
        assert((id != nil && id != ""), "A business id is to query the Yelp business deep link.")
        
        let path = String.businessLinkPath(forId: id)
        
        return self.addScheme(toPath: path,
                              forWeb: false)
    }
    
    ///
    /// Initializes a URL that can be used to open the Yelp website to a business page.
    ///
    /// - parameters:
    ///   - forId: (**Required**) The identifier of the business for the Yelp application to query.
    ///
    /// - returns: URL?
    ///
    static func yelpBusinessWebLink(forId id: String!) -> URL? {
        assert((id != nil && id != ""), "A business id is to query the Yelp business deep link.")
        
        let path = String.businessLinkPath(forId: id)
        
        return self.addScheme(toPath: path,
                              forWeb: true)
    }
    
    ///
    /// Initializes a URL that can be used to open the Yelp application (if it is installed on a device) to the check-in nearby page.
    ///
    /// - returns: URL?
    ///
    static func yelpCheckInNearbyDeepLink() -> URL? {
        return self.addScheme(toPath: "check_in/nearby",
                              forWeb: false)
    }
    
    ///
    /// Initializes a URL that can be used to open the Yelp application (if it is installed on a device) to the check-ins page.
    ///
    /// - returns: URL?
    ///
    static func yelpCheckInsDeepLink() -> URL? {
        return self.addScheme(toPath: "check_ins",
                              forWeb: false)
    }
    
    ///
    /// Initializes a URL that can be used to open the Yelp application (if it is installed on a device) to the check-ins page sorted by rankings.
    ///
    /// - returns: URL?
    ///
    static func yelpCheckInRankingsDeepLink() -> URL? {
        return self.addScheme(toPath: "check_in/rankings",
                              forWeb: false)
    }
}
