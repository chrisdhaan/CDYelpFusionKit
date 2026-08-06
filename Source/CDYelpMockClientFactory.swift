// The CDYelpFusionKitTesting target in CDYelpFusionKit.xcodeproj doesn't link
// CDYelpFusionKit.framework (empty Frameworks phase, no target dependency) — it exists only to
// mirror the SPM/CocoaPods Testing product in Xcode's file navigator, not to build standalone.
// SWIFT_PACKAGE is set only when compiling through SPM, where the dependency is real.
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
