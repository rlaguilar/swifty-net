import Foundation

class MockServer: URLProtocol {
    struct Response {
        let data: Data
        let urlResponse: URLResponse
    }

    static var handleRequest: (URLRequest) -> Result<Response, Error> = { _ in fatalError() }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let result = Self.handleRequest(request)

        switch result {
        case .success(let response):
            client?.urlProtocol(self, didReceive: response.urlResponse, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: response.data)
            client?.urlProtocolDidFinishLoading(self)
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        
    }
}
