import Foundation

enum CDYelpRouter {
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
            return "businesses/search"
        case .phone:
            return "businesses/search/phone"
        case let .transactions(type, _):
            return "transactions/\(Self.percentEncodedPathSegment(type))/search"
        case let .business(id, _):
            return "businesses/\(Self.percentEncodedPathSegment(id))"
        case .matches:
            return "businesses/matches"
        case let .reviews(id, _):
            return "businesses/\(Self.percentEncodedPathSegment(id))/reviews"
        case .autocomplete:
            return "autocomplete"
        case let .event(id, _):
            return "events/\(Self.percentEncodedPathSegment(id))"
        case .events:
            return "events"
        case .featuredEvent:
            return "events/featured"
        case .allCategories:
            return "categories"
        case let .categoryDetails(alias, _):
            return "categories/\(Self.percentEncodedPathSegment(alias))"
        case .engagement:
            return "businesses/engagement"
        case let .serviceOfferings(id, _):
            return "businesses/\(Self.percentEncodedPathSegment(id))/service_offerings"
        case .businessInsights:
            return "businesses/insights"
        case let .reviewHighlights(id, _):
            return "businesses/\(Self.percentEncodedPathSegment(id))/review_highlights"
        case let .openings(businessId, _):
            return "bookings/\(Self.percentEncodedPathSegment(businessId))/openings"
        case .aiChat:
            return "ai/chat/v2"
        case .jobs:
            return "jobs"
        }
    }

    /// Percent-encodes a single path segment so identifiers containing reserved URL characters
    /// (`?`, `#`, `/`, etc.) can't be reinterpreted as path/query delimiters when `path` is later
    /// concatenated with the base URL and re-parsed by `URLComponents(string:)`.
    private static func percentEncodedPathSegment(_ raw: String) -> String {
        let unreserved = CharacterSet(charactersIn: "-._~").union(.alphanumerics)
        return raw.addingPercentEncoding(withAllowedCharacters: unreserved) ?? raw
    }

    func asURLRequest(apiKey: String) throws -> URLRequest {
        switch self {
        case let .aiChat(request):
            // aiChat: outside /v3/ base — uses rootBase + path so .path is the single source of truth
            guard let url = URL(string: CDYelpURL.rootBase + path) else {
                throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            do {
                urlRequest.httpBody = try JSONEncoder().encode(request)
            } catch {
                throw CDYelpNetworkError.invalidRequest(underlying: error)
            }
            return urlRequest

        case let .jobs(query, locale):
            // jobs: POST + JSON body under /v3/ base
            guard let url = URL(string: CDYelpURL.base + path) else {
                throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            var body: [String: String] = ["query": query]
            if let locale { body["locale"] = locale }
            do {
                urlRequest.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw CDYelpNetworkError.invalidRequest(underlying: error)
            }
            return urlRequest

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
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
            return urlRequest
        }
    }

    /// Thrown when a Double query parameter is NaN or infinite and has no valid wire representation.
    struct NonFiniteQueryValueError: LocalizedError, Sendable {
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
            return params
        case let .transactions(_, params), let .business(_, params), let .reviews(_, params),
             let .event(_, params), let .categoryDetails(_, params), let .serviceOfferings(_, params),
             let .reviewHighlights(_, params), let .openings(_, params):
            return params
        case .aiChat, .jobs:
            return [:]
        }
    }
}
