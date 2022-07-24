public struct MergedRequestModifier: RequestModifier {
    public var modifiers: [RequestModifier]

    public init(modifiers: [RequestModifier] = []) {
        self.modifiers = modifiers
    }

    public mutating func append(modifier: RequestModifier) {
        modifiers.append(modifier)
    }

    public func modify(request: Request) -> Request {
        modifiers.reduce(BaseRequest(request)) { request, modifier in
            modifier.modify(request: request)
        }
    }
}
