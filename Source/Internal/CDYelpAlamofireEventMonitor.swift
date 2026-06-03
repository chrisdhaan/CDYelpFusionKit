//
//  CDYelpAlamofireEventMonitor.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 6/3/26.
//
//  Copyright © 2016-2026 Christopher de Haan <contact@christopherdehaan.me>
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

import Alamofire
import Foundation

final class CDYelpAlamofireEventMonitor: EventMonitor {
    let monitors: [any CDYelpEventMonitor]

    init(monitors: [any CDYelpEventMonitor]) {
        self.monitors = monitors
    }

    func requestDidResume(_ request: Request) {
        guard let urlRequest = request.request else { return }
        for monitor in monitors {
            monitor.requestDidStart(urlRequest: urlRequest)
        }
    }

    func requestIsRetrying(_ request: Request) {
        for monitor in monitors {
            monitor.requestWillRetry(urlRequest: request.request, retryCount: request.retryCount)
        }
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        // Unwrap AFError so monitors receive the underlying URLError rather than an Alamofire-specific type.
        let publicError: Error?
        if let afError = response.error, case let .sessionTaskFailed(underlying) = afError {
            publicError = underlying
        } else {
            publicError = response.error
        }
        for monitor in monitors {
            monitor.requestDidComplete(
                urlRequest: request.request,
                response: response.response,
                data: response.data,
                error: publicError
            )
        }
    }
}
