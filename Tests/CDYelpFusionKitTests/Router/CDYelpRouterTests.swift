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
        let request = try router.asURLRequest()
        #expect(request.httpMethod == "GET")
        #expect(request.url?.host == "api.yelp.com")
    }

    @Test func businessRouterInterpolatesId() throws {
        let router = CDYelpRouter.business(id: "test-id-123", parameters: [:])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("test-id-123") == true)
    }

    @Test func searchRouterIncludesParameters() throws {
        let parameters = ["term": "pizza", "location": "New York", "limit": "10"]
        let router = CDYelpRouter.search(parameters: parameters)
        let request = try router.asURLRequest()
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("term") == true)
        #expect(urlString.contains("location") == true)
    }

    @Test func businessRouterConstructsCorrectPath() throws {
        let businessId = "gary-danko-san-francisco"
        let router = CDYelpRouter.business(id: businessId, parameters: [:])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains(businessId) == true)
    }

    @Test func routerProducesValidURL() throws {
        let router = CDYelpRouter.search(parameters: ["term": "restaurants"])
        let request = try router.asURLRequest()
        #expect(request.url?.scheme == "https")
        #expect(request.url?.host == "api.yelp.com")
    }

    @Test func routerHandlesEmptyParameters() throws {
        let router = CDYelpRouter.search(parameters: [:])
        let request = try router.asURLRequest()
        #expect(request.httpMethod == "GET")
        #expect(request.url != nil)
    }

    @Test func phoneSearchRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.phone(parameters: ["phone": "+14157492060"])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("businesses/search/phone") == true)
        #expect(request.httpMethod == "GET")
    }

    @Test func transactionRouterInterpolatesType() throws {
        let router = CDYelpRouter.transactions(type: "delivery", parameters: ["location": "San Francisco"])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("transactions/delivery/search") == true)
    }

    @Test func reviewsRouterInterpolatesBusinessId() throws {
        let businessId = "north-india-restaurant"
        let router = CDYelpRouter.reviews(id: businessId, parameters: [:])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("businesses/\(businessId)/reviews") == true)
    }

    @Test func matchesRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.matches(parameters: ["name": "Gary Danko", "city": "San Francisco"])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("businesses/matches") == true)
    }

    @Test func autocompleteRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.autocomplete(parameters: ["text": "Pizza"])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("autocomplete") == true)
    }

    @Test func eventRouterInterpolatesEventId() throws {
        let eventId = "san-francisco-yelp-elite-week"
        let router = CDYelpRouter.event(id: eventId, parameters: [:])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("events/\(eventId)") == true)
    }

    @Test func eventsRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.events(parameters: ["location": "San Francisco"])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("/events") == true)
        #expect(!request.url?.path.contains("/events/") ?? false)
    }

    @Test func featuredEventRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.featuredEvent(parameters: ["location": "San Francisco"])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("events/featured") == true)
    }

    @Test func allCategoriesRouterProducesCorrectPath() throws {
        let router = CDYelpRouter.allCategories(parameters: ["locale": "en_US"])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("categories") == true)
    }

    @Test func categoryDetailsRouterInterpolatesAlias() throws {
        let alias = "fastfood"
        let router = CDYelpRouter.categoryDetails(alias: alias, parameters: [:])
        let request = try router.asURLRequest()
        #expect(request.url?.path.contains("categories/\(alias)") == true)
    }

    @Test func allRoutersUseHttpsScheme() throws {
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
        ]

        for router in routers {
            let request = try router.asURLRequest()
            #expect(request.url?.scheme == "https")
        }
    }

    @Test func allRoutersUseGetMethod() throws {
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
        ]

        for router in routers {
            let request = try router.asURLRequest()
            #expect(request.httpMethod == "GET")
        }
    }

    @Test func routerHandlesSpecialCharactersInId() throws {
        let businessId = "the-sentinel-san-francisco"
        let router = CDYelpRouter.business(id: businessId, parameters: [:])
        let request = try router.asURLRequest()
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
        let request = try router.asURLRequest()
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("term") == true)
        #expect(urlString.contains("location") == true)
        #expect(urlString.contains("limit") == true)
    }

    @Test func phoneRouterIncludesPhoneParameter() throws {
        let parameters = ["phone": "+14157492060"]
        let router = CDYelpRouter.phone(parameters: parameters)
        let request = try router.asURLRequest()
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("phone") == true)
    }

    @Test func reviewsRouterIncludesLocaleParameter() throws {
        let parameters = ["locale": "en_US"]
        let router = CDYelpRouter.reviews(id: "business123", parameters: parameters)
        let request = try router.asURLRequest()
        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("locale") == true)
    }

    @Test func routerPathsDoNotContainQueryStrings() throws {
        let router = CDYelpRouter.search(parameters: ["term": "coffee"])
        let request = try router.asURLRequest()
        let path = request.url?.path ?? ""
        #expect(!path.contains("?") ?? false)
    }
}
