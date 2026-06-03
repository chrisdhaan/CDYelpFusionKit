import Alamofire
import Foundation

final class CDYelpAlamofireRequestAdapter: RequestAdapter {
    let adapters: [any CDYelpRequestAdapter]

    init(adapters: [any CDYelpRequestAdapter]) {
        self.adapters = adapters
    }

    func adapt(_ urlRequest: URLRequest, for _: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        do {
            for adapter in adapters {
                request = try adapter.adapt(request)
            }
            completion(.success(request))
        } catch {
            completion(.failure(error))
        }
    }
}
