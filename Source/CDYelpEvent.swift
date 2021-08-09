//
//  CDYelpEvent.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/1/17.
//
//  Copyright © 2016-2021 Christopher de Haan <contact@christopherdehaan.me>
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

#if !os(OSX)
 import UIKit
#else
 import Foundation
#endif

public struct CDYelpEvent: Decodable {

    public let attendingCount: Int?
    public let category: String?
    public let cost: Int?
    public let costMax: Double?
    public let description: String?
    public let eventSiteUrl: URL?
    public let id: String?
    public let imageUrl: URL?
    public let interestedCount: Int?
    public let isCanceled: Bool?
    public let isFree: Bool?
    public let isOfficial: Bool?
    public let latitude: Double?
    public let longitude: Double?
    public let name: String?
    public let ticketsUrl: String?
    public let timeEnd: Date?
    public let timeStart: Date?
    public let location: CDYelpLocation?
    public let businessId: String?

    enum CodingKeys: String, CodingKey {
        case attendingCount = "attending_count"
        case category
        case cost
        case costMax = "cost_max"
        case description
        case eventSiteUrl = "event_site_url"
        case id
        case imageUrl = "image_url"
        case interestedCount = "interested_count"
        case isCanceled = "is_canceled"
        case isFree = "is_free"
        case isOfficial = "is_official"
        case latitude
        case longitude
        case name
        case ticketsUrl = "tickets_url"
        case timeEnd = "time_end"
        case timeStart = "time_start"
        case location
        case businessId = "business_id"
    }
}
