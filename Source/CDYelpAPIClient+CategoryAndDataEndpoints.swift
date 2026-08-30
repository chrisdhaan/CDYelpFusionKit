//
//  CDYelpAPIClient+CategoryAndDataEndpoints.swift
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

    // MARK: - Category Endpoints

    ///
    /// This endpoint returns all Yelp business categories across all locales by default. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - locale: (Optional) The locale to return the category information in.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchCategories(forLocale locale: CDYelpLocale?) async throws -> CDYelpCategoriesResponse {
        let parameters = Parameters.categoriesParameters(withLocale: locale)
        let router = CDYelpRouter.allCategories(parameters: parameters)
        return try await perform(router)
    }

    ///
    /// This endpoint returns detailed information about the Yelp category specified by a Yelp category alias.  To get a category alias, refer to **fetchCategories(forLocale: )**. To enable this endpoint, please join the Yelp Developer Beta Program.
    ///
    /// - parameters:
    ///   - alias: (**Required**) The alias to return category details for. Use the **CDYelpCategoryAlias** enum to get the list of supported category aliases.
    ///   - locale: (Optional) The locale to return the category information in.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchCategory(
        forAlias alias: CDYelpCategoryAlias,
        andLocale locale: CDYelpLocale?
    ) async throws -> CDYelpCategoryResponse {
        precondition(!alias.rawValue.isEmpty, "A category alias is required to query the Yelp Fusion API category details endpoint.")
        let parameters = Parameters.categoriesParameters(withLocale: locale)
        let router = CDYelpRouter.categoryDetails(alias: alias.rawValue, parameters: parameters)
        return try await perform(router)
    }

    // MARK: - AI Chat, Engagement, and Business Data Endpoints

    ///
    /// Fetches AI chat response from the Yelp AI Chat endpoint.
    ///
    /// - parameters:
    ///   - query: (Required) A natural language query about local businesses. Maximum length is 1000 characters.
    ///   - chatId: (Optional) The ID of an existing chat to continue a multi-turn conversation.
    ///   - latitude: (Optional) The latitude of the user's location. Must be provided together with `longitude`, or not at all.
    ///   - longitude: (Optional) The longitude of the user's location. Must be provided together with `latitude`, or not at all.
    ///   - requestContext: (Optional) Additional key-value context for the request.
    ///
    /// - Precondition: `latitude` and `longitude` must both be `nil` or both be non-`nil`. Passing only one traps,
    ///   unlike prior versions, which silently dropped the lone coordinate. See the 6.0 migration guide.
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchAIChat(
        query: String,
        chatId: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        requestContext: [String: String]? = nil
    ) async throws -> CDYelpAIChatResponse {
        precondition(!query.isEmpty, "A query is required.")
        precondition(query.count <= 1000, "Query must be 1000 characters or fewer.")
        precondition(
            (latitude == nil) == (longitude == nil),
            "latitude and longitude must be provided together or not at all."
        )
        let userContext: CDYelpAIChatRequest.UserContext? = if let latitude, let longitude {
            .init(latitude: latitude, longitude: longitude)
        } else {
            nil
        }
        let chatRequest = CDYelpAIChatRequest(
            query: query,
            chatId: chatId,
            userContext: userContext,
            requestContext: requestContext
        )
        let router = CDYelpRouter.aiChat(request: chatRequest)
        return try await perform(router)
    }

    ///
    /// Fetches engagement metrics for a list of businesses.
    ///
    /// - parameters:
    ///   - businessIds: (Required) A list of business IDs (1–20 required).
    ///   - dateRangeStart: (Optional) The start date for the metric date range.
    ///   - dateRangeEnd: (Optional) The end date for the metric date range.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchEngagementMetrics(
        forBusinessIds businessIds: [String],
        dateRangeStart: String? = nil,
        dateRangeEnd: String? = nil
    ) async throws -> CDYelpEngagementResponse {
        precondition(!businessIds.isEmpty && businessIds.count <= 20, "Between 1 and 20 business IDs are required.")
        let parameters = Parameters.engagementParameters(
            withBusinessIds: businessIds,
            dateRangeStart: dateRangeStart,
            dateRangeEnd: dateRangeEnd
        )
        let router = CDYelpRouter.engagement(parameters: parameters)
        return try await perform(router)
    }

    ///
    /// Fetches service offerings for a business.
    ///
    /// - parameters:
    ///   - id: (Required) The business ID.
    ///   - locale: (Optional) The desired language for the response.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchServiceOfferings(
        forBusinessId id: String,
        locale: CDYelpLocale? = nil
    ) async throws -> CDYelpServiceOfferingsResponse {
        precondition(!id.isEmpty, "A business ID is required.")
        let parameters = Parameters.businessParameters(withLocale: locale, devicePlatform: nil)
        let router = CDYelpRouter.serviceOfferings(id: id, parameters: parameters)
        return try await perform(router)
    }

    ///
    /// Fetches business insights for the provided business IDs.
    ///
    /// - parameters:
    ///   - businessIds: (Required) The business IDs for which to fetch insights. Must be between 1 and 20.
    ///   - dateRangeStart: (Required) Start date for the insights (format: YYYYMM).
    ///   - dateRangeEnd: (Required) End date for the insights (format: YYYYMM).
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchBusinessInsights(
        forBusinessIds businessIds: [String],
        dateRangeStart: String,
        dateRangeEnd: String
    ) async throws -> CDYelpBusinessInsightsResponse {
        precondition(!businessIds.isEmpty && businessIds.count <= 20, "Between 1 and 20 business IDs are required.")
        precondition(!dateRangeStart.isEmpty && !dateRangeEnd.isEmpty, "dateRangeStart and dateRangeEnd are required (format: YYYYMM).")
        let parameters = Parameters.businessInsightsParameters(
            withBusinessIds: businessIds,
            dateRangeStart: dateRangeStart,
            dateRangeEnd: dateRangeEnd
        )
        let router = CDYelpRouter.businessInsights(parameters: parameters)
        return try await perform(router)
    }

    ///
    /// Fetches review highlights for a business.
    ///
    /// - parameters:
    ///   - id: (Required) The business ID.
    ///   - count: (Optional) Number of highlights to return (1–5).
    ///   - locale: (Optional) The desired language for the response.
    ///   - devicePlatform: (Optional) The device platform for the request.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchReviewHighlights(
        forBusinessId id: String,
        count: Int? = nil,
        locale: CDYelpLocale? = nil,
        devicePlatform: String? = nil
    ) async throws -> CDYelpReviewHighlightsResponse {
        precondition(!id.isEmpty, "A business ID is required.")
        if let count {
            precondition(count >= 1 && count <= 5, "count must be between 1 and 5.")
        }
        let parameters = Parameters.reviewHighlightsParameters(count: count, locale: locale, devicePlatform: devicePlatform)
        let router = CDYelpRouter.reviewHighlights(id: id, parameters: parameters)
        return try await perform(router)
    }

    ///
    /// Fetches home services (jobs) for the provided query.
    ///
    /// - parameters:
    ///   - query: (Required) The search query (1–1000 characters).
    ///   - locale: (Optional) The desired language for the response.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchJobs(
        forQuery query: String,
        locale: CDYelpLocale? = nil
    ) async throws -> CDYelpJobsResponse {
        precondition(!query.isEmpty && query.count <= 1000, "A query of 1–1000 characters is required.")
        let router = CDYelpRouter.jobs(query: query, locale: locale?.rawValue)
        return try await perform(router)
    }

    ///
    /// Fetches available reservation openings for a business.
    ///
    /// - parameters:
    ///   - id: (Required) The business ID.
    ///   - covers: (Required) Party size (1–10).
    ///   - date: (Required) The desired date (format: YYYY-MM-DD).
    ///   - time: (Required) The desired time (format: HH:MM).
    ///   - getCoversRange: (Optional) Whether to include covers range information.
    ///
    /// - Throws: ``CDYelpNetworkError`` if the request fails.
    ///
    public func fetchOpenings(
        forBusinessId id: String,
        covers: Int,
        date: String,
        time: String,
        getCoversRange: Bool? = nil
    ) async throws -> CDYelpOpeningsResponse {
        precondition(!id.isEmpty, "A business ID is required.")
        precondition(covers >= 1 && covers <= 10, "covers must be between 1 and 10.")
        precondition(!date.isEmpty, "A date is required (format: YYYY-MM-DD).")
        precondition(!time.isEmpty, "A time is required (format: HH:MM).")
        let parameters = Parameters.openingsParameters(covers: covers, date: date, time: time, getCoversRange: getCoversRange)
        let router = CDYelpRouter.openings(businessId: id, parameters: parameters)
        return try await perform(router)
    }
}
