import Foundation
import XCTest
@testable import SwiftyNet

final class URLRequestBuilderTests: XCTestCase {
    let baseURL = URL(string: "http://test.com/")!
    lazy var builder = BaseURLRequestBuilder(baseURL: baseURL)

    func testBuildURLRequest_WhenEmptyPath_CreatesRootURLRequest() throws {
        let request = BaseRequest(path: "")

        let urlRequest = try builder.buildURLRequest(for: request)

        XCTAssertEqual(urlRequest.url, baseURL)
    }

    func testBuildURLRequest_WhenSlashPath_CreatesRootURLRequest() throws {
        let request = BaseRequest(path: "/")

        let urlRequest = try builder.buildURLRequest(for: request)

        XCTAssertEqual(urlRequest.url, baseURL)
    }

    func testBuildURLRequest_WhenNonEmptyPath_PathIsIncludedInRequest() throws {
        let path = "/user/1"
        let request = BaseRequest(path: path)

        let urlRequest = try builder.buildURLRequest(for: request)

        XCTAssertEqual(urlRequest.url?.path, path)
    }

    func testBuildURLRequest_WhenNonEmptyParams_ParamsAreIncludedInRequest() throws {
        let request = BaseRequest(path: "", params: ["a": 1, "b": 2])

        let urlRequest = try builder.buildURLRequest(for: request)
        let components = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(components.queryItems?.count, 2)
        XCTAssert(components.queryItems!.contains(where: { $0.name == "a" && $0.value == "1" }))
        XCTAssert(components.queryItems!.contains(where: { $0.name == "b" && $0.value == "2" }))
    }

    func testBuildURLRequest_WhenPostMethod_IncludesBodyInRequest() throws {
        let body = ["key": "value"]
        let request = BaseRequest(path: "", method: .post(body))

        let urlRequest = try builder.buildURLRequest(for: request)

        XCTAssertEqual(urlRequest.httpBody, try JSONEncoder().encode(body))
    }

    func testBuildURLRequest_WhenPassedCustomEncoder_UsesIt() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let builderWithEncoder = BaseURLRequestBuilder(baseURL: baseURL, encoder: encoder)
        let body = ["key": Date()]
        let request = BaseRequest(path: "", method: .post(body))

        let urlRequest = try builderWithEncoder.buildURLRequest(for: request)

        XCTAssertEqual(urlRequest.httpBody, try encoder.encode(body))
    }

    func testBuildURLRequest_WhenSettingAllRequestValues_IncludesAllOfThemInRequest() throws {
        let path = "/user/1"
        let body = ["key": "value"]
        let request = BaseRequest(path: path, params: ["a": 1, "b": 2], method: .post(body))

        let urlRequest = try builder.buildURLRequest(for: request)
        let components = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(urlRequest.url?.path, path)
        XCTAssertEqual(components.queryItems?.count, 2)
        XCTAssert(components.queryItems!.contains(where: { $0.name == "a" && $0.value == "1" }))
        XCTAssert(components.queryItems!.contains(where: { $0.name == "b" && $0.value == "2" }))
        XCTAssertEqual(urlRequest.httpBody, try JSONEncoder().encode(body))
    }
}
