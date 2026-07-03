//
//  CDYelpRouterTests.swift
//  CDYelpFusionKitTests
//
//  Created by Christopher de Haan on 5/24/26.
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

@testable import CDYelpFusionKit
import Foundation
import Testing

struct CDYelpRouterTests {
    @Test func searchRouterProducesGetRequest() throws {
        let router = CDYelpRouter.search(parameters: ["term": "coffee", "location": "San Francisco"])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.httpMethod == "GET")
        #expect(request.url?.host == "api.yelp.com")
    }

    @Test func businessRouterInterpolatesId() throws {
        let router = CDYelpRouter.business(id: "test-id-123", parameters: [:])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("test-id-123") == true)
    }

    @Test func searchRouterIncludesParameters() throws {
        let parameters = ["term": "pizza", "location": "New York", "limit": "10"]
        let router = CDYelpRouter.search(parameters: parameters)
        let request = try router.asURLRequest(apiKey: "test-key")
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("term") == true)
        #expect(urlString.contains("location") == true)
    }

    @Test func businessRouterConstructsCorrectPath() throws {
        let businessId = "gary-danko-san-francisco"
        let router = CDYelpRouter.business(id: businessId, parameters: [:])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains(businessId) == true)
    }

    @Test func routerProducesValidURL() throws {
        let router = CDYelpRouter.search(parameters: ["term": "restaurants"])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.scheme == "https")
        #expect(request.url?.host == "api.yelp.com")
    }

    @Test func routerHandlesEmptyParameters() throws {
        let router = CDYelpRouter.search(parameters: [:])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.httpMethod == "GET")
        #expect(request.url != nil)
    }

    @Test func phoneSearchRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.phone(parameters: ["phone": "+14157492060"])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("businesses/search/phone") == true)
        #expect(request.httpMethod == "GET")
    }

    @Test func transactionRouterInterpolatesType() throws {
        let router = CDYelpRouter.transactions(type: "delivery", parameters: ["location": "San Francisco"])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("transactions/delivery/search") == true)
    }

    @Test func reviewsRouterInterpolatesBusinessId() throws {
        let businessId = "north-india-restaurant"
        let router = CDYelpRouter.reviews(id: businessId, parameters: [:])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("businesses/\(businessId)/reviews") == true)
    }

    @Test func matchesRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.matches(parameters: ["name": "Gary Danko", "city": "San Francisco"])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("businesses/matches") == true)
    }

    @Test func autocompleteRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.autocomplete(parameters: ["text": "Pizza"])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("autocomplete") == true)
    }

    @Test func eventRouterInterpolatesEventId() throws {
        let eventId = "san-francisco-yelp-elite-week"
        let router = CDYelpRouter.event(id: eventId, parameters: [:])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("events/\(eventId)") == true)
    }

    @Test func eventsRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.events(parameters: ["location": "San Francisco"])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("/events") == true)
        #expect(!(request.url?.path.contains("/events/") ?? false))
    }

    @Test func featuredEventRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.featuredEvent(parameters: ["location": "San Francisco"])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("events/featured") == true)
    }

    @Test func allCategoriesRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.allCategories(parameters: ["locale": "en_US"])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("categories") == true)
    }

    @Test func categoryDetailsRouterInterpolatesAlias() throws {
        let alias = "fastfood"
        let router = CDYelpRouter.categoryDetails(alias: alias, parameters: [:])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("categories/\(alias)") == true)
    }

    @Test func aiChatRouterProducesPostRequest() throws {
        let chatRequest = CDYelpAIChatRequest(query: "Best tacos near me")
        let router = CDYelpRouter.aiChat(request: chatRequest)
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.httpMethod == "POST")
        #expect(request.url?.scheme == "https")
        #expect(request.url?.host == "api.yelp.com")
        #expect(request.url?.path == "/ai/chat/v2")
    }

    @Test func aiChatRouterDoesNotUseV3BasePath() throws {
        let chatRequest = CDYelpAIChatRequest(query: "sushi")
        let router = CDYelpRouter.aiChat(request: chatRequest)
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("/v3/") == false)
    }

    @Test func aiChatRouterEncodesBody() throws {
        let chatRequest = CDYelpAIChatRequest(query: "Best pizza", chatId: "abc123")
        let router = CDYelpRouter.aiChat(request: chatRequest)
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.httpBody != nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test func engagementRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.engagement(parameters: ["business_ids": "abc,def"])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("businesses/engagement") == true)
        #expect(request.httpMethod == "GET")
    }

    @Test func serviceOfferingsRouterInterpolatesId() throws {
        let businessId = "gary-danko-sf"
        let router = CDYelpRouter.serviceOfferings(id: businessId, parameters: [:])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("businesses/\(businessId)/service_offerings") == true)
        #expect(request.httpMethod == "GET")
    }

    @Test func businessInsightsRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.businessInsights(parameters: ["business_ids": "abc"])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("businesses/insights") == true)
        #expect(request.httpMethod == "GET")
    }

    @Test func reviewHighlightsRouterInterpolatesId() throws {
        let businessId = "the-house-sf"
        let router = CDYelpRouter.reviewHighlights(id: businessId, parameters: [:])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("businesses/\(businessId)/review_highlights") == true)
        #expect(request.httpMethod == "GET")
    }

    @Test func jobsRouterProducesPostRequest() throws {
        let router = CDYelpRouter.jobs(query: "plumber", locale: nil)
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.httpMethod == "POST")
        #expect(request.url?.path.contains("jobs") == true)
        #expect(request.httpBody != nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test func openingsRouterInterpolatesBusinessId() throws {
        let businessId = "trattoria-contadina-sf"
        let router = CDYelpRouter.openings(businessId: businessId, parameters: [:])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains("bookings/\(businessId)/openings") == true)
        #expect(request.httpMethod == "GET")
    }

    @Test func allRoutersUseHttpsScheme() throws {
        let chatRequest = CDYelpAIChatRequest(query: "test")
        let routers: [CDYelpRouter] = [
            .search(parameters: [:]),
            .phone(parameters: [:]),
            .transactions(type: "delivery", parameters: [:]),
            .business(id: "test", parameters: [:]),
            .matches(parameters: [:]),
            .reviews(id: "test", parameters: [:]),
            .autocomplete(parameters: [:]),
            .event(id: "test", parameters: [:]),
            .events(parameters: [:]),
            .featuredEvent(parameters: [:]),
            .allCategories(parameters: [:]),
            .categoryDetails(alias: "test", parameters: [:]),
            .aiChat(request: chatRequest),
            .engagement(parameters: [:]),
            .serviceOfferings(id: "test", parameters: [:]),
            .businessInsights(parameters: [:]),
            .reviewHighlights(id: "test", parameters: [:]),
            .jobs(query: "plumber", locale: nil),
            .openings(businessId: "test", parameters: [:]),
        ]

        for router in routers {
            let request = try router.asURLRequest(apiKey: "test-key")
            #expect(request.url?.scheme == "https")
        }
    }

    @Test func allGetRoutersUseGetMethod() throws {
        let routers: [CDYelpRouter] = [
            .search(parameters: [:]),
            .phone(parameters: [:]),
            .transactions(type: "delivery", parameters: [:]),
            .business(id: "test", parameters: [:]),
            .matches(parameters: [:]),
            .reviews(id: "test", parameters: [:]),
            .autocomplete(parameters: [:]),
            .event(id: "test", parameters: [:]),
            .events(parameters: [:]),
            .featuredEvent(parameters: [:]),
            .allCategories(parameters: [:]),
            .categoryDetails(alias: "test", parameters: [:]),
            .engagement(parameters: [:]),
            .serviceOfferings(id: "test", parameters: [:]),
            .businessInsights(parameters: [:]),
            .reviewHighlights(id: "test", parameters: [:]),
            .openings(businessId: "test", parameters: [:]),
        ]

        for router in routers {
            let request = try router.asURLRequest(apiKey: "test-key")
            #expect(request.httpMethod == "GET")
        }
    }

    @Test func postRoutersUsePostMethod() throws {
        let chatRequest = CDYelpAIChatRequest(query: "test")
        let routers: [CDYelpRouter] = [
            .aiChat(request: chatRequest),
            .jobs(query: "plumber", locale: nil),
        ]

        for router in routers {
            let request = try router.asURLRequest(apiKey: "test-key")
            #expect(request.httpMethod == "POST")
        }
    }

    @Test func routerHandlesSpecialCharactersInId() throws {
        let businessId = "the-sentinel-san-francisco"
        let router = CDYelpRouter.business(id: businessId, parameters: [:])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.path.contains(businessId) == true)
    }

    @Test func routerHandlesMultipleParameters() throws {
        let parameters = [
            "term": "coffee",
            "location": "San Francisco",
            "limit": "20",
            "offset": "0",
            "sort_by": "rating",
        ]
        let router = CDYelpRouter.search(parameters: parameters)
        let request = try router.asURLRequest(apiKey: "test-key")
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("term") == true)
        #expect(urlString.contains("location") == true)
        #expect(urlString.contains("limit") == true)
    }

    @Test func phoneRouterIncludesPhoneParameter() throws {
        let parameters = ["phone": "+14157492060"]
        let router = CDYelpRouter.phone(parameters: parameters)
        let request = try router.asURLRequest(apiKey: "test-key")
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("phone") == true)
    }

    @Test func reviewsRouterIncludesLocaleParameter() throws {
        let parameters = ["locale": "en_US"]
        let router = CDYelpRouter.reviews(id: "business123", parameters: parameters)
        let request = try router.asURLRequest(apiKey: "test-key")
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("locale") == true)
    }

    @Test func routerPathsDoNotContainQueryStrings() throws {
        let router = CDYelpRouter.search(parameters: ["term": "coffee"])
        let request = try router.asURLRequest(apiKey: "test-key")
        let path = request.url?.path ?? ""
        #expect(!path.contains("?"))
    }

    @Test func authorizationHeaderContainsBearerToken() throws {
        let apiKey = "test-bearer-key"
        let router = CDYelpRouter.search(parameters: ["location": "San Francisco"])
        let request = try router.asURLRequest(apiKey: apiKey)
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer \(apiKey)")
    }

    @Test func phoneNumberPlusSignIsPercentEncoded() throws {
        // + in query strings is decoded as a space by most servers (application/x-www-form-urlencoded
        // convention). E.164 numbers start with + so this must be encoded as %2B.
        let router = CDYelpRouter.phone(parameters: ["phone": "+14157492060"])
        let request = try router.asURLRequest(apiKey: "test-key")
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("%2B14157492060"))
        #expect(!urlString.contains("phone=+14157492060"))
    }

    @Test func idContainingQueryDelimiterIsPercentEncodedNotInjected() throws {
        // A raw "?" in a path-embedded id must not be reinterpreted as the start of a query
        // string when `path` is concatenated with the base URL and re-parsed by URLComponents.
        // `URL.path` auto-decodes percent-encoding, so assert on the raw encoded representation
        // and on `.query` being empty rather than on the (correctly decoded) `.path` string.
        let maliciousId = "abc?evil=1"
        let router = CDYelpRouter.business(id: maliciousId, parameters: [:])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.query == nil)
        #expect(request.url?.absoluteString.contains("abc%3Fevil%3D1") == true)
        #expect(request.url?.path == "/v3/businesses/abc?evil=1")
    }

    @Test func idContainingFragmentDelimiterIsPercentEncoded() throws {
        let maliciousId = "abc#fragment"
        let router = CDYelpRouter.reviews(id: maliciousId, parameters: [:])
        let request = try router.asURLRequest(apiKey: "test-key")
        #expect(request.url?.fragment == nil)
        #expect(request.url?.absoluteString.contains("abc%23fragment") == true)
    }

    @Test func booleanQueryParameterEncodesNumerically() throws {
        // Matches the Yelp Fusion API convention (and the encoding this library has always sent,
        // previously via Alamofire's default URLEncoding, whose boolEncoding is .numeric).
        let router = CDYelpRouter.search(parameters: ["open_now": true])
        let request = try router.asURLRequest(apiKey: "test-key")
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("open_now=1"))
        #expect(!urlString.contains("open_now=true"))
    }
}
