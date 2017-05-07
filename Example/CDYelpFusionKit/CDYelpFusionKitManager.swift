//
//  CDYelpKitManager.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 5/6/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import CDYelpFusionKit
import UIKit

final class CDYelpFusionKitManager: NSObject {
    
    static let shared = CDYelpFusionKitManager()
    
    var yelpAPIClient: CDYelpAPIClient!
    
    func configure() {
        let yelpOAuthManager = CDYelpOAuthAPIClient(clientId: "c2ga0ZniC7rQMICCibYK6g",
                                                    clientSecret: "F4CbFYVJuWVP2pE8QvS2oitpCcFRHCsciQiga74gaYnEAcqrTWwq42IeePyau5Et")
        self.yelpAPIClient = CDYelpAPIClient(oAuthAPIClient: yelpOAuthManager)
//        self.yelpAPIClient = CDYelpAPIClient(clientId: "",
//                                             clientSecret: "")
        self.yelpAPIClient.authorize()
    }
}
