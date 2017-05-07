//
//  CDYelpAPIClient.swift
//  Pods
//
//  Created by Christopher de Haan on 11/7/16.
//
//  Copyright (c) 2016 Christopher de Haan <contact@christopherdehaan.me>
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

import Alamofire
import AlamofireObjectMapper

open class CDYelpAPIClient: NSObject {
    
    fileprivate var manager = Alamofire.SessionManager()
//    fileprivate lazy var manager: Alamofire.SessionManager = {
//        if let accessToken = self.oAuthAPIClient.oAuthCredential?.accessToken {
//            // Get the default headers
//            var headers = Alamofire.SessionManager.defaultHTTPHeaders
//            // Add the Authorization header
//            headers["Authorization"] = "Bearer \(accessToken)"
//            // Create a custom session configuration
//            let configuration = URLSessionConfiguration.default
//            // Add the Authorization header
//            configuration.httpAdditionalHeaders = headers
//            // Create a session manager with the custom configuration
//            return Alamofire.SessionManager(configuration: configuration)
//        } else {
//            return Alamofire.SessionManager()
//        }
//    }()
    fileprivate let oAuthAPIClient: CDYelpOAuthAPIClient!
    
    // MARK: - Initializers
    public init(clientId: String!,
                clientSecret: String!) {
        assert((clientId != nil && clientId != "") &&
            (clientSecret != nil && clientSecret != ""), "Both a clientId and clientSecret are required to query the Yelp Fusion V3 Developers API oauth endpoint.")
        self.oAuthAPIClient = CDYelpOAuthAPIClient(clientId: clientId,
                                                   clientSecret: clientSecret)
        super.init()
    }
    
    public init(oAuthAPIClient: CDYelpOAuthAPIClient!) {
        self.oAuthAPIClient = oAuthAPIClient
        super.init()
    }
    
    // MARK: - Authorization Methods
    public func authorize() {
        self.oAuthAPIClient.authorize { (successful, error) in
            if let successful = successful,
                successful == true {
                
                if let accessToken = self.oAuthAPIClient.oAuthCredential?.accessToken {
                    // Get the default headers
                    var headers = Alamofire.SessionManager.defaultHTTPHeaders
                    // Add the Authorization header
                    headers["Authorization"] = "Bearer \(accessToken)"
                    // Create a custom session configuration
                    let configuration = URLSessionConfiguration.default
                    // Add the Authorization header
                    configuration.httpAdditionalHeaders = headers
                    // Create a session manager with the custom configuration
                    self.manager = Alamofire.SessionManager(configuration: configuration)
                }
            }
            
            if let error = error {
                print("authorize() failure: ", error.localizedDescription)
            }
        }
    }
    
    public func isAuthorized() -> Bool {
        if let _ = self.oAuthAPIClient.oAuthCredential?.accessToken {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Yelp API Methods
    public func searchBusinesses(byTerm term: String?,
                                 location: String?,
                                 latitude: Double?,
                                 longitude: Double?,
                                 radius: Int?,
                                 categories: [String]?,
                                 locale: String?,
                                 limit: Int?,
                                 offset: Int?,
                                 sortBy: String?,
                                 price: String?,
                                 openNow: Bool?,
                                 openAt: Int?,
                                 attributes: [String]?,
                                 completion: @escaping (CDYelpSearchResponse?, Error?) -> Void) {
        assert((latitude != nil && longitude != nil) ||
            (location != nil && location != ""), "Either a latitude and longitude or a location are required to query the Yelp Fusion V3 Developers API search endpoint.")
        
        if self.isAuthorized() == true {
            
            let params = Parameters.searchParameters(withTerm: term,
                                                     location: location,
                                                     latitude: latitude,
                                                     longitude: longitude,
                                                     radius: radius,
                                                     categories: categories,
                                                     locale: locale,
                                                     limit: limit,
                                                     offset: offset,
                                                     sortBy: sortBy,
                                                     price: price,
                                                     openNow: openNow,
                                                     openAt: openAt,
                                                     attributes: attributes)

            self.manager.request(CDYelpRouter.search(parameters: params)).responseObject { (response: DataResponse<CDYelpSearchResponse>) in

                switch response.result {
                case .success(let searchResponse):
                    completion(searchResponse, nil)
                    break
                case .failure(let error):
                    print("searchBusinesses() failure: ", error.localizedDescription)
                    completion(nil, error)
                    break
                }
            }
        }
    }
    
    public func searchBusinesses(byPhoneNumber phoneNumber: String!,
                                 completion: @escaping (NSObject?) -> Void) {
        assert((phoneNumber != nil && phoneNumber != ""), "A business phone number is required to query the Yelp Fusion V3 Developers API phone endpoint.")
        
        let params = Parameters.phoneParameters(withPhoneNumber: phoneNumber)
        
        self.manager.request(CDYelpRouter.phone(parameters: params)).response { (response) in
            //
        }
    }
    
    public func searchTransactions(byType type: String!,
                                   location: String?,
                                   latitude: Double?,
                                   longitude: Double?,
                                   completion: @escaping (NSObject?) -> Void) {
        assert((type != nil && type != ""), "A transaction type is required to query the Yelp Fusion V3 Developers API transactions endpoint.")
        
        let params = Parameters.transactionsParameters(withLocation: location,
                                                       latitude: latitude,
                                                       longitude: longitude)
        
        self.manager.request(CDYelpRouter.transactions(type: type, parameters: params)).response { (response) in
            //
        }
    }
    
    public func fetchBusiness(byId id: String!,
                              completion: @escaping (NSObject?) -> Void) {
        assert((id != nil && id != ""), "A business id is required to query the Yelp Fusion V3 Developers API business endpoint.")
        
        self.manager.request(CDYelpRouter.business(id: id)).response { (response) in
            //
        }
    }
    
    public func fetchReviews(forBusinessId id: String!,
                             locale: String?,
                             completion: @escaping (NSObject?) -> Void) {
        assert((id != nil && id != ""), "A business id is required to query the Yelp Fusion V3 Developers API reviews endpoint.")
        
        let params = Parameters.reviewsParameters(withLocale: locale)
        
        self.manager.request(CDYelpRouter.reviews(id: id, parameters: params)).response { (response) in
            //
        }
    }
    
    public func autocompleteBusinesses(byTerm term: String!,
                                       latitude: Double!,
                                       longitude: Double!,
                                       locale: String?,
                                       completion: @escaping (NSObject?) -> Void) {
        assert((term != nil && term != "") &&
            latitude != nil &&
            longitude != nil, "A search term, latitude, and longitude are required to query the Yelp Fusion V3 Developers API autocomplete endpoint.")
        
        let params = Parameters.autocompleteParameters(withTerm: term,
                                                       latitude: latitude,
                                                       longitude: longitude,
                                                       locale: locale)
        
        self.manager.request(CDYelpRouter.autocomplete(parameters: params)).response { (response) in
            //
        }
    }
}
