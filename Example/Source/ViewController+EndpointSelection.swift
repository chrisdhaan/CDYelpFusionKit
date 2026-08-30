//
//  ViewController+EndpointSelection.swift
//  iOS Example
//
//  Created by Christopher de Haan on 8/29/26.
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

import UIKit

/// Not `private extension`: handleAPIEndpointSelection/handleDeepLinkSelection/handleWebLinkSelection
/// are called from ViewController.swift's UITableViewDelegate extension.
extension ViewController {

    /// Shared Task/do-catch/present boilerplate for every row below: runs `call`, then routes the
    /// result to `presentJSONResponse` or a thrown error to `presentError`.
    func performEndpointCall(at row: Int, _ call: @Sendable @escaping () async throws -> some Sendable) {
        Task {
            do {
                let response = try await call()
                presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
            } catch {
                presentError(error)
            }
        }
    }

    func handleAPIEndpointSelection(at row: Int) {
        switch row {
        case 0 ... 2:
            handleBusinessSearchSelection(at: row)
        case 3 ... 6:
            handleBusinessLookupSelection(at: row)
        case 7 ... 9:
            handleEventEndpointSelection(at: row)
        case 10 ... 11:
            handleCategoryEndpointSelection(at: row)
        case 12 ... 15:
            handleAIAndBusinessDataSelection(at: row)
        case 16 ... 18:
            handleReviewAndReservationSelection(at: row)
        default:
            break
        }
    }

    func handleBusinessSearchSelection(at row: Int) {
        switch row {
        case 0:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.searchBusinesses(byTerm: "Food",
                                                                                   location: "San Francisco",
                                                                                   latitude: nil,
                                                                                   longitude: nil,
                                                                                   radius: 10000,
                                                                                   categories: nil,
                                                                                   locale: .english_unitedStates,
                                                                                   limit: 5,
                                                                                   offset: 0,
                                                                                   sortBy: .rating,
                                                                                   priceTiers: nil,
                                                                                   openNow: true,
                                                                                   openAt: nil,
                                                                                   attributes: nil)
            }
        case 1:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.searchBusinesses(byPhoneNumber: "+14157492060")
            }
        case 2:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.searchTransactions(byType: .foodDelivery,
                                                                                     location: "San Francisco",
                                                                                     latitude: nil,
                                                                                     longitude: nil)
            }
        default:
            break
        }
    }

    func handleBusinessLookupSelection(at row: Int) {
        switch row {
        case 3:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchBusiness(forId: "north-india-restaurant-san-francisco",
                                                                                locale: nil)
            }
        case 4:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.searchBusinesses(name: "Gary Danko",
                                                                                   addressOne: "800 N Point St",
                                                                                   addressTwo: nil,
                                                                                   addressThree: nil,
                                                                                   city: "San Francisco",
                                                                                   state: "CA",
                                                                                   country: "US",
                                                                                   latitude: nil,
                                                                                   longitude: nil,
                                                                                   phone: nil,
                                                                                   zipCode: nil,
                                                                                   yelpBusinessId: nil,
                                                                                   limit: 5,
                                                                                   matchThresholdType: .normal)
            }
        case 5:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchReviews(forBusinessId: "north-india-restaurant-san-francisco",
                                                                               locale: nil)
            }
        case 6:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.autocompleteBusinesses(byText: "Pizza Delivery",
                                                                                         latitude: 37.786572,
                                                                                         longitude: -122.415192,
                                                                                         locale: nil)
            }
        default:
            break
        }
    }

    func handleEventEndpointSelection(at row: Int) {
        switch row {
        case 7:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchEvent(
                    forId: "san-francisco-yelp-elite-week-renew-and-rejuvenate-with-redmint",
                    locale: nil
                )
            }
        case 8:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.searchEvents(byLocale: nil,
                                                                               offset: nil,
                                                                               limit: 5,
                                                                               sortBy: .descending,
                                                                               sortOn: .popularity,
                                                                               startDate: nil,
                                                                               endDate: nil,
                                                                               categories: [.music, .foodAndDrink],
                                                                               isFree: false,
                                                                               location: nil,
                                                                               latitude: 37.786572,
                                                                               longitude: -122.415192,
                                                                               radius: 10000,
                                                                               excludedEvents: nil)
            }
        case 9:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchFeaturedEvent(forLocale: nil,
                                                                                     location: nil,
                                                                                     latitude: 37.786572,
                                                                                     longitude: -122.415192)
            }
        default:
            break
        }
    }

    func handleCategoryEndpointSelection(at row: Int) {
        switch row {
        case 10:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchCategories(forLocale: nil)
            }
        case 11:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchCategory(forAlias: .fastFood,
                                                                                andLocale: nil)
            }
        default:
            break
        }
    }

    func handleAIAndBusinessDataSelection(at row: Int) {
        switch row {
        case 12:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchAIChat(query: "What are the best pizza places in San Francisco?",
                                                                              chatId: nil,
                                                                              latitude: 37.786572,
                                                                              longitude: -122.415192,
                                                                              requestContext: nil)
            }
        case 13:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchEngagementMetrics(forBusinessIds: ["north-india-restaurant-san-francisco"],
                                                                                         dateRangeStart: nil,
                                                                                         dateRangeEnd: nil)
            }
        case 14:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchServiceOfferings(forBusinessId: "north-india-restaurant-san-francisco",
                                                                                        locale: nil)
            }
        case 15:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchBusinessInsights(forBusinessIds: ["north-india-restaurant-san-francisco"],
                                                                                        dateRangeStart: "202401",
                                                                                        dateRangeEnd: "202412")
            }
        default:
            break
        }
    }

    func handleReviewAndReservationSelection(at row: Int) {
        switch row {
        case 16:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchReviewHighlights(forBusinessId: "north-india-restaurant-san-francisco",
                                                                                        count: 3,
                                                                                        locale: nil,
                                                                                        devicePlatform: nil)
            }
        case 17:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchJobs(forQuery: "Plumber", locale: nil)
            }
        case 18:
            performEndpointCall(at: row) {
                try await CDYelpFusionKitManager.shared.apiClient.fetchOpenings(forBusinessId: "north-india-restaurant-san-francisco",
                                                                                covers: 2,
                                                                                date: "2026-09-01",
                                                                                time: "19:00",
                                                                                getCoversRange: nil)
            }
        default:
            break
        }
    }

    func presentJSONResponse(_ response: Sendable, title: String) {
        let jsonText = JSONPrettyPrinter.string(from: response)
        let jsonResponseViewController = CDYelpJSONResponseViewController(title: title, jsonText: jsonText)
        navigationController?.pushViewController(jsonResponseViewController, animated: true)
    }

    func presentError(_ error: Error) {
        let alertController = UIAlertController(title: "Request Failed", message: "\(error)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func handleDeepLinkSelection(at row: Int) {
        switch row {
        case 0:
            if let url = URL.yelpDeepLink(),
               UIApplication.shared.canOpenURL(url) {
                self.openUrl(url)
            }
        case 1:
            if let url = URL.yelpSearchDeepLink(withTerm: "burrito",
                                                category: .food,
                                                location: "San Francisco, CA"),
                UIApplication.shared.canOpenURL(url) {
                self.openUrl(url)
            }
        case 2:
            if let url = URL.yelpBusinessDeepLink(forId: "the-sentinel-san-francisco"),
               UIApplication.shared.canOpenURL(url) {
                self.openUrl(url)
            }
        case 3:
            if let url = URL.yelpCheckInNearbyDeepLink(),
               UIApplication.shared.canOpenURL(url) {
                self.openUrl(url)
            }
        case 4:
            if let url = URL.yelpCheckInsDeepLink(),
               UIApplication.shared.canOpenURL(url) {
                self.openUrl(url)
            }
        case 5:
            if let url = URL.yelpCheckInRankingsDeepLink(),
               UIApplication.shared.canOpenURL(url) {
                self.openUrl(url)
            }
        default:
            break
        }
    }

    func handleWebLinkSelection(at row: Int) {
        switch row {
        case 0:
            if let url = URL.yelpWebLink(),
               UIApplication.shared.canOpenURL(url) {
                self.openUrl(url)
            }
        case 1:
            if let url = URL.yelpSearchWebLink(withTerm: "burrito",
                                               category: .food,
                                               location: "San Francisco, CA"),
                UIApplication.shared.canOpenURL(url) {
                self.openUrl(url)
            }
        case 2:
            if let url = URL.yelpBusinessWebLink(forId: "the-sentinel-san-francisco"),
               UIApplication.shared.canOpenURL(url) {
                self.openUrl(url)
            }
        default:
            break
        }
    }
}
