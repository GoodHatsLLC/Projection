import Foundation
import XCTest
@testable import Projection

// MARK: - InvalidHandlingTests

@MainActor
final class InvalidHandlingTests: XCTestCase {

    var rootProjection: Projection<RootState>!

    var rootState: RootState {
        get { rootProjection.value }
        set { rootProjection.value = newValue }
    }

    override func setUpWithError() throws {
        rootProjection = .value(RootState())
    }

    func testProjection_compactMap() throws {
        let next = rootProjection.optionalTest

        XCTAssertNil(next.optionalNilState.compact())
        XCTAssertNotNil(next.optionalPresentState.compact()?.abc)

        let avail = try XCTUnwrap(next.optionalPresentState.compact()?.abc)
        avail.value = "some value yep"

        XCTAssertEqual(rootState.optionalTest.optionalPresentState?.abc, "some value yep")

        next.value.optionalNilState = next.optionalPresentState.value

        XCTAssertEqual(rootState.optionalTest.optionalNilState?.abc, "some value yep")
    }

    func testProjection_cachedDisconnectedConnections() throws {
        var shouldFail = false

        // create a controllable further projection from root
        let next = rootProjection
            .statefulMap(
                into: OtherState(abc: "HELLO", aaState: rootProjection.value.aaState),
                validity: .condition({ _ in !shouldFail })
            ) { from, to in
                from.aaState <-> to.aaState
            }

        // use this connection to modify root successfully
        next.aaState.aa.value = "other-aa"

        XCTAssertEqual(rootProjection.aaState.aa.value, "other-aa")
        XCTAssertEqual(rootState.aaState.aa, "other-aa")

        // set the further connection to fail
        shouldFail = true

        // modify root via initial connection successfully
        rootProjection.aaState.aa.value = "oops"
        XCTAssertEqual(rootState.aaState.aa, "oops")
        // show the connection is still working
        XCTAssertEqual(rootProjection.aaState.aa.value, "oops")
        XCTAssertTrue(rootProjection.isValid())

        // see the further connection is broken
        XCTAssertFalse(next.isValid())
        // but the initial connection is still good
        XCTAssertTrue(rootProjection.isValid())

        // un-break the connection for future reads
        shouldFail = false

        // but see the real value is read
        XCTAssertEqual(next.aaState.aa.value, "oops")
        // and the connection not broken
        XCTAssert(next.isValid())

        // write to the unbroken connection successfully
        next.aaState.aa.value = "yolo-aa"
        XCTAssertEqual(next.aaState.aa.value, "yolo-aa")
        // and the root state and initial connection is updated
        XCTAssertEqual(rootProjection.aaState.aa.value, "yolo-aa")

        // show the initial connection is still active and still doesn't modify the broken projection.
        rootProjection.aaState.aa.value = "we did it again"
        XCTAssertEqual(rootState.aaState.aa, "we did it again")
        XCTAssertEqual(rootProjection.aaState.aa.value, "we did it again")
        XCTAssertEqual(next.aaState.aa.value, "we did it again")

        let furtherYet = next.aaState.bbState.ccState
        XCTAssert(furtherYet.isValid())
    }

}
