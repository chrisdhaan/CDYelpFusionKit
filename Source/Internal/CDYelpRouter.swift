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
            return "transactions/\(type)/search"
        case let .business(id, _):
            return "businesses/\(id)"
        case .matches:
            return "businesses/matches"
        case let .reviews(id, _):
            return "businesses/\(id)/reviews"
        case .autocomplete:
            return "autocomplete"
        case let .event(id, _):
            return "events/\(id)"
        case .events:
            return "events"
        case .featuredEvent:
            return "events/featured"
        case .allCategories:
            return "categories"
        case let .categoryDetails(alias, _):
            return "categories/\(alias)"
        case .engagement:
            return "businesses/engagement"
        case let .serviceOfferings(id, _):
            return "businesses/\(id)/service_offerings"
        case .businessInsights:
            return "businesses/insights"
        case let .reviewHighlights(id, _):
            return "businesses/\(id)/review_highlights"
        case let .openings(businessId, _):
            return "bookings/\(businessId)/openings"
        case .aiChat:
            return "ai/chat/v2"
        case .jobs:
            return "jobs"
        }
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
                // All parameter values are String, Int, Double, or Bool — String(describing:) is correct for each.
                components.queryItems = queryParams.map {
                    URLQueryItem(name: $0.key, value: String(describing: $0.value))
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
