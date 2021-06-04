//
//  CDYelpBusiness.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/29/16.
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

public struct CDYelpBusiness: Decodable {

    public let id: String?
    public let name: String?
    public let imageUrl: URL?
    public let isClosed: Bool?
    public let url: URL?
    public let price: String?
    public let phone: String?
    public let displayPhone: String?
    public let photos: [String]?
    public let hours: [CDYelpHour]?
    public let rating: Double?
    public let reviewCount: Int?
    public let categories: [CDYelpCategory]?
    public let distance: Double?
    public let coordinates: CDYelpCoordinates?
    public let location: CDYelpLocation?
    public let transactions: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl = "image_url"
        case isClosed = "is_closed"
        case url
        case price
        case phone
        case displayPhone = "display_phone"
        case photos
        case hours
        case rating
        case reviewCount = "review_count"
        case categories
        case distance
        case coordinates
        case location
        case transactions
    }
}
