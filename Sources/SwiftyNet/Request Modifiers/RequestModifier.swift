public protocol RequestModifier {
    func modify(request: Request) -> Request
}

public struct BaseRequestModifier: RequestModifier {
    let methodModifier: (HTTPMethod) -> HTTPMethod
    let pathModifier: (String) -> String
    let paramsModifier: (Request.Params) -> Request.Params

    public init(
        methodModifier: @escaping (HTTPMethod) -> HTTPMethod = { $0 },
        pathModifier: @escaping (String) -> String = { $0 },
        paramsModifier: @escaping (Request.Params) -> Request.Params = { $0 }
    ) {
        self.methodModifier = methodModifier
        self.pathModifier = pathModifier
        self.paramsModifier = paramsModifier
    }
    
    public func modify(request: Request) -> Request {
        return BaseRequest(
            path: pathModifier(request.path),
            params: paramsModifier(request.params),
            method: methodModifier(request.method)
        )
    }
}
