import Testing
@testable import CDYelpFusionKit

@Suite(.serialized) struct CDYelpAttributeFilterTests {
    @Test func parkingRawValues() {
        #expect(CDYelpAttributeFilter.parkingGarage.rawValue == "parking_garage")
        #expect(CDYelpAttributeFilter.parkingLot.rawValue == "parking_lot")
        #expect(CDYelpAttributeFilter.parkingStreet.rawValue == "parking_street")
        #expect(CDYelpAttributeFilter.parkingValet.rawValue == "parking_valet")
        #expect(CDYelpAttributeFilter.parkingBike.rawValue == "parking_bike")
        #expect(CDYelpAttributeFilter.parkingValidated.rawValue == "parking_validated")
    }

    @Test func dietaryRawValues() {
        #expect(CDYelpAttributeFilter.likedByVegetarians.rawValue == "liked_by_vegetarians")
        #expect(CDYelpAttributeFilter.veganOfferings.rawValue == "vegan_offerings")
        #expect(CDYelpAttributeFilter.glutenFreeOfferings.rawValue == "gluten_free_offerings")
        #expect(CDYelpAttributeFilter.outdoorSeating.rawValue == "outdoor_seating")
    }
}
