import Foundation

public protocol NetworkChannelDelegate: AnyObject {
    func networkChannel(_ channel: NetworkChannel, willSend request: Request, identifier: String) throws

    func networkChannel(
        _ channel: NetworkChannel,
        didReceive response: (Data, URLResponse),
        for request: Request,
        identifier: String
    ) throws

    func networkChannel(
        _ channel: NetworkChannel,
        didReceive error: Error,
        for request: Request,
        identifier: String
    ) throws
}

public class NetworkChannel {
    private let urlRequestBuilder: URLRequestBuilder
    private let session: URLSession
    private let requestModifier: RequestModifier

    public weak var delegate: NetworkChannelDelegate?

    public init(
        urlRequestBuilder: URLRequestBuilder,
        session: URLSession = .shared,
        modifiers: [RequestModifier] = []
    ) {
        self.urlRequestBuilder = urlRequestBuilder
        self.session = session
        self.requestModifier = MergedRequestModifier(modifiers: modifiers)
    }

    public func send(request: Request) async throws -> (Data, URLResponse) {
        let urlRequest = try urlRequestBuilder.buildURLRequest(
            for: requestModifier.modify(request: request)
        )

        let identifier = UUID().uuidString
        try delegate?.networkChannel(self, willSend: request, identifier: identifier)

        let (data, urlResponse): (Data, URLResponse)

        do {
            (data, urlResponse) = try await session.data(for: urlRequest)
        } catch {
            try delegate?.networkChannel(self, didReceive: error, for: request, identifier: identifier)
            throw error
        }

        try delegate?.networkChannel(self, didReceive: (data, urlResponse), for: request, identifier: identifier)

        return (data, urlResponse)
    }
}

public extension NetworkChannel {
    convenience init(baseURL: URL) {
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
