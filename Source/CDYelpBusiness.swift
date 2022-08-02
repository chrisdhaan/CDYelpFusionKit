//
//  CDYelpBusiness.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/29/16.
//
//  Copyright © 2016-2022 Christopher de Haan <contact@christopherdehaan.me>
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

public struct CDYelpBusiness {
    public struct BusinessSearch: Decodable {

        public let categories: [CDYelpCategory]?
        public let coordinates: CDYelpCoordinates?
        public let displayPhone: String?
        public let distance: Double?
        public let id: String?
        public let alias: String?
        public let imageUrl: String?
        public let isClosed: Bool?
        public let location: CDYelpLocation.Detailed?
        public let name: String?
        public let phone: String?
        public let price: String?
        public let rating: Double?
        public let reviewCount: Int?
        public let url: String?
        public let transactions: [String]?

        enum CodingKeys: String, CodingKey {
            case categories
            case coordinates
            case displayPhone = "display_phone"
            case distance
            case id
            case alias
            case imageUrl = "image_url"
            case isClosed = "is_closed"
            case location
            case name
            case phone
            case price
            case rating
            case reviewCount = "review_count"
            case url
            case transactions
        }

        public func imageUrlAsUrl() -> URL? {
            if let imageUrl = self.imageUrl,
               let asUrl = URL(string: imageUrl) {
                return asUrl
            }
            return nil
        }

        public func urlAsUrl() -> URL? {
            if let url = self.url,
               let asUrl = URL(string: url) {
                return asUrl
            }
            return nil
        }
    }

    public struct PhoneSearch: Decodable {

        public let id: String?
        public let alias: String?
        public let name: String?
        public let imageUrl: String?
        public let isClosed: Bool?
        public let url: String?
        public let price: String?
        public let phone: String?
        public let rating: Double?
        public let reviewCount: Int?
        public let categories: [CDYelpCategory]?
        public let coordinates: CDYelpCoordinates?
        public let location: CDYelpLocation?
        public let transactions: [String]?

        enum CodingKeys: String, CodingKey {
            case id
            case alias
            case name
            case imageUrl = "image_url"
            case isClosed = "is_closed"
            case url
            case price
            case phone
            case rating
            case reviewCount = "review_count"
            case categories
            case coordinates
            case location
            case transactions
        }

        public func imageUrlAsUrl() -> URL? {
            if let imageUrl = self.imageUrl,
               let asUrl = URL(string: imageUrl) {
                return asUrl
            }
            return nil
        }

        public func urlAsUrl() -> URL? {
            if let url = self.url,
               let asUrl = URL(string: url) {
                return asUrl
            }
            return nil
        }
    }

    public struct TransactionSearch: Decodable {

        public let id: String?
        public let alias: String?
        public let name: String?
        public let imageUrl: String?
        public let isClosed: Bool?
        public let url: String?
        public let price: String?
        public let phone: String?
        public let rating: Double?
        public let reviewCount: Int?
        public let categories: [CDYelpCategory]?
        public let coordinates: CDYelpCoordinates?
        public let location: CDYelpLocation?
        public let transactions: [String]?

        enum CodingKeys: String, CodingKey {
            case id
            case alias
            case name
            case imageUrl = "image_url"
            case isClosed = "is_closed"
            case url
            case price
            case phone
            case rating
            case reviewCount = "review_count"
            case categories
            case coordinates
            case location
            case transactions
        }

        public func imageUrlAsUrl() -> URL? {
            if let imageUrl = self.imageUrl,
               let asUrl = URL(string: imageUrl) {
                return asUrl
            }
            return nil
        }

        public func urlAsUrl() -> URL? {
            if let url = self.url,
               let asUrl = URL(string: url) {
                return asUrl
            }
            return nil
        }
    }

    public struct Detailed: Decodable {

        public let categories: [CDYelpCategory]?
        public let coordinates: CDYelpCoordinates?
        public let displayPhone: String?
        public let hours: [CDYelpHour]?
        public let id: String?
        public let alias: String?
        public let imageUrl: String?
        public let isClaimed: Bool?
        public let isClosed: Bool?
        public let location: CDYelpLocation.Detailed?
        public let messaging: CDYelpMessaging?
        public let name: String?
        public let phone: String?
        public let photos: [String]?
        public let price: String?
        public let rating: Double?
        public let reviewCount: Int?
        public let url: String?
        public let transactions: [String]?
        public let specialHours: [CDYelpSpecialHour]?
        public let attributes: [String: String]?

        enum CodingKeys: String, CodingKey {
            case categories
            case coordinates
            case displayPhone = "display_phone"
            case hours
            case id
            case alias
            case imageUrl = "image_url"
            case isClaimed = "is_claimed"
            case isClosed = "is_closed"
            case location
            case messaging
            case name
            case phone
            case photos
            case price
            case rating
            case reviewCount = "review_count"
            case url
            case transactions
            case specialHours
            case attributes
        }

        public func imageUrlAsUrl() -> URL? {
            if let imageUrl = self.imageUrl,
               let asUrl = URL(string: imageUrl) {
                return asUrl
            }
            return nil
        }

        public func urlAsUrl() -> URL? {
            if let url = self.url,
               let asUrl = URL(string: url) {
                return asUrl
            }
            return nil
        }

        public func photosAsUrls() -> [URL] {
            var asUrls: [URL] = []
            if let photos = self.photos {
                for photo in photos {
                    if let url = URL(string: photo) {
                        asUrls.append(url)
                    }
                }
            }
            return asUrls
        }
    }

    public struct BusinessMatch: Decodable {

        public let id: String?
        public let alias: String?
        public let name: String?
        public let location: CDYelpLocation.Detailed?
        public let coordinates: CDYelpCoordinates?
        public let phone: String?

        enum CodingKeys: String, CodingKey {
            case id
            case alias
            case name
            case location
            case coordinates
            case phone
        }
    }

    public struct Autocomplete: Decodable {

        public let id: String?
        public let name: String?

        enum CodingKeys: String, CodingKey {
            case id
            case name
        }
    }
}
