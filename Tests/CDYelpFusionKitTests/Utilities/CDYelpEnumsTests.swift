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

@testable import CDYelpFusionKit
import Foundation
import Testing

struct CDYelpEnumsTests {
    // MARK: - Business Sort Type Tests

    @Test func businessSortTypeHasCorrectRawValues() {
        #expect(CDYelpBusinessSortType.bestMatch.rawValue == "best_match")
        #expect(CDYelpBusinessSortType.rating.rawValue == "rating")
        #expect(CDYelpBusinessSortType.reviewCount.rawValue == "review_count")
        #expect(CDYelpBusinessSortType.distance.rawValue == "distance")
    }

    @Test func businessSortTypeEnumCompleteness() {
        let allSortTypes: [CDYelpBusinessSortType] = [.bestMatch, .rating, .reviewCount, .distance]
        #expect(allSortTypes.count >= 4)
    }

    // MARK: - Price Tier Tests

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

    // MARK: - Locale Tests

    @Test func localeEnumHasValidUSValue() {
        #expect(CDYelpLocale.english_unitedStates.rawValue == "en_US")
    }

    @Test func localeEnumHasValidInternationalValues() {
        #expect(CDYelpLocale.english_canada.rawValue == "en_CA")
        #expect(CDYelpLocale.english_unitedKingdom.rawValue == "en_GB")
        #expect(CDYelpLocale.french_france.rawValue == "fr_FR")
        #expect(CDYelpLocale.german_germany.rawValue == "de_DE")
        #expect(CDYelpLocale.spanish_spain.rawValue == "es_ES")
        #expect(CDYelpLocale.japanese_japan.rawValue == "ja_JP")
    }

    // MARK: - Transaction Type Tests

    @Test func transactionTypeEnumHasValidValues() {
        #expect(CDYelpTransactionType.foodDelivery.rawValue == "delivery")
    }

    // MARK: - Business Match Threshold Type Tests

    @Test func businessMatchThresholdTypeHasCorrectRawValues() {
        #expect(CDYelpBusinessMatchThresholdType.normal.rawValue == "default")
        #expect(CDYelpBusinessMatchThresholdType.strict.rawValue == "strict")
    }

    @Test func businessMatchThresholdTypeHandlesNone() {
        #expect(CDYelpBusinessMatchThresholdType.none.rawValue == "none")
    }

    // MARK: - Event Category Filter Tests

    @Test func eventCategoryFilterHasValidValues() {
        #expect(CDYelpEventCategoryFilter.charities.rawValue == "charities")
        #expect(CDYelpEventCategoryFilter.music.rawValue == "music")
        #expect(CDYelpEventCategoryFilter.foodAndDrink.rawValue == "food-and-drink")
    }

    @Test func eventCategoryFilterIncludesMultipleCategories() {
        let categories: [CDYelpEventCategoryFilter] = [
            .charities, .fashion, .festivalsAndFairs, .film,
            .foodAndDrink, .kidsAndFamily, .lecturesAndBooks, .music,
            .nightlife, .other, .performingArts, .sportsAndActiveLife,
            .visualArts,
        ]
        #expect(categories.count >= 13)
    }

    // MARK: - Event Sort Tests

    @Test func eventSortByTypeHasCorrectRawValues() {
        #expect(CDYelpEventSortByType.ascending.rawValue == "asc")
        #expect(CDYelpEventSortByType.descending.rawValue == "desc")
    }

    @Test func eventSortOnTypeHasCorrectRawValues() {
        #expect(CDYelpEventSortOnType.popularity.rawValue == "popularity")
        #expect(CDYelpEventSortOnType.timeStart.rawValue == "time_start")
    }

    // MARK: - Stars Tests

    @Test func starsEnumIncludesHalfValues() {
        #expect(CDYelpStars.oneHalf.rawValue == "one_half")
        #expect(CDYelpStars.twoHalf.rawValue == "two_half")
        #expect(CDYelpStars.threeHalf.rawValue == "three_half")
        #expect(CDYelpStars.fourHalf.rawValue == "four_half")
    }

    @Test func starsEnumIncludesFullValues() {
        #expect(CDYelpStars.one.rawValue == "one")
        #expect(CDYelpStars.two.rawValue == "two")
        #expect(CDYelpStars.three.rawValue == "three")
        #expect(CDYelpStars.four.rawValue == "four")
        #expect(CDYelpStars.five.rawValue == "five")
    }

    @Test func starsEnumIncludesZero() {
        #expect(CDYelpStars.zero.rawValue == "zero")
    }

    // MARK: - Stars Size Tests

    @Test func starsSizeEnumHasAllSizes() {
        #expect(CDYelpStarsSize.small.rawValue == "small")
        #expect(CDYelpStarsSize.regular.rawValue == "regular")
        #expect(CDYelpStarsSize.large.rawValue == "large")
        #expect(CDYelpStarsSize.extraLarge.rawValue == "extra_large")
    }

    // MARK: - Attribute Filter Tests

    @Test func attributeFilterHasValidValues() {
        #expect(CDYelpAttributeFilter.hotAndNew.rawValue == "hot_and_new")
        #expect(CDYelpAttributeFilter.reservation.rawValue == "reservation")
        #expect(CDYelpAttributeFilter.deals.rawValue == "deals")
    }

    @Test func attributeFilterIncludesAccessibility() {
        #expect(CDYelpAttributeFilter.genderNeutralRestrooms.rawValue == "gender_neutral_restrooms")
        #expect(CDYelpAttributeFilter.wheelchairAccessible.rawValue == "wheelchair_accessible")
    }

    // MARK: - Category Alias Tests

    @Test func categoryAliasHasCommonFoodCategories() {
        #expect(CDYelpCategoryAlias.food.rawValue == "food")
        #expect(CDYelpCategoryAlias.restaurants.rawValue == "restaurants")
        #expect(CDYelpCategoryAlias.coffeeAndTea.rawValue == "coffee")
    }

    @Test func categoryAliasHasActiveLifeCategories() {
        #expect(CDYelpCategoryAlias.activeLife.rawValue == "active")
        #expect(CDYelpCategoryAlias.gyms.rawValue == "gyms")
    }

    @Test func categoryAliasUsesCamelCase() {
        #expect(CDYelpCategoryAlias.atvRentalsAndTours.rawValue == "atvrentals")
        #expect(CDYelpCategoryAlias.basketballCourts.rawValue == "basketballcourts")
    }
}
