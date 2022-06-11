//
//  CDYelpLocation.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 5/6/17.
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

public struct CDYelpLocation: Decodable {

    public let addressOne: String?
    public let addressTwo: String?
    public let addressThree: String?
    public let city: String?
    public let state: String?
    public let zipCode: String?
    public let country: String?
    public let displayAddress: [String]?
    public let crossStreets: String?

    enum CodingKeys: String, CodingKey {
        case addressOne = "address1"
        case addressTwo = "address2"
        case addressThree = "address3"
        case city
        case state
        case zipCode = "zip_code"
        case country
        case displayAddress = "display_address"
        case crossStreets = "cross_streets"
    }
}
