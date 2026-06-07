@testable import CDYelpFusionKit
import Testing

@Suite(.serialized) struct CDYelpReviewSortTypeTests {
    @Test func yelpSortRawValue() {
        #expect(CDYelpReviewSortType.yelpSort.rawValue == "yelp_sort")
    }

    @Test func ratingRawValue() {
        #expect(CDYelpReviewSortType.rating.rawValue == "rating")
    }

    @Test func timeCreatedRawValue() {
        #expect(CDYelpReviewSortType.timeCreated.rawValue == "time_created")
    }
}
