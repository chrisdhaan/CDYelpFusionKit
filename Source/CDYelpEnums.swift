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
    case activeLife                 = "active"
    case atvRentals                 = "atvrentals"
    case airsoft                    = "airsoft"
    case amateurSportsTeams         = "amateursportsteams"
    case amusementParks             = "amusementparks"
    case aquariums                  = "aquariums"
    case archery                    = "archery"
    case badminton                  = "badminton"
    case baseballFields             = "baseballfields"
    case basketballCourts           = "basketballcourts"
    case bathingArea                = "bathing_area"
    case battingCages               = "battingcages"
    case beachEquipmentRentals      = "beachequipmentrental"
    case beachVolleyball            = "beachvolleyball"
    case beaches                    = "beaches"
    case bicyclePaths               = "bicyclepaths"
    case bikeParking                = "bikeparking"
    case bikeRentals                = "bikerentals"
    case boating                    = "boating"
    case bobSledding                = "bobsledding"
    case bocceBall                  = "bocceball"
    case bowling                    = "bowling"
    case bubbleSoccer               = "bubblesoccer"
    case bungeeJumping              = "bungeejumping"
    case carousels                  = "carousels"
    case challengeCourses           = "challengecourses"
    case climbing                   = "climbing"
    case cyclingClasses             = "cyclingclasses"
    case dayCamps                   = "daycamps"
    case discGolf                   = "discgolf"
    case diving                     = "diving"
    case freeDiving                 = "freediving"
    case scubaDiving                = "scuba"
    case escapeGames                = "escapegames"
    case experiences                = "experiences"
    case fencingClubs               = "fencing"
    case fishing                    = "fishing"
    case fitnessAndInstruction      = "fitness"
    case aerialFitness              = "aerialfitness"
    case barreClasses               = "barreclasses"
    case bootCamps                  = "bootcamps"
    case boxing                     = "boxing"
    case cardioClasses              = "cardioclasses"
    case danceStudios               = "dancestudio"
    case emsTraining                = "emstraining"
    case golfLessons                = "golflessons"
    case gyms                       = "gyms"
    case circuitTrainingGyms        = "circuittraininggyms"
    case intervalTrainingGyms       = "intervaltraininggyms"
    case martialArts                = "martialarts"
    case brazilianJiuJitsu          = "brazilianjiujitsu"
    case chineseMartialArts         = "chinesemartialarts"
    case karate                     = "karate"
    case kickboxing                 = "kickboxing"
    case muayThai                   = "muaythai"
    case taekwondo                  = "taekwondo"
    case meditationCenters          = "meditationcenters"
    case pilates                    = "pilates"
    case qiGong                     = "qigong"
    case selfDefenseClasses         = "selfdefenseclasses"
    case taiChi                     = "taichi"
    case trainers                   = "healthtrainers"
    case yoga                       = "yoga"
    case flyboarding                = "flyboarding"
    case gliding                    = "gliding"
    case goKarts                    = "gokarts"
    case golf                       = "golf"
    case gunAndRifleRanges          = "gun_ranges"
    case gymnastics                 = "gymnastics"
    case handball                   = "handball"
    case hangGliding                = "hanggliding"
    case hiking                     = "hiking"
    case horseRacing                = "horseracing"
    case horsebackRiding            = "horsebackriding"
    case hotAirBalloons             = "hot_air_balloons"
    case indoorPlaycentre           = "indoor_playcenter"
    case jetSkis                    = "jetskis"
    case kidsActivities             = "kids_activities"
    case kiteboarding               = "kiteboarding"
    case lakes                      = "lakes"
    case laserTag                   = "lasertag"
    case lawnBowling                = "lawn_bowling"
    case miniGolf                   = "mini_golf"
    case mountainBiking             = "mountainbiking"
    case nudist                     = "nudist"
    case paddleboarding             = "paddleboarding"
    case paintball                  = "paintball"
    case parasailing                = "parasailing"
    case parks                      = "parks"
    case dogParks                   = "dog_parks"
    case skateParks                 = "skate_parks"
    case playgrounds                = "playgrounds"
    case publicPlazas               = "publicplazas"
    case racesAndCompetitions       = "races"
    case racingExperience           = "racingexperience"
    case raftingAndKayaking         = "rafting"
    case recreationCenters          = "recreation"
    case rockClimbing               = "rock_climbing"
    case sailing                    = "sailing"
    case scavengerHunts             = "scavengerhunts"
    case scooterRentals             = "scooterrentals"
    case seniorCenters              = "seniorcenters"
    case skatingRinks               = "skatingrinks"
    case skiing                     = "skiing"
    case skydiving                  = "skydiving"
    case sledding                   = "sledding"
    case snorkeling                 = "snorkeling"
    case soccer                     = "football"
    case sportEquipmentHire         = "sport_equipment_hire"
    case sportsClubs                = "sports_clubs"
    case squash                     = "squash"
    case summerCamps                = "summer_camps"
    case surfLifesaving             = "surflifesaving"
    case surfing                    = "surfing"
    case swimmingPools              = "swimmingpools"
    case tennis                     = "tennis"
    case trampolineParks            = "trampoline"
    case tubing                     = "tubing"
    case volleyball                 = "volleyball"
    case waterParks                 = "waterparks"
    case wildlifeHuntingRanges      = "wildlifehunting"
    case ziplining                  = "zipline"
    case zoos                       = "zoos"
    case pettingZoos                = "pettingzoos"
    case zorbing                    = "zorbing"
    
    // TODO: -
    // Arts & Entertainment
    case artsAndEntertainment   = "arts"
    
    // TODO: -
    // Automotive
    case automotive             = "auto"
    
    // TODO: -
    // Beauty & Spas
    case beautyAndSpas          = "beautysvc"
    case daySpas                = "spas"
    case eroticMassage          = "eroticmassage"
    case massage                = "massage"
    case medicalSpas            = "medicalspa"
    case nailSalons             = "othersalons"
    
    // Bicycles
    case bicycles           = "bicycles"
    case bikeAssocations    = "bikeassociations"
    case bikeRepair         = "bikerepair"
    case bikeShop           = "bikeshop"
    case specialBikes       = "specialbikes"
    
    // Education
    case education                      = "education"
    case adultEducation                 = "adultedu"
    case artClasses                     = "artclasses"
    case collegeCounseling              = "collegecounseling"
    case collegesAndUniversities        = "collegeuniv"
    case educationalServices            = "educationservices"
    case elementarySchools              = "elementaryschools"
    case middleSchoolsAndHighSchools    = "highschools"
    case montessoriSchools              = "montessori"
    case preschools                     = "preschools"
    case privateSchools                 = "privateschools"
    case privateTutors                  = "privatetutors"
    case religiousSchools               = "religiousschools"
    case specialEducation               = "specialed"
    case specialtySchools               = "specialtyschools"
    case artSchools                     = "artschools"
    case bartendingSchools              = "bartendingschools"
    case cprClasses                     = "cprclasses"
    case cheerleading                   = "cheerleading"
    case childbirthEducation            = "childbirthedu"
    case circusSchools                  = "circusschools"
    case cookingSchools                 = "cookingschools"
    case cosmetologySchools             = "cosmetology_schools"
    case duiSchools                     = "duischools"
    case danceSchools                   = "dance_schools"
    case dramaSchools                   = "dramaschools"
    case drivingSchools                 = "driving_schools"
    case firearmTraining                = "firearmtraining"
    case firstAidClasses                = "firstaidclasses"
    case flightInstruction              = "flightinstruction"
    case foodSafetyTraining             = "foodsafety"
    case languageSchools                = "language_schools"
    case massageSchools                 = "massage_schools"
    case nursingSchools                 = "nursingschools"
    case parentingClasses               = "parentingclasses"
    case poleDancingClasses             = "poledancingclasses"
    case sambaSchools                   = "sambaschools"
    case skiSchools                     = "skischools"
    case surfSchools                    = "surfschools"
    case swimmingLessonsAndSchools      = "swimminglessons"
    case trafficSchools                 = "trafficschools"
    case vocationalAndTechnicalSchool   = "vocation"
    case tastingClasses                 = "tastingclasses"
    case cheeseTastingClasses           = "cheesetastingclasses"
    case wineTastingClasses             = "winetasteclasses"
    case testPreparation                = "testprep"
    case tutoringCenters                = "tutoring"
    case waldorfSchools                 = "waldorfschools"
    
    // TODO: -
    // Event Planning & Services
    case eventPlanningAndServices   = "eventservices"
    
    // Financial Services
    case financialServices          = "financialservices"
    case banksAndCreditUnions       = "banks"
    case businessFinancing          = "businessfinancing"
    case checkCashingAndPerDayLoans = "paydayloans"
    case currencyExchange           = "currencyexchange"
    case debtReliefServices         = "debtrelief"
    case financialAdvising          = "financialadvising"
    case installmentLoans           = "installmentloans"
    case insurance                  = "insurance"
    case autoInsurance              = "autoinsurance"
    case homeAndRentalInsurance     = "homeinsurance"
    case lifeInsurance              = "lifeinsurance"
    case investing                  = "investing"
    case mortgageLenders            = "mortgagelenders"
    case taxServices                = "taxservices"
    case titleLoans                 = "titleloans"
    
    // TODO: -
    // Food
    case food                   = "food"
    case foodTrucks             = "foodtrucks"
    case specialtyFood          = "gourmet"
    case streetVendors          = "streetvendors"
    case wineries               = "wineries"
    
    // TODO: -
    // Health & Medical
    case healthAndMedical       = "health"
    case massageTherapy         = "massage_therapy"
    
    // TODO: -
    // Home Services
    case homeServices           = "homeservices"
    
    // TODO: -
    // Hotels & Travel
    case hotelsAndTravel        = "hotelstravel"
    case tours                  = "tours"
    
    // Local Flavor
    case localFlavor            = "localflavor"
    case parklets               = "parklets"
    case publicArt              = "publicart"
    case unofficialYelpEvents   = "unofficialyelpevents"
    case yelpEvents             = "yelpevents"
    
    // TODO: -
    // Local Services
    case localServices          = "localservices"
    
    // Mass Media
    case massMedia          = "massmedia"
    case printMedia         = "printmedia"
    case radioStations      = "radiostations"
    case televisionStations = "televisionstations"
    
    // Nightlife
    case nightlife              = "nightlife"
    case adultEntertainment     = "adultentertainment"
    case barCrawl               = "barcrawl"
    case bars                   = "bars"
    case absintheBars           = "absinthebars"
    case airportLounges         = "airportlounges"
    case beachBars              = "beachbars"
    case beerBar                = "beerbar"
    case champagneBars          = "champagne_bars"
    case cocktailBars           = "cocktailbars"
    case diveBars               = "divebars"
    case driveThruBars          = "drivethrubars"
    case gayBars                = "gaybars"
    case hookahBars             = "hookah_bars"
    case hotelBar               = "hotel_bar"
    case irishPub               = "irish_pubs"
    case lounges                = "lounges"
    case pubs                   = "pubs"
    case pulquerias             = "pulquerias"
    case sakeBars               = "sakebars"
    case speakeasies            = "speakeasies"
    case sportsBars             = "sportsbars"
    case tabac                  = "tabac"
    case tikiBars               = "tikibars"
    case vermouthBars           = "vermouthbars"
    case whiskeyBars            = "whiskeybars"
    case wineBars               = "wine_bars"
    case beerGardens            = "beergardens"
    case clubCrawl              = "clubcrawl"
    case coffeeshops            = "coffeeshops"
    case comedyClubs            = "comedyclubs"
    case countryDanceHalls      = "countrydancehalls"
    case danceClubs             = "danceclubs"
    case danceRestaurants       = "dancerestaurants"
    case fasilMusic             = "fasil"
    case jazzAndBlues           = "jazzandblues"
    case karaoke                = "karaoke"
    case musicVenues            = "musicvenues"
    case pianoBars              = "pianobars"
    case poolHalls              = "poolhalls"
    
    // Pets
    case pets                   = "pets"
    case animalShelters         = "animalshelters"
    case horseBoarding          = "horse_boarding"
    case petAdoption            = "petadoption"
    case petServices            = "petservices"
    case animalPhysicalTherapy  = "animalphysicaltherapy"
    case aquariumServices       = "aquariumservices"
    case dogWalkers             = "dogwalkers"
    case emergencyPetHospital   = "emergencypethospital"
    case farriers               = "farriers"
    case holisticAnimalCare     = "animalholistic"
    case petBoardingAndSitting  = "pet_sitting"
    case petBreeders            = "petbreeders"
    case petCremationServices   = "petcremation"
    case petGroomers            = "groomer"
    case petHospice             = "pethospice"
    case petInsurance           = "petinsurance"
    case petPhotography         = "petphotography"
    case petTraining            = "pet_training"
    case petTransportation      = "pettransport"
    case petStores              = "petstore"
    case birdShops              = "birdshops"
    case localFishStores        = "localfishstores"
    case reptileShops           = "reptileshops"
    case veterinarians          = "vet"
    
    // TODO: -
    // Professional Services
    case professionalServices   = "professional"
    
    // Public Services & Government
    case publicServicesAndGovernment        = "publicservicesgovt"
    case authorizedPostalRepresentative     = "authorized_postal_representative"
    case civicCenter                        = "civiccenter"
    case communityCenters                   = "communitycenters"
    case courthouses                        = "courthouses"
    case departmentsOfMotorVehicles         = "departmentsofmotorvehicles"
    case embassy                            = "embassy"
    case fireDepartments                    = "firedepartments"
    case landmarksAndHistoricalBuildings    = "landmarks"
    case libraries                          = "libraries"
    case municipality                       = "municipality"
    case policeDepartments                  = "policedepartments"
    case postOffices                        = "postoffices"
    case registryOffice                     = "registry_office"
    case taxOffice                          = "taxoffice"
    case townHall                           = "townhall"
    
    // TODO: -
    // Real Estate
    case realEstate             = "realestate"
    
    // Religious Organizations
    case religiousOrganizations = "religiousorgs"
    case afroBrazilian          = "afrobrazilian"
    case buddhistTemples        = "buddhist_temples"
    case churches               = "churches"
    case hinduTemples           = "hindu_temples"
    case mosques                = "mosques"
    case shrines                = "shrines"
    case spiritism              = "spiritism"
    case synagogues             = "synagogues"
    case taoistTemples          = "taoisttemples"
    
    // TODO: -
    // Restaurants
    case restaurants            = "restaurants"
    case cafes                  = "cafes"
    
    // TODO: -
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
