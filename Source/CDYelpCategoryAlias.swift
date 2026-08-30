//
//  CDYelpCategoryAlias.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 7/25/17.
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

// swiftlint:disable file_length type_body_length
// Swift enums can't split their cases across files or extensions (unlike classes,
// structs, or actors). This enum is a complete 1-to-1 mapping of Yelp's real
// category taxonomy (1,481 cases as of writing) — every case corresponds to an
// actual Yelp Fusion API category alias, so reducing the case count would mean
// dropping real, supported categories rather than simplifying anything.
///
/// A list of the business categories the Yelp Fusion API supports.
///
public enum CDYelpCategoryAlias: String, Sendable {
    // Active Life
    case activeLife = "active"
    case atvRentalsAndTours = "atvrentals"
    case airsoft
    case amateurSportsTeams = "amateursportsteams"
    case amusementParks = "amusementparks"
    case aquariums
    case archery
    case badminton
    case baseballFields = "baseballfields"
    case basketballCourts = "basketballcourts"
    case bathingArea = "bathing_area"
    case battingCages = "battingcages"
    case beachEquipmentRentals = "beachequipmentrental"
    case beachVolleyball = "beachvolleyball"
    case beaches
    case bicyclePaths = "bicyclepaths"
    case bikeParking = "bikeparking"
    case bikeRentals = "bikerentals"
    case boating
    case bobSledding = "bobsledding"
    case bocceBall = "bocceball"
    case bowling
    case bubbleSoccer = "bubblesoccer"
    case bungeeJumping = "bungeejumping"
    case carousels
    case challengeCourses = "challengecourses"
    case climbing
    case cyclingClasses = "cyclingclasses"
    case dayCamps = "daycamps"
    case discGolf = "discgolf"
    case diving
    case freeDiving = "freediving"
    case scubaDiving = "scuba"
    case escapeGames = "escapegames"
    case experiences
    case fencingClubs = "fencing"
    case fishing
    case fitnessAndInstruction = "fitness"
    case aerialFitness = "aerialfitness"
    case barreClasses = "barreclasses"
    case bootCamps = "bootcamps"
    case boxing
    case cardioClasses = "cardioclasses"
    case danceStudios = "dancestudio"
    case emsTraining = "emstraining"
    case golfLessons = "golflessons"
    case gyms
    case circuitTrainingGyms = "circuittraininggyms"
    case intervalTrainingGyms = "intervaltraininggyms"
    case martialArts = "martialarts"
    case brazilianJiuJitsu = "brazilianjiujitsu"
    case chineseMartialArts = "chinesemartialarts"
    case karate
    case kickboxing
    case muayThai = "muaythai"
    case taekwondo
    case meditationCenters = "meditationcenters"
    case pilates
    case qiGong = "qigong"
    case selfDefenseClasses = "selfdefenseclasses"
    case taiChi = "taichi"
    case trainers = "healthtrainers"
    case yoga
    case flyboarding
    case gliding
    case goKarts = "gokarts"
    case golf
    case gunAndRifleRanges = "gun_ranges"
    case gymnastics
    case handball
    case hangGliding = "hanggliding"
    case hiking
    case horseRacing = "horseracing"
    case horsebackRiding = "horsebackriding"
    case hotAirBalloons = "hot_air_balloons"
    case indoorPlaycentre = "indoor_playcenter"
    case jetSkis = "jetskis"
    case kidsActivities = "kids_activities"
    case kiteboarding
    case lakes
    case laserTag = "lasertag"
    case lawnBowling = "lawn_bowling"
    case miniGolf = "mini_golf"
    case mountainBiking = "mountainbiking"
    case nudist
    case paddleboarding
    case paintball
    case parasailing
    case parks
    case dogParks = "dog_parks"
    case skateParks = "skate_parks"
    case playgrounds
    case publicPlazas = "publicplazas"
    case racesAndCompetitions = "races"
    case racingExperience = "racingexperience"
    case raftingAndKayaking = "rafting"
    case recreationCenters = "recreation"
    case rockClimbing = "rock_climbing"
    case sailing
    case scavengerHunts = "scavengerhunts"
    case scooterRentals = "scooterrentals"
    case seniorCenters = "seniorcenters"
    case skatingRinks = "skatingrinks"
    case skiing
    case skydiving
    case sledding
    case snorkeling
    case soccer = "football"
    case sportEquipmentHire = "sport_equipment_hire"
    case sportsClubs = "sports_clubs"
    case squash
    case summerCamps = "summer_camps"
    case surfLifesaving = "surflifesaving"
    case surfing
    case swimmingPools = "swimmingpools"
    case tennis
    case trampolineParks = "trampoline"
    case tubing
    case volleyball
    case waterParks = "waterparks"
    case wildlifeHuntingRanges = "wildlifehunting"
    case ziplining = "zipline"
    case zoos
    case pettingZoos = "pettingzoos"
    case zorbing

    // Arts & Entertainment
    case artsAndEntertainment = "arts"
    case arcades
    case artGalleries = "galleries"
    case bettingCenters = "bettingcenters"
    case bingoHalls = "bingo"
    case botanicalGardens = "gardens"
    case cabaret
    case casinos
    case castles
    case choirs
    case cinema = "movietheaters"
    case driveInTheater = "driveintheater"
    case outdoorMovies = "outdoormovies"
    case countryClubs = "countryclubs"
    case culturalCenter = "culturalcenter"
    case farms
    case attractionFarms = "attractionfarms"
    case pickYourOwnFarms = "pickyourown"
    case ranches
    case festivals
    case christmasMarkets = "xmasmarkets"
    case funFair = "funfair"
    case generalFestivals = "generalfestivals"
    case tradeFairs = "tradefairs"
    case hauntedHouses = "hauntedhouses"
    case jazzAndBlues = "jazzandblues"
    case lanCenters = "lancenters"
    case mahJongHalls = "mahjong"
    case marchingBands = "marchingbands"
    case museums
    case artMuseums = "artmuseums"
    case childrensMuseums = "childrensmuseums"
    case observatories
    case operaAndBallet = "opera"
    case pachinko
    case paintAndSip = "paintandsip"
    case performingArts = "theater"
    case planetarium
    case professionalSportsTeams = "sportsteams"
    case psychicsAndAstrologers = "psychic_astrology"
    case psychicMediums = "psychicmediums"
    case raceTracks = "racetracks"
    case rodeo
    case socialClubs = "social_clubs"
    case veteransOrganizations = "veteransorganizations"
    case stadiumsAndArenas = "stadiumsarenas"
    case streetArt = "streetart"
    case studioTaping = "studiotaping"
    case tablaoFlamenco = "tablaoflamenco"
    case ticketSales = "ticketsales"
    case wineTastingRoom = "winetastingroom"

    // Automotive
    case automotive = "auto"
    case aircraftDealers = "aircraftdealers"
    case aircraftRepairs = "aircraftrepairs"
    case autoCustomization = "autocustomization"
    case autoDetailing = "auto_detailing"
    case autoElectricServices = "autoelectric"
    case autoGlassServices = "autoglass"
    case carWindowTinting = "carwindowtinting"
    case autoLoanProviders = "autoloanproviders"
    case autoPartsAndSupplies = "autopartssupplies"
    case autoRepair = "autorepair"
    case diyAutoShop = "diyautoshop"
    case autoSecurity = "autosecurity"
    case autoUpholstery = "autoupholstery"
    case boatDealers = "boatdealers"
    case bodyShops = "bodyshops"
    case carAuctions = "carauctions"
    case carBrokers = "carbrokers"
    case carBuyers = "carbuyers"
    case carDealers = "car_dealers"
    case carInspectors = "autodamageassessment"
    case carShareServices = "carshares"
    case carStereoInstallation = "stereo_installation"
    case carWash = "carwash"
    case commercialTruckDealers = "truckdealers"
    case commercialTruckRepair = "truckrepair"
    case evChargingStations = "evchargingstations"
    case fuelDocks = "fueldocks"
    case gasStations = "servicestations"
    case hybridCarRepair = "hybridcarrepair"
    case interlockSystems = "interlocksystems"
    case marinas
    case mobileDentRepair = "mobiledentrepair"
    case mobilityEquipmentSalesAndServices = "mobilityequipment"
    case motorcycleDealers = "motorcycledealers"
    case motorcycleRepair = "motorcyclerepair"
    case motorsportVehicleDealers = "motodealers"
    case motorsportVehicleRepairs = "motorepairs"
    case oilChangeStations = "oilchange"
    case parking
    case rvDealers = "rv_dealers"
    case rvRepair = "rvrepair"
    case registrationServices = "registrationservices"
    case roadsideAssistance = "roadsideassist"
    case serviceStations = "service_stations"
    case smogCheckStations = "smog_check_stations"
    case tires
    case towing
    case trailerDealers = "trailerdealers"
    case trailerRental = "trailerrental"
    case trailerRepair = "trailerrepair"
    case transmissionRepair = "transmissionrepair"
    case truckRental = "truck_rental"
    case usedCarDealers = "usedcardealers"
    case vehicleShipping = "vehicleshipping"
    case vehicleWraps = "vehiclewraps"
    case wheelAndRimRepair = "wheelrimrepair"
    case windshieldInstallationAndRepair = "windshieldinstallrepair"

    // Beauty & Spas
    case beautyAndSpas = "beautysvc"
    case acneTreatment = "acnetreatment"
    case barbers
    case cosmeticsAndBeautySupply = "cosmetics"
    case daySpas = "spas"
    case eroticMassage = "eroticmassage"
    case eyebrowServices = "eyebrowservices"
    case eyelashService = "eyelashservice"
    case hairExtensions = "hair_extensions"
    case hairLossCenters = "hairloss"
    case hairRemoval = "hairremoval"
    case laserHairRemoval = "laser_hair_removal"
    case sugaring
    case threadingServices = "threadingservices"
    case waxing
    case hairSalons = "hair"
    case blowDryOutServices = "blowoutservices"
    case hairStylists = "hairstylists"
    case mensHairSalons = "menshair"
    case hotSprings = "hotsprings"
    case makeupArtists = "makeupartists"
    case massage
    case nailSalons = "othersalons"
    case nailTechnicians = "nailtechnicians"
    case perfume
    case permanentMakeup = "permanentmakeup"
    case piercing
    case rolfing
    case skinCare = "skincare"
    case tanning
    case sprayTanning = "spraytanning"
    case tanningBeds = "tanningbeds"
    case tattoo
    case teethWhitening = "teethwhitening"

    // Bicycles
    case bicycles
    case bikeAssocations = "bikeassociations"
    case bikeRepair = "bikerepair"
    case bikeShop = "bikeshop"
    case specialBikes = "specialbikes"

    // Education
    case education
    case adultEducation = "adultedu"
    case artClasses = "artclasses"
    case collegeCounseling = "collegecounseling"
    case collegesAndUniversities = "collegeuniv"
    case educationalServices = "educationservices"
    case elementarySchools = "elementaryschools"
    case middleSchoolsAndHighSchools = "highschools"
    case montessoriSchools = "montessori"
    case preschools
    case privateSchools = "privateschools"
    case privateTutors = "privatetutors"
    case religiousSchools = "religiousschools"
    case specialEducation = "specialed"
    case specialtySchools = "specialtyschools"
    case artSchools = "artschools"
    case bartendingSchools = "bartendingschools"
    case cprClasses = "cprclasses"
    case cheerleading
    case childbirthEducation = "childbirthedu"
    case circusSchools = "circusschools"
    case cookingSchools = "cookingschools"
    case cosmetologySchools = "cosmetology_schools"
    case duiSchools = "duischools"
    case danceSchools = "dance_schools"
    case dramaSchools = "dramaschools"
    case drivingSchools = "driving_schools"
    case firearmTraining = "firearmtraining"
    case firstAidClasses = "firstaidclasses"
    case flightInstruction = "flightinstruction"
    case foodSafetyTraining = "foodsafety"
    case languageSchools = "language_schools"
    case massageSchools = "massage_schools"
    case nursingSchools = "nursingschools"
    case parentingClasses = "parentingclasses"
    case poleDancingClasses = "poledancingclasses"
    case sambaSchools = "sambaschools"
    case skiSchools = "skischools"
    case surfSchools = "surfschools"
    case swimmingLessonsAndSchools = "swimminglessons"
    case trafficSchools = "trafficschools"
    case vocationalAndTechnicalSchool = "vocation"
    case tastingClasses = "tastingclasses"
    case cheeseTastingClasses = "cheesetastingclasses"
    case wineTastingClasses = "winetasteclasses"
    case testPreparation = "testprep"
    case tutoringCenters = "tutoring"
    case waldorfSchools = "waldorfschools"

    // Event Planning & Services
    case eventPlanningAndServices = "eventservices"
    case bartenders
    case boatCharters = "boatcharters"
    case caricatures
    case caterers = "catering"
    case clowns
    case djs
    case facePainting = "facepainting"
    case gameTruckRental = "gametruckrental"
    case golfCartRentals = "golfcartrentals"
    case hennaArtists = "hennaartists"
    case magicians
    case mohels
    case musicians
    case officiants
    case partyAndEventPlanning = "eventplanning"
    case partyBikeRentals = "partybikerentals"
    case partyBusRentals = "partybusrentals"
    case partyCharacters = "partycharacters"
    case partyEquipmentRentals = "partyequipmentrentals"
    case bounceHouseRentals = "bouncehouserentals"
    case partySupplies = "partysupplies"
    case personalChefs = "personalchefs"
    case photoBoothRentals = "photoboothrentals"
    case photographers
    case boudoirPhotography = "boudoirphotography"
    case eventPhotography = "eventphotography"
    case sessionPhotography = "sessionphotography"
    case silentDisco = "silentdisco"
    case sommelierServices = "sommelierservices"
    case teamBuildingActivities = "teambuilding"
    case triviaHosts = "triviahosts"
    case valetServices = "valetservices"
    case venuesAndEventSpaces = "venues"
    case videographers
    case weddingChapels = "weddingchappels"
    case weddingPlanning = "wedding_planning"

    // Financial Services
    case financialServices = "financialservices"
    case banksAndCreditUnions = "banks"
    case businessFinancing = "businessfinancing"
    case checkCashingAndPerDayLoans = "paydayloans"
    case currencyExchange = "currencyexchange"
    case debtReliefServices = "debtrelief"
    case financialAdvising = "financialadvising"
    case installmentLoans = "installmentloans"
    case insurance
    case autoInsurance = "autoinsurance"
    case homeAndRentalInsurance = "homeinsurance"
    case lifeInsurance = "lifeinsurance"
    case investing
    case mortgageLenders = "mortgagelenders"
    case taxServices = "taxservices"
    case titleLoans = "titleloans"

    // Food
    case food
    case acaiBowls = "acaibowls"
    case backshop
    case bagels
    case bakeries
    case beerWineAndSpirits = "beer_and_wine"
    case bento
    case beverageStore = "beverage_stores"
    case breweries
    case bubbleTea = "bubbletea"
    case butcher
    case csa
    case chimneyCakes = "chimneycakes"
    case churros
    case cideries
    case coffeeAndTea = "coffee"
    case coffeeAndTeaSupplies = "coffeeteasupplies"
    case coffeeRoasteries = "coffeeroasteries"
    case convenienceStores = "convenience"
    case cupcakes
    case customCakes = "customcakes"
    case delicatessen
    case desserts
    case distilleries
    case doItYourselfFood = "diyfood"
    case donairs
    case donuts
    case empanadas
    case ethicGrocery = "ethicgrocery"
    case farmersMarket = "farmersmarket"
    case fishmonger
    case foodDeliveryServices = "fooddeliveryservices"
    case foodTrucks = "foodtrucks"
    case friterie
    case gelato
    case grocery
    case hawkerCentre = "hawkercentre"
    case honey
    case iceCreamAndFrozenYogurt = "icecream"
    case importedFood = "importedfood"
    case internationalGrocery = "intlgrocery"
    case internetCafes = "internetcafe"
    case japaneseSweets = "jpsweets"
    case taiyaki
    case juiceBarsAndSmoothies = "juicebars"
    case kombucha
    case milkshakeBars = "milkshakebars"
    case mulledWine = "gluhwein"
    case nasiLemak = "nasilemak"
    case organicStores = "organic_stores"
    case panzerotti
    case patisserieAndCakeShop = "cakeshop"
    case piadina
    case poke
    case pretzels
    case salumerie
    case shavedIce = "shavedice"
    case shavedSnow = "shavedsnow"
    case smokehouse
    case specialtyFood = "gourmet"
    case candyStores = "candy"
    case cheeseShops = "cheese"
    case chocolatiersAndShops = "chocolate"
    case dagashi
    case driedFruit = "driedfruit"
    case frozenFood = "frozenfood"
    case fruitsAndVeggies = "markets"
    case healthMarkets = "healthmarkets"
    case herbsAndSpices = "herbsandspices"
    case macarons
    case meatShops = "meats"
    case oliveOil = "oliveoil"
    case pastaShops = "pastashops"
    case popcornShops = "popcorn"
    case seafoodMarkets = "seafoodmarkets"
    case tofuShops = "tofu"
    case streetVendors = "streetvendors"
    case sugarShacks = "sugarshacks"
    case teaRooms = "tea"
    case torshi
    case tortillas
    case waterStores = "waterstores"
    case wineries
    case zapiekanka

    // Health & Medical
    case healthAndMedical = "health"
    case acupuncture
    case animalAssistedTherapy = "animalassistedtherapy"
    case assistedLivingFacilities = "assistedliving"
    case ayurveda
    case behaviorAnalysts = "behavioranalysts"
    case bloodAndPlasmaDonationCenters = "blooddonation"
    case cannabisClinics = "cannabis_clinics"
    case cannabisTours = "cannabistours"
    case cannabisCollective = "cannabiscollective"
    case chiropractors
    case colonics
    case conciergeMedicine = "conciergemedicine"
    case counselingAndMentalHealth = "c_and_mh"
    case psychoanalysts
    case psychologists
    case psychotherapists
    case sexTherapists = "sextherapists"
    case sophrologists
    case sportsPsychologists = "sportspsychologists"
    case cryotherapy
    case dentalHygienists = "dentalhygienists"
    case mobileClinics = "dentalhygienistsmobile"
    case storefrontClinics = "dentalhygeiniststorefront"
    case dentists
    case cosmeticDentists = "cosmeticdentists"
    case endodontists
    case generalDentistry = "generaldentistry"
    case oralSurgeons = "oralsurgeons"
    case orthodontists
    case pediatricDentists = "pediatric_dentists"
    case periodontists
    case diagnosticServices = "diagnosticservices"
    case diagnosticImaging = "diagnosticimaging"
    case laboratoryTesting = "laboratorytesting"
    case dialysisClinics = "dialysisclinics"
    case dietitians
    case doctors = "physicians"
    case addictionMedicine = "addictionmedicine"
    case allergists = "allergist"
    case anesthesiologists
    case audiologist
    case cardiologists = "cardiology"
    case cosmeticSurgeons = "cosmeticsurgeons"
    case dermatologists = "dermatology"
    case earNoseAndThroat = "earnosethroat"
    case emergencyMedicine = "emergencymedicine"
    case endocrinologists
    case familyPractice = "familydr"
    case fertility
    case gastroenterologist
    case geneticists
    case gerontologists = "gerontologist"
    case hepatologists
    case homeopathic
    case hospitalists
    case immunodermatologists
    case infectiousDiseaseSpecialists = "infectiousdisease"
    case internalMedicine = "internalmed"
    case naturopathicAndHolistic = "naturopathic"
    case nephrologists
    case neurologist
    case neuropathologists
    case neurotologists
    case obstetriciansAndGynecologists = "obgyn"
    case oncologist
    case opthamologists = "opthamalogists"
    case orthopedists
    case osteopathicPhysicians = "osteopathicphysicians"
    case otologists
    case painManagement = "painmanagement"
    case pathologists
    case pediatricians
    case phlebologists
    case podiatrists
    case preventiveMedicine = "preventivemedicine"
    case proctologists = "proctologist"
    case psychiatrists
    case pulmonologist
    case radiologists
    case rheumatologists = "rhematologists"
    case spineSurgeons = "spinesurgeons"
    case sportsMedicine = "sportsmed"
    case surgeons
    case tattooRemoval = "tattooremoval"
    case toxicologists
    case underseaAndHyperbaricMedicine = "underseamedicine"
    case urologists
    case vascularMedicine = "vascularmedicine"
    case doulas
    case emergencyRooms = "emergencyrooms"
    case floatSpa = "floatspa"
    case habilitativeServices = "habilitativeservices"
    case halfwayHouses = "halfwayhouses"
    case halotherapy
    case healthInsuranceOffices = "healthinsurance"
    case hearingAidProviders = "hearingaidproviders"
    case hearingAids = "hearing_aids"
    case herbalShops = "herbalshops"
    case homeHealthCare = "homehealthcare"
    case hospice
    case hospitals
    case hydrotherapy
    case hypnosisAndHypnotherapy = "hypnosis"
    case ivHydration = "ivhydration"
    case lactationServices = "lactationservices"
    case laserEyeSurgeryAndLasik = "laserlasikeyes"
    case liceServices = "liceservices"
    case massageTherapy = "massage_therapy"
    case medicalCannabisReferrals = "cannabisreferrals"
    case medicalCenters = "medcenters"
    case bulkBilling = "bulkbilling"
    case osteopaths
    case walkInClinics = "walkinclinics"
    case medicalFootCare = "medicalfoot"
    case medicalSpas = "medicalspa"
    case medicalTransportation = "medicaltransportation"
    case midwives
    case nursePractitioner = "nursepractitioner"
    case nutritionists
    case occupationalTherapy = "occupationaltherapy"
    case optometrists
    case organAndTissueDonorServices = "organdonorservices"
    case orthotics
    case oxygenBars = "oxygenbars"
    case personalCareServices = "personalcare"
    case pharmacy
    case physicalTherapy = "physicaltherapy"
    case placentaEncapsulations = "placentaencapsulation"
    case prenatalAndPerinatalCare = "prenatal"
    case prosthetics
    case prosthodontists
    case psychotechnicalTests = "psychotechnicaltests"
    case reflexology
    case rehabilitationCenter = "rehabilitation_center"
    case reiki
    case retirementHomes = "retirement_homes"
    case saunas
    case skilledNursing = "skillednursing"
    case sleepSpecialists = "sleepspecialists"
    case speechTherapists = "speech_therapists"
    case spermClinic = "spermclinic"
    case traditionalChineseMedicine = "tcm"
    case tuiNa = "tuina"
    case urgentCare = "urgent_care"
    case weightLossCenters = "weightlosscenters"

    // Home Services
    case homeServices = "homeservices"
    case artificialTurf = "artificialturf"
    case buildingSupplies = "buildingsupplies"
    case cabinetry
    case carpenters
    case carpetInstallation = "carpetinstallation"
    case carpeting
    case childproofing
    case chimneySweeps = "chimneysweeps"
    case contractors
    case countertopInstallation = "countertopinstall"
    case damageRestoration = "damagerestoration"
    case decksAndRailing = "decksrailing"
    case demolitionServices = "demolitionservices"
    case doorSalesAndInstallation = "doorsales"
    case drywallInstallationAndRepair = "drywall"
    case electricians
    case excavationServices = "excavationservices"
    case fencesAndGates = "fencesgates"
    case fireProtectionServices = "fireprotection"
    case fireplaceServices = "fireplace"
    case firewood
    case flooring
    case foundationRepair = "foundationrepair"
    case furnitureAssembly = "furnitureassembly"
    case garageDoorServices = "garage_door_services"
    case gardeners
    case glassAndMirrors = "glassandmirrors"
    case gutterServices = "gutterservices"
    case handyman
    case heatingAndAirConditioningAndHVAC = "hvac"
    case holidayDecoratingServices = "seasonaldecorservices"
    case homeAutomation = "homeautomation"
    case homeCleaning = "homecleaning"
    case homeEnergyAuditors = "homeenergyauditors"
    case homeInspectors = "home_inspectors"
    case homeNetworkInstallation = "homenetworkinstall"
    case homeOrganization = "home_organization"
    case homeTheatreInstallation = "hometheatreinstallation"
    case homeWindowTinting = "homewindowtinting"
    case houseSitters = "housesitters"
    case insulationInstallation = "insulationinstallation"
    case interiorDesign = "interiordesign"
    case internetServiceProviders = "isps"
    case irrigation
    case keysAndLocksmiths = "locksmiths"
    case landscapeArchitects = "landscapearchitects"
    case landscaping
    case lightingFixturesAndEquipment = "lighting"
    case masonryAndConcrete = "masonry_concrete"
    case mobileHomeRepair = "mobile_home_repair"
    case movers
    case packingServices = "packingservices"
    case painters
    case patioCoverings = "patiocoverings"
    case plumbing
    case backflowServices = "backflowservices"
    case poolAndHotTubService = "poolservice"
    case poolCleaners = "poolcleaners"
    case pressureWashers = "pressurewashers"
    case refinishingServices = "refinishing"
    case roofInspectors = "roofinspectors"
    case roofing
    case saunaInstallationAndRepair = "saunainstallation"
    case securitySystems = "securitysystems"
    case shadesAndBlinds = "blinds"
    case shutters
    case solarInstallation = "solarinstallation"
    case solarPanelCleaning = "solarpanelcleaning"
    case structuralEngineers = "structuralengineers"
    case stuccoServices = "stucco"
    case televisionServiceProviders = "televisionserviceproviders"
    case tiling
    case treeServices = "treeservices"
    case utilities
    case vinylSiding = "vinylsiding"
    case wallpapering
    case waterHeaterInstallationAndRepair = "waterheaterinstallrepair"
    case waterPurificationServices = "waterpurification"
    case waterproofing
    case windowWashing = "windowwashing"
    case windowsInstallation = "windowsinstallation"

    // Hotels & Travel
    case hotelsAndTravel = "hotelstravel"
    case airports
    case airportTerminals = "airportterminals"
    case bedAndBreakfast = "bedbreakfast"
    case campgrounds
    case carRental = "carrental"
    case guestHouses = "guesthouses"
    case healthRetreats = "healthretreats"
    case hostels
    case hotels
    case agriturismi
    case mountainHuts = "mountainhuts"
    case pensions
    case residences
    case restStops = "reststops"
    case ryokan
    case motorcycleRental = "motorcycle_rental"
    case rvParks = "rvparks"
    case rvRental = "rvrental"
    case resorts
    case skiResorts = "skiresorts"
    case tours
    case aerialTours = "aerialtours"
    case architecturalTours = "architecturaltours"
    case artTours = "arttours"
    case beerTours = "beertours"
    case boatTours = "boattours"
    case busTours = "bustours"
    case foodTours = "foodtours"
    case historicalTours = "historicaltours"
    case scooterTours = "scootertours"
    case walkingTours = "walkingtours"
    case whaleWatchingTours = "whalewatchingtours"
    case wineTours = "winetours"
    case trainStations = "trainstations"
    case transportation = "transport"
    case airlines
    case airportShuttles = "airport_shuttles"
    case bikeSharing = "bikesharing"
    case busStations = "busstations"
    case buses
    case cableCars = "cablecars"
    case dolmusStation = "dolmusstation"
    case ferries
    case limos
    case metroStations = "metrostations"
    case pedicabs
    case privateJetCharter = "privatejetcharter"
    case publicTransportation = "publictransport"
    case sharedTaxis = "sharedtaxis"
    case taxis
    case townCarService = "towncarservice"
    case trains
    case waterTaxis = "watertaxis"
    case travelServices = "travelservices"
    case luggageStorage = "luggagestorage"
    case passportAndVisaServices = "passportvisaservices"
    case travelAgents = "travelagents"
    case visitorCenters = "visitorcenters"
    case vacationRentalAgents = "vacationrentalagents"
    case vacationRentals = "vacation_rentals"

    // Local Flavor
    case localFlavor = "localflavor"
    case parklets
    case publicArt = "publicart"
    case unofficialYelpEvents = "unofficialyelpevents"
    case yelpEvents = "yelpevents"

    // Local Services
    case localServices = "localservices"
    case threeDimensionalPrinting = "3dprinting"
    case adoptionServices = "adoptionservices"
    case airDuctCleaning = "airductcleaning"
    case appliancesAndRepair = "homeappliancerepair"
    case appraisalServices = "appraisalservices"
    case artRestoration = "artrestoration"
    case awnings
    case bailBondsmen = "bailbondsmen"
    case bikeRepairAndMaintenance = "bike_repair_maintenance"
    case bookbinding
    case busRental = "busrental"
    case calligraphy
    case carpetCleaning = "carpet_cleaning"
    case childCareAndDayCare = "childcare"
    case clockRepair = "clockrepair"
    case communityBookBox = "communitybookbox"
    case communityGardens = "communitygardens"
    case communityServiceAndNonProfit = "nonprofit"
    case foodBanks = "foodbanks"
    case homelessShelters = "homelessshelters"
    case couriersAndDeliveryServices = "couriers"
    case craneServices = "craneservices"
    case elderCarePlanning = "eldercareplanning"
    case electronicsRepair = "electronicsrepair"
    case engraving
    case environmentalAbatement = "enviroabatement"
    case environmentalTesting = "environmentaltesting"
    case farmEquipmentRepair = "farmequipmentrepair"
    case fingerprinting
    case forestry
    case funeralServicesAndCemeteries = "funeralservices"
    case cremationServices = "cremationservices"
    case mortuaryServices = "mortuaryservices"
    case furnitureRental = "rentfurniture"
    case furnitureRepair = "furniturerepair"
    case furnitureReupholstery = "reupholstery"
    case generatorInstallationAndRepair = "generatorinstallrepair"
    case gestorias
    case hazardousWasteDisposal = "hazardouswastedisposal"
    case hydrojetting
    case itServicesAndComputerRepair = "itservices"
    case dataRecovery = "datarecovery"
    case mobilePhoneRepair = "mobilephonerepair"
    case telecommunications
    case iceDelivery = "icedelivery"
    case internetBoothsAndCallingCenters = "internetbooth"
    case jewelryRepair = "jewelryrepair"
    case junkRemovalAndHauling = "junkremovalandhauling"
    case dumpsterRental = "dumpsterrental"
    case junkyards
    case knifeSharpening = "knifesharpening"
    case laundryServices = "laundryservices"
    case dryCleaning = "dryclean"
    case laundromat
    case machineAndToolRental = "machinerental"
    case machineShops = "machineshops"
    case mailboxCenters = "mailboxcenters"
    case metalFabricators = "metalfabricators"
    case musicalInstrumentServices = "musicinstrumentservices"
    case guitarStores = "guitarstores"
    case pianoServices = "pianoservices"
    case pianoStores = "pianostores"
    case nannyServices = "nannys"
    case notaries
    case pestControl = "pest_control"
    case powderCoating = "powdercoating"
    case printingServices = "copyshops"
    case propane
    case recordLabels = "record_labels"
    case recordingAndRehearsalStudios = "recording_studios"
    case recyclingCenter = "recyclingcenter"
    case sandblasting
    case screenPrinting = "screenprinting"
    case screenPrintingAndTShirtPrinting = "screen_printing_tshirt_printing"
    case selfStorage = "selfstorage"
    case septicServices = "septicservices"
    case sewingAndAlterations = "sewingalterations"
    case shippingCenters = "shipping_centers"
    case shoeRepair = "shoerepair"
    case shoeShine = "shoeshine"
    case snowRemoval = "snowremoval"
    case snuggleServices = "snuggleservices"
    case tvMounting = "tvmounting"
    case watchRepair = "watch_repair"
    case waterDelivery = "waterdelivery"
    case wellDrilling = "welldrilling"
    case wildlifeControl = "wildlifecontrol"
    case youthClub = "youth_club"

    // Mass Media
    case massMedia = "massmedia"
    case printMedia = "printmedia"
    case radioStations = "radiostations"
    case televisionStations = "televisionstations"

    // Nightlife
    case nightlife
    case adultEntertainment = "adultentertainment"
    case barCrawl = "barcrawl"
    case bars
    case absintheBars = "absinthebars"
    case airportLounges = "airportlounges"
    case beachBars = "beachbars"
    case beerBar = "beerbar"
    case champagneBars = "champagne_bars"
    case cocktailBars = "cocktailbars"
    case diveBars = "divebars"
    case driveThruBars = "drivethrubars"
    case gayBars = "gaybars"
    case hookahBars = "hookah_bars"
    case hotelBar = "hotel_bar"
    case irishPub = "irish_pubs"
    case lounges
    case pubs
    case pulquerias
    case sakeBars = "sakebars"
    case speakeasies
    case sportsBars = "sportsbars"
    case tabac
    case tikiBars = "tikibars"
    case vermouthBars = "vermouthbars"
    case whiskeyBars = "whiskeybars"
    case wineBars = "wine_bars"
    case beerGardens = "beergardens"
    case clubCrawl = "clubcrawl"
    case coffeeshops
    case comedyClubs = "comedyclubs"
    case countryDanceHalls = "countrydancehalls"
    case danceClubs = "danceclubs"
    case danceRestaurants = "dancerestaurants"
    case fasilMusic = "fasil"
    case karaoke
    case musicVenues = "musicvenues"
    case pianoBars = "pianobars"
    case poolHalls = "poolhalls"

    // Pets
    case pets
    case animalShelters = "animalshelters"
    case horseBoarding = "horse_boarding"
    case petAdoption = "petadoption"
    case petServices = "petservices"
    case animalPhysicalTherapy = "animalphysicaltherapy"
    case aquariumServices = "aquariumservices"
    case dogWalkers = "dogwalkers"
    case emergencyPetHospital = "emergencypethospital"
    case farriers
    case holisticAnimalCare = "animalholistic"
    case petBoardingAndSitting = "pet_sitting"
    case petBreeders = "petbreeders"
    case petCremationServices = "petcremation"
    case petGroomers = "groomer"
    case petHospice = "pethospice"
    case petInsurance = "petinsurance"
    case petPhotography = "petphotography"
    case petTraining = "pet_training"
    case petTransportation = "pettransport"
    case petStores = "petstore"
    case birdShops = "birdshops"
    case localFishStores = "localfishstores"
    case reptileShops = "reptileshops"
    case veterinarians = "vet"

    // Professional Services
    case professionalServices = "professional"
    case accountants
    case advertising
    case architects
    case billingServices = "billingservices"
    case boatRepair = "boatrepair"
    case bookkeepers
    case businessConsulting = "businessconsulting"
    case careerCounseling = "careercounseling"
    case commissionedArtists = "commissionedartists"
    case customsBrokers = "customsbrokers"
    case digitizingServices = "digitizingservices"
    case duplicationServices = "duplicationservices"
    case editorialServices = "editorialservices"
    case employmentAgencies = "employmentagencies"
    case fengShui = "fengshui"
    case graphicDesign = "graphicdesign"
    case indoorLandscaping = "indoorlandscaping"
    case lawyers
    case bankruptcyLaw = "bankruptcy"
    case businessLaw = "businesslawyers"
    case contractLaw = "contractlaw"
    case criminalDefenseLaw = "criminaldefense"
    case duiLaw = "duilawyers"
    case disabilityLaw = "disabilitylaw"
    case divorceAndFamilyLaw = "divorce"
    case employmentLaw = "employmentlawyers"
    case entertainmentLaw = "entertainmentlaw"
    case estatePlanningLaw = "estateplanning"
    case willsAndTrustsAndProbates = "willstrustsprobates"
    case generalLitigation = "general_litigation"
    case ipAndInternetLaw = "iplaw"
    case immigrationLaw = "immigrationlawyers"
    case medicalLaw = "medicallaw"
    case personalInjuryLaw = "personal_injury"
    case realEstateLaw = "realestatelawyers"
    case socialSecurityLaw = "socialsecuritylaw"
    case taxLaw = "taxlaw"
    case trafficTicketingLaw = "trafficticketinglaw"
    case workersCompensationLaw = "workerscomplaw"
    case legalServices = "legalservices"
    case courtReporters = "courtreporters"
    case processServers = "processservers"
    case lifeCoach = "lifecoach"
    case marketing
    case matchmakers
    case mediators
    case musicProductionServices = "musicproduction"
    case officeCleaning = "officecleaning"
    case patentLaw = "patentlaw"
    case payrollServices = "payroll"
    case personalAssistants = "personalassistants"
    case privateInvestigation = "privateinvestigation"
    case productDesign = "productdesign"
    case publicRelations = "publicrelations"
    case securityServices = "security"
    case shreddingServices = "shredding"
    case signmaking
    case softwareDevelopment = "softwaredevelopment"
    case talentAgencies = "talentagencies"
    case taxidermy
    case tenantAndEvictionLaw = "tenantlaw"
    case translationServices = "translationservices"
    case videoAndFilmProduction = "videofilmproductions"
    case webDesign = "web_design"
    case wholesalers
    case restaurantSupplies = "suppliesrestaurant"

    // Public Services & Government
    case publicServicesAndGovernment = "publicservicesgovt"
    case authorizedPostalRepresentative = "authorized_postal_representative"
    case civicCenter = "civiccenter"
    case communityCenters = "communitycenters"
    case courthouses
    case departmentsOfMotorVehicles = "departmentsofmotorvehicles"
    case embassy
    case fireDepartments = "firedepartments"
    case landmarksAndHistoricalBuildings = "landmarks"
    case libraries
    case municipality
    case policeDepartments = "policedepartments"
    case postOffices = "postoffices"
    case registryOffice = "registry_office"
    case taxOffice = "taxoffice"
    case townHall = "townhall"

    // Real Estate
    case realEstate = "realestate"
    case apartments
    case artSpaceRentals = "artspacerentals"
    case commercialRealEstate = "commercialrealestate"
    case condominiums
    case estateLiquidation = "estateliquidation"
    case homeDevelopers = "homedevelopers"
    case homeStaging = "homestaging"
    case homeownerAssociation = "homeownerassociation"
    case housingCooperatives = "housingcooperatives"
    case kitchenIncubators = "kitchenincubators"
    case mobileHomeDealers = "mobilehomes"
    case mobileHomeParks = "mobileparks"
    case mortgageBrokers = "mortgagebrokers"
    case propertyManagement = "propertymgmt"
    case realEstateAgents = "realestateagents"
    case realEstateServices = "realestatesvcs"
    case landSurveying = "landsurveying"
    case realEstatePhotography = "estatephotography"
    case sharedOfficeSpaces = "sharedofficespaces"
    case universityHousing = "university_housing"

    // Religious Organizations
    case religiousOrganizations = "religiousorgs"
    case afroBrazilian = "afrobrazilian"
    case buddhistTemples = "buddhist_temples"
    case churches
    case hinduTemples = "hindu_temples"
    case mosques
    case shrines
    case spiritism
    case synagogues
    case taoistTemples = "taoisttemples"

    // Restaurants
    case restaurants
    case afghan = "afghani"
    case african
    case senegalese
    case southAfrican = "southafrican"
    case newAmerican = "newamerican"
    case traditionalAmerican = "tradamerican"
    case andalusian
    case arabian
    case arabPizza = "arabpizza"
    case argentine
    case armenian
    case asianFusion = "asianfusion"
    case asturian
    case australian
    case austrian
    case baguettes
    case bangladeshi
    case barbeque = "bbq"
    case basque
    case bavarian
    case beerGarden = "beergarden"
    case beerHall = "beerhall"
    case beisl
    case belgian
    case flemish
    case bistros
    case blackSea = "blacksea"
    case brasseries
    case brazilian
    case brazilianEmpanadas = "brazilianempanadas"
    case centralBrazilian = "centralbrazilian"
    case northeasternBrazilian = "northeasternbrazilian"
    case northernBrazilian = "northernbrazilian"
    case rodizios
    case breakfastAndBrunch = "breakfast_brunch"
    case british
    case buffets
    case bulgarian
    case burgers
    case burmese
    case cafes
    case themedCafes = "themedcafes"
    case cafeteria
    case cajunAndCreole = "cajun"
    case cambodian
    case newCanadian = "newcanadian"
    case canteen
    case caribbean
    case dominican
    case haitian
    case puertoRican = "puertorican"
    case trinidadian
    case catalan
    case cheesesteaks
    case chickenShop = "chickenshop"
    case chickenWings = "chicken_wings"
    case chilean
    case chinese
    case cantonese
    case congee
    case dimSum = "dimsum"
    case fuzhou
    case hainan
    case hakka
    case henghwa
    case hokkien
    case hunan
    case pekinese
    case shanghainese
    case szechuan
    case teochew
    case comfortFood = "comfortfood"
    case corsican
    case creperies
    case cuban
    case currySausage = "currysausage"
    case cypriot
    case czech
    case czechAndSlovakian = "czechslovakian"
    case danish
    case delis
    case diners
    case dinnerTheater = "dinnertheater"
    case dumplings
    case easternEuropean = "eastern_european"
    case ethiopian
    case fastFood = "hotdogs"
    case filipino
    case fischbroetchen
    case fishAndChips = "fishnchips"
    case flatbread
    case fondue
    case foodCourt = "food_court"
    case foodStands = "foodstands"
    case freiduria
    case french
    case alsatian
    case auvergnat
    case berrichon
    case bourguignon
    case mauritius
    case nicoise = "nicois"
    case provencal
    case reunion
    case frenchSouthwest = "sud_ouest"
    case galician
    case gameMeat = "gamemeat"
    case gastropubs
    case georgian
    case german
    case baden
    case easternGerman = "easterngerman"
    case franconian
    case hessian
    case northernGerman = "northerngerman"
    case palatine
    case rhinelandian
    case giblets
    case glutenFree = "gluten_free"
    case greek
    case guamanian
    case halal
    case hawaiian
    case heuriger
    case himalayanAndNepalese = "himalayan"
    case honduran
    case hongKongStyleCafe = "hkcafe"
    case hotDogs = "hotdog"
    case hotPot = "hotpot"
    case hungarian
    case iberian
    case indian = "indpak"
    case indonesian
    case international
    case irish
    case islandPub = "island_pub"
    case israeli
    case italian
    case abruzzese
    case altoatesine
    case apulian
    case calabrian
    case cucinaCampana = "cucinacampana"
    case emilian
    case friulan
    case ligurian
    case lumbard
    case napoletana
    case piemonte
    case roman
    case sardinian
    case sicilian
    case tuscan
    case venetian
    case japanese
    case blowfish
    case conveyorBeltSushi = "conveyorsushi"
    case donburi
    case gyudon
    case oyakodon
    case handRolls = "handrolls"
    case horumon
    case izakaya
    case japaneseCurry = "japacurry"
    case kaiseki
    case kushikatsu
    case oden
    case okinawan
    case okonomiyaki
    case onigiri
    case ramen
    case robatayaki
    case soba
    case sukiyaki
    case takoyaki
    case tempura
    case teppanyaki
    case tonkatsu
    case udon
    case unagi
    case westernStyleJapaneseFood = "westernjapanese"
    case yakiniku
    case yakitori
    case jewish
    case kebab
    case kopitiam
    case korean
    case kosher
    case kurdish
    case laos
    case laotian
    case latinAmerican = "latin"
    case colombian
    case salvadoran
    case venezuelan
    case liveAndRawFood = "raw_food"
    case lyonnais
    case malaysian
    case mamak
    case nyonya
    case meatballs
    case mediterranean
    case falafel
    case mexican
    case easternMexican = "easternmexican"
    case jaliscan
    case northernMexican = "northernmexican"
    case oaxacan
    case pueblan
    case tacos
    case tamales
    case yucatan
    case middleEastern = "mideastern"
    case egyptian
    case lebanese
    case milkBars = "milkbars"
    case modernAustralian = "modern_australian"
    case modernEuropean = "modern_european"
    case mongolian
    case moroccan
    case newMexicanCuisine = "newmexican"
    case newZealand = "newzealand"
    case nicaraguan
    case nightFood = "nightfood"
    case nikkei
    case noodles
    case norcinerie
    case openSandwiches = "opensandwiches"
    case oriental
    case pfAndComercial = "pfcomercial"
    case pakistani
    case panAsian = "panasian"
    case parentCafes = "eltern_cafes"
    case parma
    case persianAndIranian = "persian"
    case peruvian
    case pita
    case pizza
    case polish
    case pierogis
    case popUpRestaurants = "popuprestaurants"
    case portuguese
    case alentejo
    case algarve
    case azores
    case beira
    case fadoHouses = "fado_houses"
    case madeira
    case minho
    case ribatejo
    case trasOsMontes = "tras_os_montes"
    case potatoes
    case poutineries
    case pubFood = "pubfood"
    case rice = "riceshop"
    case romanian
    case rotisserieChicken = "rotisserie_chicken"
    case russian
    case salad
    case sandwiches
    case scandinavian
    case schnitzel
    case scottish
    case seafood
    case serboCroatian = "serbocroatian"
    case signatureCuisine = "signature_cuisine"
    case singaporean
    case slovakian
    case soulFood = "soulfood"
    case soup
    case southern
    case spanish
    case arroceriaAndPaella = "arroceria_paella"
    case sriLankan = "srilankan"
    case steakhouses = "steak"
    case supperClubs = "supperclubs"
    case sushiBars = "sushi"
    case swabian
    case swedish
    case swissFood = "swissfood"
    case syrian
    case tabernas
    case taiwanese
    case tapasBars = "tapas"
    case tapasAndSmallPlates = "tapasmallplates"
    case tavolaCalda = "tavolacalda"
    case texMex = "tex-mex"
    case thai
    case traditionalNorwegian = "norwegian"
    case traditionalSwedish = "traditional_swedish"
    case trattorie
    case turkish
    case cheeKufta = "cheekufta"
    case gozleme
    case homemadeFood = "homemadefood"
    case lahmacun
    case ottomanCuisine = "ottomancuisine"
    case turkishRavioli = "turkishravioli"
    case ukrainian
    case uzbek
    case vegan
    case vegetarian
    case venison
    case vietnamese
    case waffles
    case wok
    case wraps
    case yugoslav

    // Shopping
    case shopping
    case adult
    case antiques
    case artsAndCrafts = "artsandcrafts"
    case artSupplies = "artsupplies"
    case ateliers
    case cardsAndStationery = "stationery"
    case cookingClasses = "cookingclasses"
    case costumes
    case embroideryAndCrochet = "embroideryandcrochet"
    case fabricStores = "fabricstores"
    case framing
    case paintYourOwnPottery = "paintyourownpottery"
    case auctionHouses = "auctionhouses"
    case babyGearAndFurniture = "baby_gear"
    case batteryStores = "batterystores"
    case bespokeClothing = "bespoke"
    case booksAndMagazinesAndMusicAndVideo = "media"
    case bookstores
    case comicBooks = "comicbooks"
    case musicAndDVDs = "musicvideo"
    case newspapersAndMagazines = "mags"
    case videoGameStores = "videogamestores"
    case videosAndVideoGameRental = "videoandgames"
    case vinylRecords = "vinyl_records"
    case brewingSupplies = "brewingsupplies"
    case bridal
    case cannabisDispensaries = "cannabisdispensaries"
    case chineseBazaar = "chinesebazaar"
    case computers
    case conceptShops = "concept_shops"
    case customizedMerchandise = "custommerchandise"
    case departmentStores = "deptstores"
    case discountStore = "discountstore"
    case drugstores
    case dutyFreeShops = "dutyfreeshops"
    case electronics
    case eyewearAndOpticians = "opticians"
    case farmingEquipment = "farmingequipment"
    case fashion
    case accessories
    case ceremonialClothing = "ceremonialclothing"
    case childrensClothing = "childcloth"
    case clothingRental = "clothingrental"
    case formalWear = "formalwear"
    case furClothing = "furclothing"
    case hats
    case kimonos
    case leatherGoods = "leather"
    case lingerie
    case maternityWear = "maternity"
    case mensClothing = "menscloth"
    case plusSizeFashion = "plus_size_fashion"
    case shoeStores = "shoes"
    case sleepwear
    case sportsWear = "sportswear"
    case danceWear = "dancewear"
    case stockings
    case surfShop = "surfshop"
    case swimwear
    case traditionalClothing = "tradclothing"
    case usedAndVintageAndConsignment = "vintage"
    case womensClothing = "womenscloth"
    case fireworks
    case fitnessAndExerciseEquipment = "fitnessequipment"
    case fleaMarkets = "fleamarkets"
    case flowersAndGifts = "flowers"
    case florists
    case giftShops = "giftshops"
    case goldBuyers = "goldbuyers"
    case gunsAndAmmo = "guns_and_ammo"
    case headShops = "headshops"
    case highFidelityAudioEquipment = "hifi"
    case hobbyShops = "hobbyshops"
    case homeAndGarden = "homeandgarden"
    case appliances
    case candleStores = "candlestores"
    case christmasTrees = "christmastrees"
    case furnitureStores = "furniture"
    case grillingEquipment = "grillingequipment"
    case hardwareStores = "hardware"
    case holidayDecorations = "holidaydecorations"
    case homeDecor = "homedecor"
    case hotTubAndPool = "hottubandpool"
    case kitchenAndBath = "kitchenandbath"
    case linens
    case materialeElettrico = "materialeelettrico"
    case mattresses
    case nurseriesAndGardening = "gardening"
    case hydroponics
    case outdoorFurnitureStores = "outdoorfurniture"
    case paintStores = "paintstores"
    case playsets
    case pumpkinPatches = "pumpkinpatches"
    case rugs
    case tableware
    case horseEquipmentShops = "horsequipment"
    case jewelry
    case kiosk
    case knittingSupplies = "knittingsupplies"
    case livestockFeedAndSupply = "livestocksupply"
    case luggage
    case marketStalls = "marketstalls"
    case medicalSupplies = "medicalsupplies"
    case militarySurplus = "militarysurplus"
    case mobilePhoneAccessories = "cellphoneaccessories"
    case mobilePhones = "mobilephones"
    case motorcycleGear = "motorcyclinggear"
    case musicalInstrumentsAndTeachers = "musicalinstrumentsandteachers"
    case officeEquipment = "officeequipment"
    case outletStores = "outlet_stores"
    case packingSupplies = "packingsupplies"
    case pawnShops = "pawn"
    case personalShopping = "personal_shopping"
    case photographyStoresAndServices = "photographystores"
    case poolAndBilliards = "poolbilliards"
    case popUpShops = "popupshops"
    case props
    case publicMarkets = "publicmarkets"
    case religiousItems = "religiousitems"
    case safeStores = "safestores"
    case safetyEquipment = "safetyequipment"
    case scandinavianDesign = "scandinaviandesign"
    case shoppingCenters = "shoppingcenters"
    case shoppingPassages = "shoppingpassages"
    case souvenirShops = "souvenirs"
    case spiritualShop = "spiritual_shop"
    case sportingGoods = "sportgoods"
    case bikes
    case diveShops = "diveshops"
    case golfEquipment = "golfequipment"
    case huntingAndFishingSupplies = "huntingfishingsupplies"
    case outdoorGear = "outdoorgear"
    case skateShops = "skateshops"
    case skiAndSnowboardShops = "skishops"
    case tabletopGames = "tabletopgames"
    case teacherSupplies = "teachersupplies"
    case thriftStores = "thrift_stores"
    case tickets
    case tobaccoShops = "tobaccoshops"
    case toyStores = "toys"
    case trophyShops = "trophyshops"
    case uniforms
    case usedBookstore = "usedbooks"
    case vapeShops = "vapeshops"
    case vitaminsAndSupplements = "vitaminssupplements"
    case watches
    case wholesaleStores = "wholesale_stores"
    case wigs
}
// swiftlint:enable file_length type_body_length
