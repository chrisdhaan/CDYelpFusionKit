import Foundation

// @unchecked because Error is not Sendable; the stored errors are always URLError or DecodingError, both of which are Sendable.
public enum CDYelpNetworkError: Error, @unchecked Sendable {
    case invalidRequest(underlying: Error)
    case httpError(statusCode: Int, data: Data)
    case decodingFailed(underlying: Error)
    case networkFailure(underlying: Error)
}
