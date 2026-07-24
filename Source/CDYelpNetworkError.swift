import Foundation

/// @unchecked because the associated `underlying: Error` values may be concrete types from
/// user-provided `CDYelpRequestAdapter` implementations that are not verifiably `Sendable`
/// at compile time. The framework itself only stores `Sendable` types: `URLError` (transport
/// failures, and bad-URL construction failures from `CDYelpRouter`), `EncodingError`
/// (JSON body encoding failures), `CDYelpRouter.NonFiniteQueryValueError` (a NaN/Infinite
/// query parameter), `DecodingError` (response decoding failures), and `CancellationError`
/// (a retry-backoff sleep cancelled via `cancelAllPendingAPIRequests()` or ambient task
/// cancellation) — except when a custom adapter throws, in which case the caller is
/// responsible for ensuring the error is safe to cross actor or task boundaries.
public enum CDYelpNetworkError: Error, @unchecked Sendable {
    case invalidRequest(underlying: Error)
    case httpError(statusCode: Int, data: Data, headers: [String: String])
    case decodingFailed(underlying: Error)
    case networkFailure(underlying: Error)
}
