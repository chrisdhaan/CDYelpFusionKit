// This file isn't part of any target in CDYelpFusionKit.xcodeproj. It used to belong to a
// CDYelpFusionKitTesting Xcode target with an empty Frameworks phase and no dependency on
// CDYelpFusionKit (so it could never actually build there); that target has since been removed.
// SWIFT_PACKAGE is set only when compiling through SPM, which is where this file is actually built.
#if SWIFT_PACKAGE
    import CDYelpFusionKit
#endif
import Foundation

/// Creates CDYelpAPIClient instances configured for testing with CDYelpMockURLProtocol.
public enum CDYelpMockClientFactory {
    /// Returns a CDYelpAPIClient whose session uses CDYelpMockURLProtocol for all requests.
    public static func makeClient(
        apiKey: String = "test-api-key",
        cacheConfiguration: CDYelpCacheConfiguration = .disabled,
        retryConfiguration: CDYelpRetryConfiguration = .disabled,
        decoderConfiguration: CDYelpDecoderConfiguration = .default,
        eventMonitors: [any CDYelpEventMonitor] = [],
        requestAdapters: [any CDYelpRequestAdapter] = []
    ) -> CDYelpAPIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CDYelpMockURLProtocol.self]
        return CDYelpAPIClient(
            apiKey: apiKey,
            sessionConfiguration: configuration,
            cacheConfiguration: cacheConfiguration,
            retryConfiguration: retryConfiguration,
            decoderConfiguration: decoderConfiguration,
            eventMonitors: eventMonitors,
            requestAdapters: requestAdapters
        )
    }
}
