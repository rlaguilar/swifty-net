import Foundation
import XCTest
@testable import SwiftyNet

final class MergedRequestModifierTests: XCTestCase {
    func testModify_WhenCombiningMultipleModifiers_ApplyAllChanges() {
        let modifier = MergedRequestModifier(modifiers: [
            BaseRequestModifier(pathModifier: { "a \($0)" }),
            BaseRequestModifier(pathModifier: { "\($0) c" } )
        ])

        let request = BaseRequest(path: "b")
        let newRequest = modifier.modify(request: request)

        XCTAssertEqual(newRequest.path, "a b c")
    }

    func testModify_WhenCombiningMultipleModifiers_ApplyThemInOrder() {
        let modifier = MergedRequestModifier(modifiers: [
            BaseRequestModifier(pathModifier: { "\($0) b" }),
            BaseRequestModifier(pathModifier: { "\($0) c" } )
        ])

        let request = BaseRequest(path: "a")
        let newRequest = modifier.modify(request: request)

        XCTAssertEqual(newRequest.path, "a b c")
    }
}
