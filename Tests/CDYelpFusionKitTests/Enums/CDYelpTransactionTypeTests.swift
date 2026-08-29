import Testing
@testable import CDYelpFusionKit

@Suite(.serialized) struct CDYelpTransactionTypeTests {
    @Test func foodDeliveryRawValue() {
        #expect(CDYelpTransactionType.foodDelivery.rawValue == "delivery")
    }

    @Test func pickupRawValue() {
        #expect(CDYelpTransactionType.pickup.rawValue == "pickup")
    }

    @Test func restaurantReservationRawValue() {
        #expect(CDYelpTransactionType.restaurantReservation.rawValue == "restaurant_reservation")
    }
}
