import Foundation

/// @unchecked because each case's `parameters: [String: Any]` associated value isn't verifiably
/// `Sendable` at compile time — `Any` erases the concrete type. In practice every value placed
/// into these dictionaries (by `Parameters+CDYelpFusionKit.swift` and the public API methods that
/// build them) is a `String`, `Bool`, `Int`, `Double`, or array thereof — all `Sendable` — and
/// `asURLRequest(apiKey:)` only ever reads them, never mutates them.
enum CDYelpRouter: @unchecked Sendable {
    // GET endpoints
    case search(parameters: [String: Any])
    case phone(parameters: [String: Any])
    case transactions(type: String, parameters: [String: Any])
    case business(id: String, parameters: [String: Any])
    case matches(parameters: [String: Any])
    case reviews(id: String, parameters: [String: Any])
    case autocomplete(parameters: [String: Any])
    case event(id: String, parameters: [String: Any])
    case events(parameters: [String: Any])
    case featuredEvent(parameters: [String: Any])
    case allCategories(parameters: [String: Any])
    case categoryDetails(alias: String, parameters: [String: Any])
    case engagement(parameters: [String: Any])
    case serviceOfferings(id: String, parameters: [String: Any])
    case businessInsights(parameters: [String: Any])
    case reviewHighlights(id: String, parameters: [String: Any])
    case openings(businessId: String, parameters: [String: Any])
    // POST endpoints
    case aiChat(request: CDYelpAIChatRequest)
    case jobs(query: String, locale: String?)

    var path: String {
        switch self {
        case .search:
            "businesses/search"
        case .phone:
            "businesses/search/phone"
        case let .transactions(type, _):
            "transactions/\(Self.percentEncodedPathSegment(type))/search"
        case let .business(id, _):
            "businesses/\(Self.percentEncodedPathSegment(id))"
        case .matches:
            "businesses/matches"
        case let .reviews(id, _):
            "businesses/\(Self.percentEncodedPathSegment(id))/reviews"
        case .autocomplete:
            "autocomplete"
        case let .event(id, _):
            "events/\(Self.percentEncodedPathSegment(id))"
        case .events:
            "events"
        case .featuredEvent:
            "events/featured"
        case .allCategories:
            "categories"
        case let .categoryDetails(alias, _):
            "categories/\(Self.percentEncodedPathSegment(alias))"
        case .engagement:
            "businesses/engagement"
        case let .serviceOfferings(id, _):
            "businesses/\(Self.percentEncodedPathSegment(id))/service_offerings"
        case .businessInsights:
            "businesses/insights"
        case let .reviewHighlights(id, _):
            "businesses/\(Self.percentEncodedPathSegment(id))/review_highlights"
        case let .openings(businessId, _):
            "bookings/\(Self.percentEncodedPathSegment(businessId))/openings"
        case .aiChat:
            "ai/chat/v2"
        case .jobs:
            "jobs"
        }
    }

    /// Percent-encodes a single path segment so identifiers containing reserved URL characters
    /// (`?`, `#`, `/`, etc.) can't be reinterpreted as path/query delimiters when `path` is later
    /// concatenated with the base URL and re-parsed by `URLComponents(string:)`.
    private static func percentEncodedPathSegment(_ raw: String) -> String {
        let unreserved = CharacterSet(charactersIn: "-._~").union(.alphanumerics)
        return raw.addingPercentEncoding(withAllowedCharacters: unreserved) ?? raw
    }

    /// Sets the headers every request needs (User-Agent, Authorization, Accept, Accept-Language),
    /// plus Content-Type when a request body is present, so the header set only needs to be
    /// expressed once regardless of which branch of `asURLRequest(apiKey:)` builds the request.
    private static func applyStandardHeaders(to urlRequest: inout URLRequest, apiKey: String, hasBody: Bool) {
        urlRequest.setValue(CDYelpFusionKitUserAgent, forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue(acceptLanguageHeaderValue(), forHTTPHeaderField: "Accept-Language")
        if hasBody {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }

    /// Mirrors Alamofire's `HTTPHeaders.default` Accept-Language header, which the pre-v6
    /// Alamofire-backed session sent on every request via `sessionConfiguration.httpAdditionalHeaders`.
    /// Encodes the given preferred languages with decreasing quality values, e.g.
    /// `"en-US;q=1.0, fr-FR;q=0.9"`.
    ///
    /// Takes `preferredLanguages` as a parameter (defaulting to the live `Locale.preferredLanguages`)
    /// rather than caching the header in a `static let`, so a language change is reflected on the
    /// very next request instead of requiring a process relaunch.
    static func acceptLanguageHeaderValue(preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
        }.joined(separator: ", ")
    }

    /// Builds a POST request with a JSON-encoded body, shared by the `.aiChat` and `.jobs`
    /// branches of `asURLRequest(apiKey:)` — they differ only in base URL and encoded value.
    private static func postRequest(url: URL, apiKey: String, encoding encode: () throws -> Data) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        applyStandardHeaders(to: &urlRequest, apiKey: apiKey, hasBody: true)
        do {
            urlRequest.httpBody = try encode()
        } catch {
            throw CDYelpNetworkError.invalidRequest(underlying: error)
        }
        return urlRequest
    }

    func asURLRequest(apiKey: String) throws -> URLRequest {
        switch self {
        case let .aiChat(request):
            // aiChat: outside /v3/ base — uses rootBase + path so .path is the single source of truth
            guard let url = URL(string: CDYelpURL.rootBase + path) else {
                throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
            }
            return try Self.postRequest(url: url, apiKey: apiKey) { try JSONEncoder().encode(request) }

        case let .jobs(query, locale):
            // jobs: POST + JSON body under /v3/ base
            guard let url = URL(string: CDYelpURL.base + path) else {
                throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
            }
            return try Self.postRequest(url: url, apiKey: apiKey) {
                var body: [String: String] = ["query": query]
                if let locale {
                    body["locale"] = locale
                }
                return try JSONEncoder().encode(body)
            }

        default:
            // All other cases: GET + URL query parameters
            guard var components = URLComponents(string: CDYelpURL.base + path) else {
                throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
            }
            let queryParams = queryParameters
            if !queryParams.isEmpty {
                components.queryItems = try queryParams.map {
                    let value: String
                    if let boolValue = $0.value as? Bool {
                        // Numeric ("1"/"0"), matching the Yelp Fusion API convention and the
                        // encoding this library has always sent (previously via Alamofire's
                        // default URLEncoding, whose boolEncoding is .numeric).
                        value = boolValue ? "1" : "0"
                    } else if let doubleValue = $0.value as? Double {
                        // NaN/Infinity have no valid coordinate representation — %.8f would
                        // silently render "nan"/"inf"/"-inf" and send a malformed request.
                        guard doubleValue.isFinite else {
                            throw CDYelpNetworkError.invalidRequest(underlying: NonFiniteQueryValueError(parameterName: $0.key))
                        }
                        // String(describing:) renders small magnitudes (e.g. latitude/longitude
                        // within ~0.0001 of 0) in scientific notation ("1e-05"), which servers
                        // don't parse as a coordinate. Always use fixed-point decimal notation.
                        value = String(format: "%.8f", doubleValue)
                    } else {
                        value = String(describing: $0.value)
                    }
                    return URLQueryItem(name: $0.key, value: value)
                }
                // URLComponents allows + per RFC 3986, but servers decode it as a space
                // (application/x-www-form-urlencoded convention); force-encode it as %2B.
                if let query = components.percentEncodedQuery {
                    components.percentEncodedQuery = query.replacingOccurrences(of: "+", with: "%2B")
                }
            }
            guard let url = components.url else {
                throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            Self.applyStandardHeaders(to: &urlRequest, apiKey: apiKey, hasBody: false)
            return urlRequest
        }
    }

    /// Single source of truth for which endpoints are safe to serve from the response cache.
    /// `CDYelpURLSession.perform` also requires the request be a GET before honoring this, so the
    /// value here is only consulted for endpoints that could ever be cacheable in practice.
    ///
    /// Deliberately an explicit allow-list with no `default` case: a newly added `CDYelpRouter`
    /// case fails to compile here until someone decides which bucket it belongs in, rather than
    /// silently inheriting "cacheable" the way an exclusion list with a `default: true` would.
    var isCacheable: Bool {
        switch self {
        case .search, .phone, .transactions, .business, .matches, .reviews, .autocomplete,
             .event, .events, .featuredEvent, .allCategories, .categoryDetails:
            true
        case .engagement, .serviceOfferings, .businessInsights, .reviewHighlights, .openings:
            // Near-real-time analytics/availability endpoints were never cached prior to v6.
            false
        case .aiChat, .jobs:
            // POST endpoints; CDYelpURLSession's GET-only cache-key gate would exclude these
            // regardless, but listing them here keeps this switch exhaustive and self-documenting.
            false
        }
    }

    /// Thrown when a Double query parameter is NaN or infinite and has no valid wire representation.
    struct NonFiniteQueryValueError: LocalizedError {
        let parameterName: String
        var errorDescription: String? {
            "Query parameter '\(parameterName)' is not a finite number (NaN or infinite) and cannot be sent to the Yelp Fusion API."
        }
    }

    private var queryParameters: [String: Any] {
        switch self {
        case let .search(params), let .phone(params), let .matches(params),
             let .autocomplete(params), let .events(params), let .featuredEvent(params),
             let .allCategories(params), let .engagement(params), let .businessInsights(params):
            params
        case let .transactions(_, params), let .business(_, params), let .reviews(_, params),
             let .event(_, params), let .categoryDetails(_, params), let .serviceOfferings(_, params),
             let .reviewHighlights(_, params), let .openings(_, params):
            params
        case .aiChat, .jobs:
            [:]
        }
    }
}
