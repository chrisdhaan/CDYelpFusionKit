import Foundation

/// Observes CDYelpFusionKit request and response events.
public protocol CDYelpEventMonitor: AnyObject, Sendable {
    /// Called immediately before a URLRequest is sent.
    func requestDidStart(urlRequest: URLRequest)
    /// Called when a response is received, before decoding.
    func requestDidComplete(urlRequest: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?)
}

public extension CDYelpEventMonitor {
    func requestDidStart(urlRequest _: URLRequest) {}
    func requestDidComplete(urlRequest _: URLRequest?, response _: HTTPURLResponse?, data _: Data?, error _: Error?) {}
}
