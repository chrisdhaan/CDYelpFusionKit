import CDYelpFusionKitTesting
import Foundation
import Testing

// Use a URL pattern that does not overlap with CDYelpAPIClientTests to avoid
// cross-suite static-stub collisions when suites run concurrently.
private let kTestKey = "mock-protocol-unit-test/"
private let kTestURL = URL(string: "https://mock.yelp.test/\(kTestKey)resource")!

@Suite(.serialized)
struct CDYelpMockURLProtocolTests {
    // MARK: - canInit

    @Test func canInitReturnsTrueWhenURLMatchesRegisteredStub() {
        CDYelpMockURLProtocol.register(stub: .init(data: Data(), statusCode: 200), forURLContaining: kTestKey)
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: kTestKey) }

        let request = URLRequest(url: kTestURL)
        #expect(CDYelpMockURLProtocol.canInit(with: request) == true)
    }

    @Test func canInitReturnsFalseWhenURLDoesNotMatchAnyStub() {
        CDYelpMockURLProtocol.register(stub: .init(data: Data(), statusCode: 200), forURLContaining: kTestKey)
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: kTestKey) }

        let other = URLRequest(url: URL(string: "https://mock.yelp.test/completely-unrelated/path")!)
        #expect(CDYelpMockURLProtocol.canInit(with: other) == false)
    }

    @Test func canInitReturnsFalseAfterRemoveStub() {
        CDYelpMockURLProtocol.register(stub: .init(data: Data(), statusCode: 200), forURLContaining: kTestKey)
        CDYelpMockURLProtocol.removeStub(forURLContaining: kTestKey)

        let request = URLRequest(url: kTestURL)
        #expect(CDYelpMockURLProtocol.canInit(with: request) == false)
    }

    // MARK: - Stub delivery

    @Test func stubDeliversExpectedStatusCodeAndData() async throws {
        let body = """
        {"businesses":[],"total":0}
        """.data(using: .utf8)!

        CDYelpMockURLProtocol.register(stub: .init(data: body, statusCode: 200), forURLContaining: kTestKey)
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: kTestKey) }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [CDYelpMockURLProtocol.self]
        let session = URLSession(configuration: config)

        let (data, response) = try await session.data(from: kTestURL)
        #expect((response as? HTTPURLResponse)?.statusCode == 200)
        #expect(data == body)
    }

    @Test func stubDeliversCustomStatusCode() async throws {
        CDYelpMockURLProtocol.register(stub: .init(data: Data(), statusCode: 429), forURLContaining: kTestKey)
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: kTestKey) }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [CDYelpMockURLProtocol.self]
        let session = URLSession(configuration: config)

        let (_, response) = try await session.data(from: kTestURL)
        #expect((response as? HTTPURLResponse)?.statusCode == 429)
    }

    @Test func stubDeliversCustomResponseHeaders() async throws {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 200, headers: ["X-Test-Header": "hello"]),
            forURLContaining: kTestKey
        )
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: kTestKey) }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [CDYelpMockURLProtocol.self]
        let session = URLSession(configuration: config)

        let (_, response) = try await session.data(from: kTestURL)
        #expect((response as? HTTPURLResponse)?.value(forHTTPHeaderField: "X-Test-Header") == "hello")
    }

    @Test func mostRecentlyRegisteredStubForKeyWins() async throws {
        let first = "first".data(using: .utf8)!
        let second = "second".data(using: .utf8)!
        CDYelpMockURLProtocol.register(stub: .init(data: first, statusCode: 200), forURLContaining: kTestKey)
        CDYelpMockURLProtocol.register(stub: .init(data: second, statusCode: 200), forURLContaining: kTestKey)
        defer { CDYelpMockURLProtocol.removeStub(forURLContaining: kTestKey) }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [CDYelpMockURLProtocol.self]
        let session = URLSession(configuration: config)

        let (data, _) = try await session.data(from: kTestURL)
        #expect(data == second)
    }
}
