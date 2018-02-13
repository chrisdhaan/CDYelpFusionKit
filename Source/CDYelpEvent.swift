//
//  CDYelpEvent.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/1/17.
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

import ObjectMapper

public class CDYelpEvent: Mappable {

    public var attendingCount: Int?
    public var category: String?
    public var cost: Int?
    public var costMax: Int?
    public var description: String?
    public var eventSiteUrl: URL?
    public var id: String?
    public var imageUrl: URL?
    public var interestedCount: Int?
    public var isCanceled: Bool?
    public var isFree: Bool?
    public var isOfficial: Bool?
    public var latitude: Double?
    public var longitude: Double?
    public var name: String?
    public var ticketsUrl: URL?
    public var timeEnd: Date?
    public var timeStart: Date?
    public var location: CDYelpLocation?
    public var businessId: String?
    
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        attendingCount  <- map["attending_count"]
        category        <- map["category"]
        cost            <- map["cost"]
        costMax         <- map["cost_max"]
        description     <- map["description"]
        eventSiteUrl    <- (map["event_site_url"], URLTransform())
        id              <- map["id"]
        imageUrl        <- (map["image_url"], URLTransform())
        interestedCount <- map["interested_count"]
        isCanceled      <- map["is_canceled"]
        isFree          <- map["is_free"]
        isOfficial      <- map["is_official"]
        latitude        <- map["latitude"]
        longitude       <- map["longitude"]
        name            <- map["name"]
        ticketsUrl      <- (map["tickets_url"], URLTransform())
        timeEnd         <- (map["time_end"], DateTransform())
        timeStart       <- (map["time_start"], DateTransform())
        location        <- map["location"]
        businessId      <- map["business_id"]
    }
}
