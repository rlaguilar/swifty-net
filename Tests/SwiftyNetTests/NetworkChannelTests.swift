import Foundation
import XCTest
@testable import SwiftyNet

//TODO: Find out what to test in this particular class
final class NetworkChannelTests: XCTestCase {
    private let baseURL = URL(string: "http://example.com")!
    override class func setUp() {
        URLProtocol.registerClass(MockServer.self)
    }

    func testFoo() async throws {
        let channel = NetworkChannel(baseURL: baseURL)
        let expectedResponse = "response"
        inject(data: expectedResponse)
        let request = BaseRequest(path: "foo")

        let result: String = try await channel.send(request: request)

        XCTAssertEqual(result, expectedResponse)
    }

    private func inject(data: Encodable, response: URLResponse = HTTPURLResponse()) {
        MockServer.handleRequest = { _ in
                .success(.init(data: try! JSONEncoder().encode(data), urlResponse: response))
        }
    }

    private func inject(error: Error) {
        MockServer.handleRequest = { _ in
                .failure(error)
        }
    }
}
