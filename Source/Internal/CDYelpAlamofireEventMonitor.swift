import Alamofire
import Foundation

final class CDYelpAlamofireEventMonitor: EventMonitor {
    let monitors: [any CDYelpEventMonitor]

    init(monitors: [any CDYelpEventMonitor]) {
        self.monitors = monitors
    }

    func requestDidResume(_ request: Request) {
        guard let urlRequest = request.request else { return }
        for monitor in monitors {
            monitor.requestDidStart(urlRequest: urlRequest)
        }
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        for monitor in monitors {
            monitor.requestDidComplete(
                urlRequest: request.request,
                response: response.response,
                data: response.data,
                error: response.error
            )
        }
    }
}
