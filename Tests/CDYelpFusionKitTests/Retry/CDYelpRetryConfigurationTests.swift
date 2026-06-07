@testable import CDYelpFusionKit
import Foundation
import Testing

struct CDYelpRetryConfigurationTests {
    @Test func disabledConfigurationHasZeroRetryLimit() {
        let config = CDYelpRetryConfiguration.disabled
        #expect(config.retryLimit == 0)
        #expect(config.initialDelay == 0)
    }

    @Test func defaultConfigurationHasThreeRetries() {
        let config = CDYelpRetryConfiguration()
        #expect(config.retryLimit == 3)
        #expect(config.initialDelay == 0.5)
    }

    @Test func defaultRetryableStatusCodesMatchExpected() {
        let config = CDYelpRetryConfiguration()
        let expected: Set = [408, 429, 500, 502, 503, 504]
        #expect(config.retryableHTTPStatusCodes == expected)
    }

    @Test func customConfigurationAppliesValues() {
        let config = CDYelpRetryConfiguration(retryLimit: 5, initialDelay: 1.0)
        #expect(config.retryLimit == 5)
        #expect(config.initialDelay == 1.0)
    }

    @Test func clientAcceptsRetryConfiguration() {
        let retry = CDYelpRetryConfiguration(retryLimit: 2, initialDelay: 0.25)
        let client = CDYelpAPIClient(apiKey: "fake-key-for-test", retryConfiguration: retry)
        #expect(client.isAuthenticated())
    }
}
