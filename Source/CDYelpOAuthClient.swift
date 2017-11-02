//
//  CDYelpOAuthManager.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/7/16.
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

import Alamofire
import AlamofireObjectMapper

class CDYelpOAuthClient: NSObject {
    
    private let clientId: String!
    private let clientSecret: String!
    
    // MARK: - Initializers
    
    init(clientId: String!,
         clientSecret: String!) {
        assert((clientId != nil && clientId != "") &&
            (clientSecret != nil && clientSecret != ""), "Both a clientId and clientSecret are required to query the Yelp Fusion API oauth endpoint.")
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    // MARK: - Authorization Methods
    
    func authorize(completion: @escaping (Bool?, Error?) -> Void) {
        let params: Parameters = ["grant_type": "client_credentials",
                                  "client_id": self.clientId,
                                  "client_secret": self.clientSecret]
        Alamofire.request(CDYelpOAuthRouter.authorize(parameters: params)).responseObject { (response: DataResponse<CDYelpOAuthCredential>) in
            switch response.result {
            case .success(let oAuthCredential):
                let defaults = UserDefaults.standard
                // Save access token
                defaults.set(oAuthCredential.accessToken, forKey: CDYelpDefaults.accessToken)
                // Get current time in Int format
                let currentDate = Int(Date().timeIntervalSince1970)
                var expirationDate = currentDate
                if let expiresIn = oAuthCredential.expiresIn {
                    // Add the number of seconds until expiration
                    expirationDate = expirationDate + expiresIn - 86400
                }
                // Save the expiration time
                defaults.set(expirationDate, forKey: CDYelpDefaults.expiresIn)
                defaults.synchronize()
                completion(true, nil)
            case .failure(let error):
                print("authorize() failure: ", error.localizedDescription)
                completion(false, error)
            }
        }
    }
    
    func isAuthorized() -> Bool {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: CDYelpDefaults.accessToken),
            self.isAuthorizationExpired() == false {
            return true
        } else {
            return false
        }
    }
    
    func isAuthorizationExpired() -> Bool {
        let defaults = UserDefaults.standard
        let expiresIn = defaults.integer(forKey: CDYelpDefaults.expiresIn)
        let expirationDate = Date(timeIntervalSince1970: TimeInterval(expiresIn))
        let currentDate = Date()
        if currentDate > expirationDate {
            return true
        } else {
            return false
        }
    }
    
    func accessToken() -> String? {
        let defaults = UserDefaults.standard
        if let accessToken = defaults.string(forKey: CDYelpDefaults.accessToken) {
            return accessToken
        } else {
            return nil
        }
    }
}
