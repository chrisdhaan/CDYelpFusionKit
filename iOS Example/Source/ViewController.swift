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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CDYelpEndpointCell", for: indexPath)
        
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
        default:
            cell.textLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Yelp Fusion API Endpoints"
        default:
            return ""
        }
    }
}

// MARK: - UITableView Delegate Methods

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            CDYelpFusionKitManager.shared.apiClient.fetchBusiness(byId: "north-india-restaurant-san-francisco",
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
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}
