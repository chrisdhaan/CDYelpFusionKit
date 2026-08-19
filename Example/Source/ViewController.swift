//
//  ViewController.swift
//  iOS Example
//
//  Created by Christopher de Haan on 11/06/2016.
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

class ViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let logoImageView = UIImageView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: self.tableView.frame.size.width,
                                                      height: 50))
        logoImageView.image = UIImage.yelpLogo()
        logoImageView.contentMode = .scaleAspectFit
        self.tableView.tableHeaderView = logoImageView

        let logoOutlineImageView = UIImageView(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: self.tableView.frame.size.width,
                                                             height: 50))
        logoOutlineImageView.image = UIImage.yelpStars(numberOfStars: .twoHalf,
                                                       forSize: .large)
        logoOutlineImageView.contentMode = .center
        self.tableView.tableFooterView = logoOutlineImageView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hidden here (rather than always-hidden on the navigation controller) so the bar still
        // animates back in for the pushed JSON response screen and back out when returning here.
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func openUrl(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

// MARK: - UITableViewDataSource Methods

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 19
        case 1:
            return 6
        case 2:
            return 3
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CDYelpEndpointCell",
                                                 for: indexPath)

        cell.textLabel?.text = cellTitle(for: indexPath)

        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.white
            cell.imageView?.image = UIImage.yelpBurstLogoRed()
            cell.textLabel?.textColor = UIColor.yelpFiveStarRed()
        } else {
            cell.backgroundColor = UIColor.yelpFiveStarRed()
            cell.imageView?.image = UIImage.yelpBurstLogoWhite()
            cell.textLabel?.textColor = UIColor.white
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Yelp Fusion API Endpoints"
        case 1:
            return "Yelp Fusion Deep Linking"
        case 2:
            return "Yelp Fusion Web Linking"
        default:
            return ""
        }
    }
}

// MARK: - UITableView Delegate Methods

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            Task {
                // Await full cancellation before starting the new request so it can't be
                // swept up by the in-flight cancellation of the previous selection.
                await CDYelpFusionKitManager.shared.apiClient.cancelAllPendingAPIRequests()
                handleAPIEndpointSelection(at: indexPath.row)
            }
        case 1:
            handleDeepLinkSelection(at: indexPath.row)
        case 2:
            handleWebLinkSelection(at: indexPath.row)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

// MARK: - Private Helpers

private extension ViewController {

    func cellTitle(for indexPath: IndexPath) -> String {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: return "/businesses/search"
            case 1: return "/businesses/search/phone"
            case 2: return "/transactions/{transaction_type}/search"
            case 3: return "/businesses/id"
            case 4: return "/businesses/matches/{business_match_type}"
            case 5: return "/businesses/{id}/reviews"
            case 6: return "/autocomplete"
            case 7: return "/events/{id}"
            case 8: return "/events"
            case 9: return "/events/featured"
            case 10: return "categories"
            case 11: return "/categories/{alias}"
            case 12: return "/ai/chat/v2"
            case 13: return "/businesses/engagement"
            case 14: return "/businesses/{id}/service_offerings"
            case 15: return "/businesses/insights"
            case 16: return "/businesses/{id}/review_highlights"
            case 17: return "/jobs"
            case 18: return "/bookings/{id}/openings"
            default: return ""
            }
        case 1:
            switch indexPath.row {
            case 0: return "/"
            case 1: return "/search"
            case 2: return "/biz"
            case 3: return "/check_in/nearby"
            case 4: return "/check_ins"
            case 5: return "/check_in/rankings"
            default: return ""
            }
        case 2:
            switch indexPath.row {
            case 0: return "/"
            case 1: return "/search"
            case 2: return "/biz"
            default: return ""
            }
        default:
            return ""
        }
    }
}

// MARK: - Private Selection Handlers

private extension ViewController {

    // swiftlint:disable function_body_length
    func handleAPIEndpointSelection(at row: Int) {
        switch row {
        case 0:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.searchBusinesses(byTerm: "Food",
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
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 1:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.searchBusinesses(byPhoneNumber: "+14157492060")
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 2:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.searchTransactions(byType: .foodDelivery,
                                                                                                         location: "San Francisco",
                                                                                                         latitude: nil,
                                                                                                         longitude: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 3:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchBusiness(forId: "north-india-restaurant-san-francisco",
                                                                                                   locale: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 4:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.searchBusinesses(name: "Gary Danko",
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
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 5:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchReviews(forBusinessId: "north-india-restaurant-san-francisco",
                                                                                                  locale: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 6:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.autocompleteBusinesses(byText: "Pizza Delivery",
                                                                                                            latitude: 37.786572,
                                                                                                            longitude: -122.415192,
                                                                                                            locale: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 7:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchEvent(forId: "san-francisco-yelp-elite-week-renew-and-rejuvenate-with-redmint",
                                                                                                locale: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 8:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.searchEvents(byLocale: nil,
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
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 9:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchFeaturedEvent(forLocale: nil,
                                                                                                        location: nil,
                                                                                                        latitude: 37.786572,
                                                                                                        longitude: -122.415192)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 10:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchCategories(forLocale: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 11:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchCategory(forAlias: .fastFood,
                                                                                                   andLocale: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 12:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchAIChat(query: "What are the best pizza places in San Francisco?",
                                                                                                  chatId: nil,
                                                                                                  latitude: 37.786572,
                                                                                                  longitude: -122.415192,
                                                                                                  requestContext: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 13:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchEngagementMetrics(forBusinessIds: ["north-india-restaurant-san-francisco"],
                                                                                                             dateRangeStart: nil,
                                                                                                             dateRangeEnd: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 14:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchServiceOfferings(forBusinessId: "north-india-restaurant-san-francisco",
                                                                                                            locale: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 15:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchBusinessInsights(forBusinessIds: ["north-india-restaurant-san-francisco"],
                                                                                                            dateRangeStart: "202401",
                                                                                                            dateRangeEnd: "202412")
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 16:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchReviewHighlights(forBusinessId: "north-india-restaurant-san-francisco",
                                                                                                            count: 3,
                                                                                                            locale: nil,
                                                                                                            devicePlatform: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 17:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchJobs(forQuery: "Plumber", locale: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        case 18:
            Task {
                do {
                    let response = try await CDYelpFusionKitManager.shared.apiClient.fetchOpenings(forBusinessId: "north-india-restaurant-san-francisco",
                                                                                                    covers: 2,
                                                                                                    date: "2026-09-01",
                                                                                                    time: "19:00",
                                                                                                    getCoversRange: nil)
                    presentJSONResponse(response, title: cellTitle(for: IndexPath(row: row, section: 0)))
                } catch {
                    presentError(error)
                }
            }
        default:
            break
        }
    }
    // swiftlint:enable function_body_length

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
