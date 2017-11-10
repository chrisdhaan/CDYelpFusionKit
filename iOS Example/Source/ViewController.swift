//
//  ViewController.swift
//  iOS Example
//
//  Created by Christopher de Haan on 11/06/2016.
//
//  Copyright (c) 2016-2017 Christopher de Haan <contact@christopherdehaan.me>
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableViewDataSource Methods

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 10
        case 1:
            return 6
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CDYelpEndpointCell", for: indexPath)
        
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
                cell.textLabel?.text = "/check_ins"
            case 4:
                cell.textLabel?.text = "/check_in/nearby"
            case 5:
                cell.textLabel?.text = "/check_in/rankings"
            default:
                cell.textLabel?.text = ""
            }
        default:
            cell.textLabel?.text = ""
            cell.imageView?.image = UIImage.yelpBurstLogoWhite()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Yelp Fusion API Endpoints"
        case 1:
            return "Yelp Fusion Deep Linking"
        default:
            return ""
        }
    }
}

// MARK: - UITableView Delegate Methods

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                                                                      locale: nil) { (business) in
                                                                        
                                                                        if let business = business {
                                                                            print(business)
                                                                        }
                }
            case 4:
                CDYelpFusionKitManager.shared.apiClient.searchBusinesses(byMatchType: .best,
                                                                         name: "Yelp if you need HELP!",
                                                                         addressOne: nil,
                                                                         addressTwo: nil,
                                                                         addressThree: nil,
                                                                         city: "San Francisco",
                                                                         state: "CA",
                                                                         country: "US",
                                                                         latitude: nil,
                                                                         longitude: nil,
                                                                         phone: nil,
                                                                         postalCode: nil,
                                                                         yelpBusinessId: nil) { (response) in
                                                                            
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
                CDYelpFusionKitManager.shared.apiClient.autocompleteBusinesses(byText: "Pizza Hut",
                                                                               latitude: 37.786572,
                                                                               longitude: -122.415192,
                                                                               locale: nil) { (response) in
                                                                                
                                                                                if let response = response,
                                                                                    let businesses = response.businesses,
                                                                                    businesses.count > 0 {
                                                                                    print(businesses)
                                                                                }
                }
            case 7:
                CDYelpFusionKitManager.shared.apiClient.fetchEvent(forId: "city-of-san-francisco-san-francisco",
                                                                   locale: nil) { (event) in
                                                                    
                                                                    if let event = event {
                                                                        print(event)
                                                                    }
                }
            case 8:
                CDYelpFusionKitManager.shared.apiClient.searchEvents(byLocale: nil,
                                                                     offset: nil,
                                                                     limit: 5,
                                                                     sortBy: .descending,
                                                                     sortOn: .popularity,
                                                                     categories: [.music, .foodAndDrink],
                                                                     startDate: nil,
                                                                     endDate: nil,
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
                                                                           longitude: -122.415192) { (event) in
                                                                            
                                                                            if let event = event {
                                                                                print(event)
                                                                            }
                }
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                CDYelpFusionKitManager.shared.deepLink.openYelp()
            case 1:
                CDYelpFusionKitManager.shared.deepLink.openYelpToSearch(withTerm: "burrito", category: .food, location: "San Francisco, CA")
            case 2:
                CDYelpFusionKitManager.shared.deepLink.openYelpToBusiness(withid: "the-sentinel-san-francisco")
            case 3:
                CDYelpFusionKitManager.shared.deepLink.openYelpToCheckIns()
            case 4:
                CDYelpFusionKitManager.shared.deepLink.openYelpToNearbyCheckIns()
            case 5:
                CDYelpFusionKitManager.shared.deepLink.openYelpToRankedCheckIns()
            default:
                break
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
