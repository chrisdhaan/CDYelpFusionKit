import Foundation

/// Adapts a URLRequest before it is sent by CDYelpFusionKit.
public protocol CDYelpRequestAdapter: AnyObject, Sendable {
    /// Mutate and return the request. Return the request unchanged to pass it through.
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest
}
