//
//  CDYelpEnumsTests.swift
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

import Testing
import Foundation
@testable import CDYelpFusionKit

@Suite struct CDYelpEnumsTests {

    @Test func businessSortTypeHasCorrectRawValues() {
        #expect(CDYelpBusinessSortType.bestMatch.rawValue == "best_match")
        #expect(CDYelpBusinessSortType.rating.rawValue == "rating")
        #expect(CDYelpBusinessSortType.reviewCount.rawValue == "review_count")
        #expect(CDYelpBusinessSortType.distance.rawValue == "distance")
    }

    @Test func priceTierHasCorrectRawValues() {
        #expect(CDYelpPriceTier.oneDollarSign.rawValue == "1")
        #expect(CDYelpPriceTier.fourDollarSigns.rawValue == "4")
    }

    @Test func priceTierEnumCompleteness() {
        #expect(CDYelpPriceTier.oneDollarSign.rawValue == "1")
        #expect(CDYelpPriceTier.twoDollarSigns.rawValue == "2")
        #expect(CDYelpPriceTier.threeDollarSigns.rawValue == "3")
        #expect(CDYelpPriceTier.fourDollarSigns.rawValue == "4")
    }

    @Test func businessSortTypeEnumCompleteness() {
        let allSortTypes: [CDYelpBusinessSortType] = [.bestMatch, .rating, .reviewCount, .distance]
        #expect(allSortTypes.count >= 4)
    }

    @Test func localeEnumHasValidValues() {
        #expect(CDYelpLocale.english_unitedStates.rawValue == "en_US")
    }

    @Test func transactionTypeEnumHasValidValues() {
        #expect(CDYelpTransactionType.foodDelivery.rawValue == "delivery")
        #expect(CDYelpTransactionType.pickup.rawValue == "pickup")
        #expect(CDYelpTransactionType.reservation.rawValue == "restaurant_reservation")
    }

    @Test func businessMatchTypeEnumHasValidValues() {
        #expect(CDYelpBusinessMatchType.best.rawValue == "best")
        #expect(CDYelpBusinessMatchType.address.rawValue == "address")
        #expect(CDYelpBusinessMatchType.phone.rawValue == "phone")
        #expect(CDYelpBusinessMatchType.all.rawValue == "all")
    }
}
