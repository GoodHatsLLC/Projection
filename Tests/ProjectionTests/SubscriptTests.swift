import Foundation
import XCTest
@testable import Projection

// MARK: - SubscriptTests

@MainActor
final class SubscriptTests: XCTestCase {

    var rootProjection: Projection<ArrayState>!

    override func setUpWithError() throws {
        rootProjection = .value(ArrayState(substates: []))
    }

    func testSubscript_invalidation() throws {
        rootProjection.value.substates = [
            .init(text: "zero"),
            .init(text: "one"),
            .init(text: "two"),
            .init(text: "three"),
            .init(text: "four")
        ]

        let fourProjection = rootProjection.substates[4]
        XCTAssertEqual(fourProjection.text.value, "four")
        XCTAssertEqual(fourProjection.isValid(), true)
        rootProjection.value.substates.removeLast()
        XCTAssertEqual(fourProjection.isValid(), false)
    }
}
