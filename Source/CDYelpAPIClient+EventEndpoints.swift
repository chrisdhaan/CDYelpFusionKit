//
//  CDYelpAPIClient+EventEndpoints.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 8/29/26.
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

#if os(macOS)
    import Foundation
#else
    import UIKit
#endif

extension CDYelpAPIClient {

    // MARK: - Event Endpoints

    ///
    /// This endpoint returns the detailed information of a Yelp event. To get an event id, refer to **searchEvents(byLocale: )** or **fetchFeaturedEvent(forLocale: )**. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - id: (**Required**) The identifier of the event for the Yelp Fusion API to query.
    ///   - locale: (Optional) The locale to return the event information in.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchEvent(
        forId id: String,
        locale: CDYelpLocale?
    ) async throws -> CDYelpEventResponse {
        precondition(!id.isEmpty, "An event id is required to query the Yelp Fusion API event endpoint.")
        let parameters = Parameters.eventParameters(withLocale: locale)
        let router = CDYelpRouter.event(id: id, parameters: parameters)
        return try await perform(router, decoder: makeDecoder(dateFormat: DateFormatter.events))
    }

    ///
    /// This endpoint returns events based on the provided search criteria. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - locale: (Optional) The locale to return the event information in.
    ///   - offset: (Optional) A number the list of returned events should be offset by.
    ///   - limit: (Optional) The number of events results to return. By default, the value is set to 3. **The maximum value is 50**.
    ///   - sortBy: (Optional) The sort by mode that will be used on the returned events results. Use the **CDYelpEvetSortByType** enum to get the list of supported sort types. By default sortBy is set to `.descending`.
    ///   - sortOn: (Optional) The sort on mode that will be used on the returned events results. Use the **CDYelpEvetSortOnType** enum to get the list of supported sort types. By default sortBy is set to `.popularity`.
    ///   - startDate: (Optional) A unix timestamp that queiries events only beginiing at or after the specified time.
    ///   - endDate: (Optional) A unix timestamp that queiries events only ending at or before the specified time.
    ///   - isFree: (Optional) When set to true, only events that are free to attend will be returned. By default, no filter is applied so both free and paid events will be returned.
    ///   - location: (Optional) Specifies the combination of "address, neighborhood, city, state or zip, optional country" to be used when querying the Yelp Fusion API for events.
    ///   - latitude: (Optional) The latitude of the location the Yelp Fusion API should search nearby.
    ///   - longitude: (Optional) The longitude of the location the Yelp Fusion API should search nearby.
    ///   - radius: (Optional) The search radius in meters. If the value is too large, an AREA_TOO_LARGE error may be returned. **The maximum value is 40,000 meters (25 miles)**.
    ///   - categories: (Optional) The categories for the Yelp Fusion API to filter events by.
    ///   - excludedEvents: (Optional) A list of event ids. Events associated with these event ids in this list will not show up in the response.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func searchEvents(
        byLocale locale: CDYelpLocale?,
        offset: Int?,
        limit: Int?,
        sortBy: CDYelpEventSortByType?,
        sortOn: CDYelpEventSortOnType?,
        startDate: Date?,
        endDate: Date?,
        categories: [CDYelpEventCategoryFilter]?,
        isFree: Bool?,
        location: String?,
        latitude: Double?,
        longitude: Double?,
        radius: Int?,
        excludedEvents: [String]?
    ) async throws -> CDYelpEventsResponse {
        if let limit {
            precondition(limit > 0 && limit <= 50, "The limit must be 50 or less to query the Yelp Fusion API events endpoint.")
        }
        if let radius {
            precondition(radius > 0 && radius <= 40000, "The radius must be 40,000 meters or less to query the Yelp Fusion API events endpoint.")
        }
        let parameters = Parameters.eventsParameters(
            withLocale: locale,
            offset: offset,
            limit: limit,
            sortBy: sortBy,
            sortOn: sortOn,
            startDate: startDate,
            endDate: endDate,
            categories: categories,
            isFree: isFree,
            location: location,
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            excludedEvents: excludedEvents
        )
        let router = CDYelpRouter.events(parameters: parameters)
        return try await perform(router, decoder: makeDecoder(dateFormat: DateFormatter.events))
    }

    ///
    /// This endpoint returns the featured event for a given location. Featured events are chosen by Yelp's community managers. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - locale: (Optional) The locale to return the event information in.
    ///   - location: Required unless latitude and longitude are both provided. Specifies the combination of "address, neighborhood, city, state or zip, optional country" to be used when querying the Yelp Fusion API for events.
    ///   - latitude: Required unless location is provided. Must be accompanied by longitude.
    ///   - longitude: Required unless location is provided. Must be accompanied by latitude.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchFeaturedEvent(
        forLocale locale: CDYelpLocale?,
        location: String?,
        latitude: Double?,
        longitude: Double?
    ) async throws -> CDYelpEventResponse {
        precondition(
            (latitude != nil && longitude != nil) || location != nil,
            "Either a latitude and longitude or a location are required to query the Yelp Fusion API featured event endpoint."
        )
        let parameters = Parameters.featuredEventParameters(
            withLocale: locale,
            location: location,
            latitude: latitude,
            longitude: longitude
        )
        let router = CDYelpRouter.featuredEvent(parameters: parameters)
        return try await perform(router, decoder: makeDecoder(dateFormat: DateFormatter.events))
    }
}
