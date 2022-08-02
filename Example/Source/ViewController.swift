//
//  ViewController.swift
//  iOS Example
//
//  Created by Christopher de Haan on 11/06/2016.
//
//  Copyright © 2016-2022 Christopher de Haan <contact@christopherdehaan.me>
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func openUrl(_ url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url,
                                      options: [:],
                                      completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
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
            return 12
        case 1:
            return 6
        case 2:
            return 3
        default:
            return 0
        }
    }

    // swiftlint:disable function_body_length
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CDYelpEndpointCell",
                                                 for: indexPath)

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "/businesses/search"
            case 1:
                cell.textLabel?.text = "/businesses/search/phone"
            case 2:
                cell.textLabel?.text = "/transactions/{transaction_type}/search"
            case 3:
                cell.textLabel?.text = "/businesses/id"
            case 4:
                cell.textLabel?.text = "/businesses/matches/{business_match_type}"
            case 5:
                cell.textLabel?.text = "/businesses/{id}/reviews"
            case 6:
                cell.textLabel?.text = "/autocomplete"
            case 7:
                cell.textLabel?.text = "/events/{id}"
            case 8:
                cell.textLabel?.text = "/events"
            case 9:
                cell.textLabel?.text = "/events/featured"
            case 10:
                cell.textLabel?.text = "categories"
            case 11:
                cell.textLabel?.text = "/categories/{alias}"
            default:
                cell.textLabel?.text = ""
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "/"
            case 1:
                cell.textLabel?.text = "/search"
            case 2:
                cell.textLabel?.text = "/biz"
            case 3:
                cell.textLabel?.text = "/check_in/nearby"
            case 4:
                cell.textLabel?.text = "/check_ins"
            case 5:
                cell.textLabel?.text = "/check_in/rankings"
            default:
                cell.textLabel?.text = ""
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "/"
            case 1:
                cell.textLabel?.text = "/search"
            case 2:
                cell.textLabel?.text = "/biz"
            default:
                cell.textLabel?.text = ""
            }
        default:
            cell.backgroundColor = UIColor.clear
            cell.imageView?.image = nil
            cell.textLabel?.text = ""
            cell.textLabel?.textColor = UIColor.black
        }

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
    // swiftlint:enable function_body_length

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

    // swiftlint:disable function_body_length
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case 0:
            CDYelpFusionKitManager.shared.apiClient.cancelAllPendingAPIRequests()
            switch indexPath.row {
            case 0:
                CDYelpFusionKitManager.shared.apiClient.searchBusinesses(byTerm: "Food",
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
                                                                         attributes: nil) { (response) in
                    if let response = response,
                       let businesses = response.businesses,
                       businesses.count > 0 {
                        print(businesses)
                    }
                }
            case 1:
                CDYelpFusionKitManager.shared.apiClient.searchBusinesses(byPhoneNumber: "+14157492060") { (response) in

                    if let response = response,
                        let businesses = response.businesses,
                        businesses.count > 0 {
                        print(businesses)
                    }
                }
            case 2:
                CDYelpFusionKitManager.shared.apiClient.searchTransactions(byType: .foodDelivery,
                                                                           location: "San Francisco",
                                                                           latitude: nil,
                                                                           longitude: nil) { (response) in
                    if let response = response,
                       let businesses = response.businesses,
                       businesses.count > 0 {
                        print(businesses)
                    }
                }
            case 3:
                CDYelpFusionKitManager.shared.apiClient.fetchBusiness(forId: "north-india-restaurant-san-francisco",
                                                                      locale: nil) { (response) in
                    if let response = response,
                       let business = response.business {
                        print(business)
                    }
                }
            case 4:
                CDYelpFusionKitManager.shared.apiClient.searchBusinesses(name: "Gary Danko",
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
                                                                         matchThresholdType: .normal) { (response) in
                    if let response = response,
                       let businesses = response.businesses,
                       businesses.count > 0 {
                        print(businesses)
                    }
                }
            case 5:
                CDYelpFusionKitManager.shared.apiClient.fetchReviews(forBusinessId: "north-india-restaurant-san-francisco",
                                                                     locale: nil) { (response) in
                    if let response = response,
                       let reviews = response.reviews,
                       reviews.count > 0 {
                        print(reviews)
                    }
                }
            case 6:
                CDYelpFusionKitManager.shared.apiClient.autocompleteBusinesses(byText: "Pizza Delivery",
                                                                               latitude: 37.786572,
                                                                               longitude: -122.415192,
                                                                               locale: nil) { (response) in
                    if let response = response {
                        if let businesses = response.businesses,
                           businesses.count > 0 {
                            print(businesses)
                        }
                        if let categories = response.categories,
                           categories.count > 0 {
                            print(categories)
                        }
                        if let terms = response.terms,
                           terms.count > 0 {
                            print(terms)
                        }
                    }
                }
            case 7:
                CDYelpFusionKitManager.shared.apiClient.fetchEvent(forId: "san-francisco-yelp-elite-week-renew-and-rejuvenate-with-redmint",
                                                                   locale: nil) { (response) in
                    if let response = response,
                       let event = response.event {
                        print(event)
                    }
                }
            case 8:
                CDYelpFusionKitManager.shared.apiClient.searchEvents(byLocale: nil,
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
                                                                     excludedEvents: nil) { (response) in
                    if let response = response,
                       let events = response.events,
                       events.count > 0 {
                        print(events)
                    }
                }
            case 9:
                CDYelpFusionKitManager.shared.apiClient.fetchFeaturedEvent(forLocale: nil,
                                                                           location: nil,
                                                                           latitude: 37.786572,
                                                                           longitude: -122.415192) { (response) in
                    if let response = response,
                       let event = response.event {
                        print(event)
                    }
                }
            case 10:
                CDYelpFusionKitManager.shared.apiClient.fetchCategories(forLocale: nil) { (response) in

                    if let response = response,
                        let categories = response.categories {
                        print(categories)
                    }
                }
            case 11:
                CDYelpFusionKitManager.shared.apiClient.fetchCategory(forAlias: .fastFood,
                                                                      andLocale: nil) { (response) in
                    if let response = response,
                       let category = response.category {
                        print(category)
                    }
                }
            default:
                break
            }
        case 1:
            switch indexPath.row {
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
        case 2:
            switch indexPath.row {
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
        default:
            break
        }
    }
    // swiftlint:enable function_body_length

    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
