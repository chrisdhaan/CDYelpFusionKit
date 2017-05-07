//
//  CDYelpLocation.swift
//  Pods
//
//  Created by Christopher de Haan on 5/6/17.
//
//

import ObjectMapper

public class CDYelpLocation: Mappable {

    public var addressOne: String?
    public var addressTwo: String?
    public var addressThree: String?
    public var city: String?
    public var country: String?
    public var displayAddress: [String]?
    public var state: String?
    public var zipCode: String?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        addressOne      <- map["address1"]
        addressTwo      <- map["address2"]
        addressThree    <- map["address3"]
        city            <- map["city"]
        country         <- map["country"]
        displayAddress  <- map["display_address"]
        state           <- map["state"]
        zipCode         <- map["zip_code"]
    }
}
