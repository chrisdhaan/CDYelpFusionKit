@testable import CDYelpFusionKit
import Foundation
import Testing

struct CDYelpDecoderConfigurationTests {
    @Test func defaultConfigurationMakesStandardDecoder() {
        let config = CDYelpDecoderConfiguration.default
        let decoder = config.makeDecoder()
        let json = #"{"value": 42}"#.data(using: .utf8)!
        struct Dummy: Decodable { let value: Int }
        let result = try? decoder.decode(Dummy.self, from: json)
        #expect(result?.value == 42)
    }

    @Test func customConfigurationAppliesKeyDecodingStrategy() {
        let config = CDYelpDecoderConfiguration(keyDecodingStrategy: .convertFromSnakeCase)
        let decoder = config.makeDecoder()
        let json = #"{"hello_world": "test"}"#.data(using: .utf8)!
        struct Dummy: Decodable { let helloWorld: String }
        let result = try? decoder.decode(Dummy.self, from: json)
        #expect(result?.helloWorld == "test")
    }

    @Test func clientInitializesWithDecoderConfiguration() {
        let config = CDYelpDecoderConfiguration(keyDecodingStrategy: .convertFromSnakeCase)
        let client = CDYelpAPIClient(apiKey: "fake-key-for-test", decoderConfiguration: config)
        #expect(client.isAuthenticated())
    }
}
