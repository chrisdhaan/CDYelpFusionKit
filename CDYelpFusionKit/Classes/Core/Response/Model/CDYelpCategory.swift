//
//  CDYelpCategory.swift
//  Pods
//
//  Created by Christopher de Haan on 5/6/17.
//
//

import ObjectMapper

public class CDYelpCategory: Mappable {

    public var alias: String?
    public var title: String?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        alias   <- map["alias"]
        title   <- map["title"]
    }
}
