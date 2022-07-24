import Foundation

public struct NetworkChannel {
    private let urlRequestBuilder: URLRequestBuilder
    private let session: URLSession
    private let requestModifier: RequestModifier

    public init(
        urlRequestBuilder: URLRequestBuilder,
        session: URLSession = .shared,
        modifiers: [RequestModifier] = []
    ) {
        self.urlRequestBuilder = urlRequestBuilder
        self.session = session
        self.requestModifier = MergedRequestModifier(modifiers: modifiers)
    }

    public func send(request: Request) async throws -> (Data, HTTPURLResponse) {
        let urlRequest = try urlRequestBuilder.buildURLRequest(
            for: requestModifier.modify(request: request)
        )

        let (data, urlResponse) = try await session.data(for: urlRequest)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw SwiftNetError.invalidURLResponse
        }

        return (data, httpResponse)
    }
}

public extension NetworkChannel {
    init(baseURL: URL) {
        self.init(urlRequestBuilder: BaseURLRequestBuilder(baseURL: baseURL))
    }

    func send<Value>(
        request: Request,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> Value where Value: Decodable {
        let (data, _) = try await send(request: request)
        return try decoder.decode(Value.self, from: data)
    }
}
