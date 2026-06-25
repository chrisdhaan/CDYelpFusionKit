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
            eventMonitors: eventMonitors,
            requestAdapters: requestAdapters
        )
    }
}
