//
//  CDYelpBusiness.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/29/16.
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

public class CDYelpBusiness: Mappable {

    public var id: String?
    public var name: String?
    public var imageUrl: URL?
    public var isClosed: Bool?
    public var url: URL?
    public var price: String?
    public var phone: String?
    public var displayPhone: String?
    public var photos: [String]?
    public var hours: [CDYelpHour]?
    public var rating: Double?
    public var reviewCount: Int?
    public var categories: [CDYelpCategory]?
    public var distance: Double?
    public var coordinates: CDYelpCoordinates?
    public var location: CDYelpLocation?
    public var transactions: [String]?

    public required init?(map: Map) {
    }

    public func mapping(map: Map) {
        id              <- map["id"]
        name            <- map["name"]
        imageUrl        <- (map["image_url"], URLTransform())
        isClosed        <- map["is_closed"]
        url             <- (map["url"], URLTransform())
        price           <- map["price"]
        phone           <- map["phone"]
        displayPhone    <- map["display_phone"]
        photos          <- map["photos"]
        hours           <- map["hours"]
        rating          <- map["rating"]
        reviewCount     <- map["review_count"]
        categories      <- map["categories"]
        distance        <- map["distance"]
        coordinates     <- map["coordinates"]
        location        <- map["location"]
        transactions    <- map["transactions"]
    }
}
