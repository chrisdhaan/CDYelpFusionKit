//
//  CDYelpCacheKey.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 6/3/26.
//

import Foundation

enum CDYelpCacheKey {
    static func key(for urlRequest: URLRequest) -> String {
        let url = urlRequest.url?.absoluteString ?? ""
        let method = urlRequest.httpMethod ?? "GET"
        return "\(method):\(url)"
    }
}
