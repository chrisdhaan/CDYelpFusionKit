import Foundation

enum CDYelpNativeRouter {
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
        // aiChat: hardcoded URL outside /v3/ base
        if case let .aiChat(request) = self {
            guard let url = URL(string: "https://api.yelp.com/ai/chat/v2") else {
                throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(request)
            return urlRequest
        }

        // jobs: POST + JSON body under /v3/ base
        if case let .jobs(query, locale) = self {
            guard let url = URL(string: CDYelpURL.base + path) else {
                throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            var body: [String: String] = ["query": query]
            if let locale { body["locale"] = locale }
            urlRequest.httpBody = try JSONEncoder().encode(body)
            return urlRequest
        }

        // All other cases: GET + URL query parameters
        guard var components = URLComponents(string: CDYelpURL.base + path) else {
            throw CDYelpNetworkError.invalidRequest(underlying: URLError(.badURL))
        }
        let params = queryParameters
        if !params.isEmpty {
            components.queryItems = params.map {
                URLQueryItem(name: $0.key, value: String(describing: $0.value))
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

    private var queryParameters: [String: Any] {
        switch self {
        case let .search(p), let .phone(p), let .matches(p),
             let .autocomplete(p), let .events(p), let .featuredEvent(p),
             let .allCategories(p), let .engagement(p), let .businessInsights(p):
            return p
        case .transactions(_, let p), .business(_, let p), .reviews(_, let p),
             .event(_, let p), .categoryDetails(_, let p), .serviceOfferings(_, let p),
             .reviewHighlights(_, let p), .openings(_, let p):
            return p
        case .aiChat, .jobs:
            return [:]
        }
    }
}
