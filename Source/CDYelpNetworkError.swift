import Foundation

/// @unchecked because Error is not Sendable; callers are responsible for ensuring any
/// underlying error stored in .invalidRequest (which may come from a custom CDYelpRequestAdapter)
/// is itself Sendable before crossing actor or task boundaries.
public enum CDYelpNetworkError: Error, @unchecked Sendable {
    case invalidRequest(underlying: Error)
    case httpError(statusCode: Int, data: Data)
    case decodingFailed(underlying: Error)
    case networkFailure(underlying: Error)
}
