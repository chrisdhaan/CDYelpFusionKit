@testable import CDYelpFusionKit
import Foundation
import Testing

struct CDYelpAPIClientTests {
    @Test func searchBusinessesReturnsDecodedResponse() async throws {
        let fixture = try FixtureLoader.data(named: "search_response.json")
        CDYelpMockURLProtocol.register(
            stub: .init(data: fixture, statusCode: 200),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeAllStubs() }

        let client = CDYelpMockClientFactory.makeClient()
        let response = try await client.searchBusinesses(
            byTerm: "coffee",
            location: "San Francisco",
            latitude: nil, longitude: nil, radius: nil,
            categories: nil, locale: nil, limit: nil, offset: nil,
            sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
            attributes: nil
        )
        #expect(response.businesses?.isEmpty == false)
    }

    @Test func searchBusinessesReturns404AsError() async {
        CDYelpMockURLProtocol.register(
            stub: .init(data: Data(), statusCode: 404),
            forURLContaining: "businesses/search"
        )
        defer { CDYelpMockURLProtocol.removeAllStubs() }

        let client = CDYelpMockClientFactory.makeClient()
        await #expect(throws: Error.self) {
            _ = try await client.searchBusinesses(
                byTerm: "coffee", location: "SF",
                latitude: nil, longitude: nil, radius: nil,
                categories: nil, locale: nil, limit: nil, offset: nil,
                sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil,
                attributes: nil
            )
        }
    }
}
