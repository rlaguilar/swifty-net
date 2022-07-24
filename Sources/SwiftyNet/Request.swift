import Foundation

public protocol Request {
    typealias Params = [String: Any]

    var path: String { get }
    var params: Params { get }
    var method: HTTPMethod { get }
}

public struct BaseRequest: Request {
    public var path: String

    public var params: Params

    public var method: HTTPMethod

    public init(path: String, params: Params = [:], method: HTTPMethod = .get) {
        self.path = path
        self.params = params
        self.method = method
    }
}

public extension BaseRequest {
    init(_ request: Request) {
        self.init(path: request.path, params: request.params, method: request.method)
    }
}
