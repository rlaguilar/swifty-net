import Foundation
import XCTest
@testable import SwiftyNet

final class HTTPMethodTests: XCTestCase {
    func testName_WhenMethodIsGet_ReturnsGET() {
        let method = HTTPMethod.get

        let name = method.name

        XCTAssertEqual(name, "GET")
    }

    func testName_WhenMethodIsPost_ReturnsPOST() {
        let method = HTTPMethod.post("")

        let name = method.name

        XCTAssertEqual(name, "POST")
    }
}
