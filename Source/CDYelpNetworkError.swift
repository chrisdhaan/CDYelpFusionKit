import Foundation

public enum CDYelpNetworkError: Error, Sendable {
    case invalidRequest(underlying: Error)
    case httpError(statusCode: Int, data: Data)
    case decodingFailed(underlying: Error)
    case networkFailure(underlying: Error)
}
