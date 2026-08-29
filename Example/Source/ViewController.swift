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

    @IBOutlet private var tableView: UITableView!

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
        3
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            19
        case 1:
            6
        case 2:
            3
        default:
            0
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
            "Yelp Fusion API Endpoints"
        case 1:
            "Yelp Fusion Deep Linking"
        case 2:
            "Yelp Fusion Web Linking"
        default:
            ""
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
        0.1
    }
}

// MARK: - Private Helpers

/// Not `private extension`: cellTitle is called from ViewController+EndpointSelection.swift.
extension ViewController {

    func cellTitle(for indexPath: IndexPath) -> String {
        switch indexPath.section {
        case 0:
            apiEndpointCellTitle(forRow: indexPath.row)
        case 1:
            switch indexPath.row {
            case 0: "/"
            case 1: "/search"
            case 2: "/biz"
            case 3: "/check_in/nearby"
            case 4: "/check_ins"
            case 5: "/check_in/rankings"
            default: ""
            }
        case 2:
            switch indexPath.row {
            case 0: "/"
            case 1: "/search"
            case 2: "/biz"
            default: ""
            }
        default:
            ""
        }
    }

    func apiEndpointCellTitle(forRow row: Int) -> String {
        switch row {
        case 0: "/businesses/search"
        case 1: "/businesses/search/phone"
        case 2: "/transactions/{transaction_type}/search"
        case 3: "/businesses/id"
        case 4: "/businesses/matches/{business_match_type}"
        case 5: "/businesses/{id}/reviews"
        case 6: "/autocomplete"
        case 7: "/events/{id}"
        case 8: "/events"
        case 9: "/events/featured"
        case 10: "categories"
        case 11: "/categories/{alias}"
        case 12: "/ai/chat/v2"
        case 13: "/businesses/engagement"
        case 14: "/businesses/{id}/service_offerings"
        case 15: "/businesses/insights"
        case 16: "/businesses/{id}/review_highlights"
        case 17: "/jobs"
        case 18: "/bookings/{id}/openings"
        default: ""
        }
    }
}
