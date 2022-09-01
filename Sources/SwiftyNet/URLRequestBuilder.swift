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
        var urlRequest = try URLRequest(
            url: request.url(baseURL: baseURL)
        )
        try urlRequest.set(method: request.method, using: encoder)
        return urlRequest
    }
}

extension Request {
    func url(baseURL: URL) throws -> URL {
        var components = URLComponents()
        components.path = path

        if !params.isEmpty { // avoids adding an extra `?` at the end of the url when there are no params.
            components.queryItems = params.map { param in
                URLQueryItem(name: param.key, value: "\(param.value)")
            }
        }

        guard let url = components.url(relativeTo: baseURL) else {
            throw SwiftyNetError.unableToBuildURLFromRequest
        }

        return url
    }
}

extension URLRequest {
    mutating func set(method: HTTPMethod, using encoder: JSONEncoder) throws {
        self.httpMethod = method.name

        switch method {
        case .get: break
        case .post(let body):
            self.httpBody = try encoder.encode(body)
        }
    }
}
