import Foundation

/// @unchecked because the associated `underlying: Error` values may be concrete types from
/// user-provided `CDYelpRequestAdapter` implementations that are not verifiably `Sendable`
/// at compile time. The framework only stores `URLError`, `DecodingError`, and `EncodingError`
/// (all of which are `Sendable`) in the `.networkFailure`, `.decodingFailed`, and `.invalidRequest`
/// cases respectively — except when a custom adapter throws, in which case the caller is
/// responsible for ensuring the error is safe to cross actor or task boundaries.
public enum CDYelpNetworkError: Error, @unchecked Sendable {
    case invalidRequest(underlying: Error)
    case httpError(statusCode: Int, data: Data, headers: [String: String])
    case decodingFailed(underlying: Error)
    case networkFailure(underlying: Error)
}
