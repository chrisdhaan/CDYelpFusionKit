//
//  CDYelpRegion.swift
//  Pods
//
//  Created by Christopher de Haan on 5/6/17.
//
//

import ObjectMapper

public class CDYelpRegion: Mappable {

    public var center: CDYelpCenter?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        center  <- map["center"]
    }
}
