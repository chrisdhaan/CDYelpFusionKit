//
//  CDYelpAPIClient.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 11/7/16.
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

#if os(macOS)
    import Foundation
#else
    import UIKit
#endif

public final class CDYelpAPIClient: Sendable {
    private let apiKey: String
    private let decoderConfiguration: CDYelpDecoderConfiguration
    private let urlSession: CDYelpURLSession

    // MARK: - Initializers

    ///
    /// Initializes a new CDYelpAPIClient object.
    ///
    /// - parameters:
    ///   - apiKey: (**Required**) A unique key for the Yelp application used for authenticating with the Yelp Fusion API. **Do not share this key**.
    ///   - cacheConfiguration: (Optional) Configuration for the built-in response cache. Defaults to disabled.
    ///   - retryConfiguration: (Optional) Configuration for automatic retry with exponential backoff. Defaults to disabled.
    ///   - decoderConfiguration: (Optional) Configuration for JSON decoding strategies. Defaults to standard configuration.
    ///   - eventMonitors: (Optional) An array of event monitors to observe CDYelpFusionKit request and response events. Defaults to an empty array.
    ///   - requestAdapters: (Optional) An array of request adapters to mutate URLRequests before sending. Defaults to an empty array.
    ///
    public convenience init(
        apiKey: String,
        cacheConfiguration: CDYelpCacheConfiguration = .disabled,
        retryConfiguration: CDYelpRetryConfiguration = .disabled,
        decoderConfiguration: CDYelpDecoderConfiguration = .default,
        eventMonitors: [any CDYelpEventMonitor] = [],
        requestAdapters: [any CDYelpRequestAdapter] = []
    ) {
        self.init(
            apiKey: apiKey,
            sessionConfiguration: .default,
            cacheConfiguration: cacheConfiguration,
            retryConfiguration: retryConfiguration,
            decoderConfiguration: decoderConfiguration,
            eventMonitors: eventMonitors,
            requestAdapters: requestAdapters
        )
    }

    ///
    /// Initializes a new CDYelpAPIClient object with a custom URLSessionConfiguration. This
    /// overload exists primarily so `CDYelpMockClientFactory` (in the separate `CDYelpFusionKitTesting`
    /// target) can inject a configuration whose `protocolClasses` route requests through
    /// `CDYelpMockURLProtocol` for testing.
    ///
    /// - parameters:
    ///   - apiKey: (**Required**) A unique key for the Yelp application used for authenticating with the Yelp Fusion API. **Do not share this key**.
    ///   - sessionConfiguration: (**Required**) The `URLSessionConfiguration` used to construct the underlying `URLSession`.
    ///   - cacheConfiguration: (Optional) Configuration for the built-in response cache. Defaults to disabled.
    ///   - retryConfiguration: (Optional) Configuration for automatic retry with exponential backoff. Defaults to disabled.
    ///   - decoderConfiguration: (Optional) Configuration for JSON decoding strategies. Defaults to standard configuration.
    ///   - eventMonitors: (Optional) An array of event monitors to observe CDYelpFusionKit request and response events. Defaults to an empty array.
    ///   - requestAdapters: (Optional) An array of request adapters to mutate URLRequests before sending. Defaults to an empty array.
    ///
    public init(
        apiKey: String,
        sessionConfiguration: URLSessionConfiguration,
        cacheConfiguration: CDYelpCacheConfiguration = .disabled,
        retryConfiguration: CDYelpRetryConfiguration = .disabled,
        decoderConfiguration: CDYelpDecoderConfiguration = .default,
        eventMonitors: [any CDYelpEventMonitor] = [],
        requestAdapters: [any CDYelpRequestAdapter] = []
    ) {
        precondition(!apiKey.isEmpty, "An apiKey is required to query the Yelp Fusion API.")
        self.apiKey = apiKey
        self.decoderConfiguration = decoderConfiguration
        let cache = cacheConfiguration.ttl > 0
            ? CDYelpResponseCache(configuration: cacheConfiguration)
            : nil
        urlSession = CDYelpURLSession(
            session: URLSession(configuration: sessionConfiguration),
            makeDecoder: { decoderConfiguration.makeDecoder() },
            cache: cache,
            monitors: eventMonitors,
            adapters: requestAdapters,
            retryConfig: retryConfiguration
        )
    }

    // MARK: - Cache Methods

    /// Removes all cached responses.
    public func clearCache() {
        urlSession.clearCache()
    }

    // MARK: - Decoding Helpers

    /// Builds a decoder honoring `decoderConfiguration` with the given date format substituted in,
    /// shared by the reviews/events endpoints whose date fields don't use the default ISO-8601 strategy.
    /// Not private: called from the endpoint extensions in CDYelpAPIClient+*.swift.
    func makeDecoder(dateFormat: DateFormatter) -> JSONDecoder {
        let decoder = decoderConfiguration.makeDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormat)
        return decoder
    }

    // MARK: - Request Methods

    /// Cancels any in progress or pending API requests. Suspends until cancellation has been
    /// applied to all in-flight tasks and retry backoff sleeps.
    public func cancelAllPendingAPIRequests() async {
        await urlSession.cancelAllTasks()
    }

    /// Builds and performs the request for a router case, shared by every endpoint method below
    /// so the "build request, perform, honor cacheability" sequence is expressed once.
    /// Not private: called from the endpoint extensions in CDYelpAPIClient+*.swift.
    func perform<T: Decodable & Sendable>(_ router: CDYelpRouter, decoder: JSONDecoder? = nil) async throws -> T {
        try await urlSession.perform(
            buildRequest: { try router.asURLRequest(apiKey: self.apiKey) },
            decoder: decoder,
            cacheable: router.isCacheable
        )
    }
}
