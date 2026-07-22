//
//  CDYelpRequestAdapter.swift
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

import Foundation

/// Adapts a URLRequest before it is sent by CDYelpFusionKit.
///
/// - Important: `adapt(_:)` runs exactly once per logical API call, before the first attempt —
///   not once per retry attempt. If a retry occurs (see `CDYelpRetryConfiguration`), the same
///   already-adapted request is resent unchanged. An adapter that refreshes an expiring token or
///   signs requests with a per-attempt nonce/timestamp will not get a fresh value on retry; such
///   an adapter should refresh proactively before the request reaches CDYelpFusionKit, rather than
///   relying on being re-invoked mid-retry.
/// - Important: An error thrown from `adapt(_:)` must be safe to share across concurrency domains —
///   it crosses an actor boundary on its way to the caller. If the error is already a
///   `CDYelpNetworkError`, it is rethrown unchanged; any other error is wrapped in
///   `CDYelpNetworkError.invalidRequest`. `CDYelpNetworkError` is `@unchecked Sendable` specifically
///   to accommodate this, since the protocol itself cannot require `adapt(_:)`'s thrown error type
///   to be `Sendable`.
public protocol CDYelpRequestAdapter: AnyObject, Sendable {
    /// Mutate and return the request. Return the request unchanged to pass it through.
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest
}
