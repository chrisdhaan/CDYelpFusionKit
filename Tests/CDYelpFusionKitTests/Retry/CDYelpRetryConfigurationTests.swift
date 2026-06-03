@testable import CDYelpFusionKit
import Foundation
import Testing

struct CDYelpRetryConfigurationTests {
    @Test func defaultConfigurationIsDisabled() {
        let config = CDYelpRetryConfiguration.disabled
        #expect(config.retryLimit == 0)
    }

    @Test func customConfigurationAppliesValues() {
        let config = CDYelpRetryConfiguration(retryLimit: 5, initialDelay: 1.0)
        #expect(config.retryLimit == 5)
        #expect(config.initialDelay == 1.0)
    }

    @Test func defaultRetryableStatusCodesContainRateLimit() {
        let config = CDYelpRetryConfiguration()
        #expect(config.retryableHTTPStatusCodes.contains(429))
    }

    @Test func clientInitializesWithRetryConfiguration() {
        let retry = CDYelpRetryConfiguration(retryLimit: 2, initialDelay: 0.25)
        let client = CDYelpAPIClient(apiKey: "fake-key-for-test", retryConfiguration: retry)
        #expect(client.isAuthenticated())
    }
}
