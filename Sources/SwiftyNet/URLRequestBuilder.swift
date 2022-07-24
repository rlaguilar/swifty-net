import Foundation

public protocol URLRequestBuilder {
    func buildURLRequest(for request: Request) throws -> URLRequest
}

public struct BaseURLRequestBuilder: URLRequestBuilder {
    public var baseURL: URL

    private let encoder: JSONEncoder

    public init(baseURL: URL, encoder: JSONEncoder = JSONEncoder()) {
        self.baseURL = baseURL
        self.encoder = encoder
    }

    public func buildURLRequest(for request: Request) throws -> URLRequest {
        var components = URLComponents()
        components.path = request.path

        if !request.params.isEmpty { // avoids adding an extra `?` at the end of the url when there are no params.
            components.queryItems = request.params.map { param in
                URLQueryItem(name: param.key, value: "\(param.value)")
            }
        }

        guard let url = components.url(relativeTo: baseURL) else {
            throw SwiftyNetError.unableToBuildURLFromRequest
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.name

        switch request.method {
        case .get: break
        case .post(let body):
            urlRequest.httpBody = try encoder.encode(body)
        }

        return urlRequest
    }
}
