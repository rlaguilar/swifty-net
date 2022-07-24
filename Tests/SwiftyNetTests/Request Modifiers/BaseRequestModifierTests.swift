import Foundation
import XCTest
@testable import SwiftyNet

final class BaseRequestModifierTests: XCTestCase {
    func testModify_WhenModifyingMethod_ChangesIt() throws {
        let body = "custom body"
        let modifier = BaseRequestModifier(methodModifier: { _ in .post(body) })
        let request = BaseRequest(path: "", method: .get)

        let newRequest = modifier.modify(request: request)

        switch newRequest.method {
        case .get:
            XCTFail()
        case .post(let newBody):
            XCTAssertEqual(try JSONEncoder().encode(newBody), try JSONEncoder().encode(body))
        }
    }

    func testModify_WhenModifyingPath_ChangesIt() throws {
        let modifier = BaseRequestModifier(pathModifier: { "hello, \($0)" })
        let request = BaseRequest(path: "world")

        let newRequest = modifier.modify(request: request)

        XCTAssertEqual(newRequest.path, "hello, world")
    }

    func testModify_WhenModifyingParams_ChangesThem() throws {
        let modifier = BaseRequestModifier(paramsModifier:  { params in
            var newParams = params
            newParams["b"] = 2
            return newParams
        })
        let request = BaseRequest(path: "", params: ["a": 1])

        let newRequest = modifier.modify(request: request)
        let newParams = newRequest.params as! [String: Int]

        XCTAssertEqual(newParams, ["a": 1, "b": 2])
    }
}
