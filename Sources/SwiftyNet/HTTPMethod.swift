public enum HTTPMethod {
    case get
    case post(Encodable)
}

extension HTTPMethod {
    var name: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
}
