//
//  String+CDYelpFusionKit.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/16/17.
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

extension String {

    static func searchLinkPath(withTerm term: String?,
                               category: CDYelpBusinessCategoryFilter?,
                               location: String?) -> String {
        var path = "search"

        if term != nil || category != nil || location != nil {
            path += "?"
        }

        if let term = term?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            path += "terms=\(term)"
        }

        if term != nil,
            let category = category?.rawValue {
            path += "&category=\(category)"
        } else if let category = category {
            path += "category=\(category)"
        }

        if term != nil,
            let location = location?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            path += "&location=\(location)"
        } else if category != nil,
            let location = location {
            path += "&location=\(location)"
        } else if let location = location {
            path += "location=\(location)"
        }

        return path
    }

    static func businessLinkPath(forId id: String!) -> String {
        var path = "biz/"

        if let id = id {
            path += "\(id)"
        }

        return path
    }
}
