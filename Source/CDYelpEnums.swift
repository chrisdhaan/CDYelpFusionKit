//
//  CDYelpEnums.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 7/25/17.
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
//

///
/// A list of the business attributes the Yelp Fusion API supports.
///
public enum CDYelpAttributeFilter: String {
    case hotAndNew              = "hot_and_new"
    case requestAQuote          = "request_a_quote"
    case waitlistReservation    = "waitlist_reservation"
    case cashback               = "cashback"
    case deals                  = "deals"
}

///
/// A list of the business categories the Yelp Fusion API supports.
///
public enum CDYelpCategoryFilter: String {
    // Active Life
    case activeLife             = "active"
    case atvRentals             = "atvrentals"
    case airsoft                = "airsoft"
    case amateurSportsTeams     = "amateursportsteams"
    case amusementParks         = "amusementparks"
    case aquariums              = "aquariums"
    case archery                = "archery"
    case badminton              = "badminton"
    case baseballFields         = "baseballfields"
    case basketballCourts       = "basketballcourts"
    case bathingArea            = "bathing_area"
    case battingCages           = "battingcages"
    case beachEquipmentRentals  = "beachequipmentrental"
    case beachVolleyball        = "beachvolleyball"
    case beaches                = "beaches"
    case bicyclePaths           = "bicyclepaths"
    case bikeParking            = "bikeparking"
    case bikeRentals            = "bikerentals"
    case boating                = "boating"
    case bobSledding            = "bobsledding"
    case bocceBall              = "bocceball"
    case bowling                = "bowling"
    case bubbleSoccer           = "bubblesoccer"
    case bungeeJumping          = "bungeejumping"
    case carousels              = "carousels"
    case challengeCourses       = "challengecourses"
    case climbing               = "climbing"
    case cyclingClasses         = "cyclingclasses"
    case dayCamps               = "daycamps"
    case discGolf               = "discgolf"
    case diving                 = "diving"
    case freeDiving             = "freediving"
    case scubaDiving            = "scuba"
    case escapeGames            = "escapegames"
    case experiences            = "experiences"
    case fencingClubs           = "fencing"
    case fishing                = "fishing"
    case fitnessAndInstruction  = "fitness"
    case aerialFitness          = "aerialfitness"
    case barreClasses           = "barreclasses"
    case bootCamps              = "bootcamps"
    case boxing                 = "boxing"
    case cardioClasses          = "cardioclasses"
    case danceStudios           = "dancestudio"
    case emsTraining            = "emstraining"
    case golfLessons            = "golflessons"
    case gyms                   = "gyms"
    case circuitTrainingGyms    = "circuittraininggyms"
    case intervalTrainingGyms   = "intervaltraininggyms"
    case martialArts            = "martialarts"
    
    // Arts & Entertainment
    case artsAndEntertainment   = "arts"
    
    // Automotive
    case automotive             = "auto"
    
    // Beauty & Spas
    case beautyAndSpas          = "beautysvc"
    
    // Bicycles
    case bicycles               = "bicycles"
    
    // Education
    case education              = "education"
    
    // Event Planning & Services
    case eventPlanningAndServices   = "eventservices"
    
    // Financial Services
    case financialServices      = "financialservices"
    
    case bars                   = "bars"
    
    // Food
    case food                   = "food"
    
    // Health & Medical
    case healthAndMedical       = "health"
    
    // Home Services
    case homeServices           = "homeservices"
    
    // Hotels & Travel
    case hotelsAndTravel        = "hotelstravel"
    
    // Local Flavor
    case localFlavor            = "localflavor"
    
    // Local Services
    case localServices          = "localservices"
    
    // Mass Media
    case massMedia              = "massmedia"
    
    // Nightlife
    case nightlife              = "nightlife"
    
    // Pets
    case pets                   = "pets"
    
    // Professional Services
    case professionalServices   = "professional"
    
    // Public Services & Government
    case publicServicesAndGovernment    = "publicservicesgovt"
    
    // Real Estate
    case realEstate             = "realestate"
    
    // Religious Organizations
    case religiousOrganizations = "religiousorgs"
    
    // Restaurants
    case restaurants            = "restaurants"
    
    // Shopping
    case shopping               = "shopping"
}

///
/// A list of locales the Yelp Fusion API supports. The locale code is in the format of {language code}_{country code}.
///
public enum CDYelpLocale: String {
    case chinese_hongKong           = "zh_HK"
    case chinese_taiwan             = "zh_TW"
    case czech_czechRepublic        = "cs_CZ"
    case danish_denmark             = "da_DK"
    case dutch_belgium              = "nl_BE"
    case dutch_theNetherlands       = "nl_NL"
    case english_australia          = "en_AU"
    case english_belgium            = "en_BE"
    case english_canada             = "en_CA"
    case english_hongKong           = "en_HK"
    case english_malaysia           = "en_MY"
    case english_newZealand         = "en_NZ"
    case english_philippines        = "en_PH"
    case english_republicOfIreland  = "en_IE"
    case english_singapore          = "en_SG"
    case english_switzerland        = "en_CH"
    case english_unitedKingdom      = "en_GB"
    case english_unitedStates       = "en_US"
    case filipino_philippines       = "fil_PH"
    case finnish_finland            = "fi_FI"
    case french_belgium             = "fr_BE"
    case french_canada              = "fr_CA"
    case french_france              = "fr_FR"
    case french_switzerland         = "fr_CH"
    case german_austria             = "de_AT"
    case german_germany             = "de_DE"
    case german_switzerland         = "de_CH"
    case italian_italy              = "it_IT"
    case italian_switzerland        = "it_CH"
    case japanese_japan             = "ja_JP"
    case malay_malaysia             = "ms_MY"
    case norwegian_norway           = "nb_NO"
    case polish_poland              = "pl_PL"
    case portuguese_brazil          = "pt_BR"
    case portuguese_portugal        = "pt_PT"
    case spanish_argentina          = "es_AR"
    case spanish_chile              = "es_CL"
    case spanish_mexico             = "es_MX"
    case spanish_spain              = "es_ES"
    case swedish_finland            = "sv_FI"
    case swedish_sweden             = "sv_SE"
    case turkish_turkey             = "tr_TR"
}

///
/// A list of the price tiers the Yelp Fusion API supports.
///
public enum CDYelpPriceTier: String {
    case oneDollarSign      = "1"
    case twoDollarSigns     = "2"
    case threeDollarSigns   = "3"
    case fourDollarSigns    = "4"
}

///
/// A list of the sort types the Yelp Fusion API supports.
///
public enum CDYelpSortType: String {
    case bestMatch      = "best_match"
    case rating         = "rating"
    case reviewCount    = "review_count"
    case distance       = "distance"
}

///
/// A list of the transaction types the Yelp Fusion API supports. Currently, only food delivery is supported and it is only supported in the U.S.
///
public enum CDYelpTransactionType: String {
    case foodDelivery   = "delivery"
}
