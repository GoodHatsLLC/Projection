import Foundation
import XCTest
@testable import Projection

// MARK: - ProjectionTests

@MainActor
final class ProjectionTests: XCTestCase {

    var rootProjection: Projection<RootState>!

    var rootState: RootState {
        get { rootProjection.value }
        set { rootProjection.value = newValue }
    }

    override func setUpWithError() throws {
        rootProjection = .value(RootState())
    }

    func testObservableProjection_basicAccess() throws {
        XCTAssertEqual(rootProjection.value.root, "root")
        XCTAssertEqual(rootProjection.root.value, "root")
    }

    func testObservableProjection_basicEdit() throws {
        rootProjection.value.root = "new-root"
        XCTAssertEqual(rootState.root, "new-root")
        XCTAssertEqual(rootProjection.root.value, "new-root")
    }

    func testObservableProjection_selectedAccess() throws {
        let aaBinding = rootProjection.aaState
        XCTAssertEqual(aaBinding.aa.value, "aa")
    }

    func testObservableProjection_selectedEdit() throws {
        let aaBinding = rootProjection.aaState
        aaBinding.value.aa = "AA"
        XCTAssertEqual(rootState.aaState.aa, "AA")
    }

    func testObservableProjection_deeplyNestedSelectors() throws {
        let aaBinding = rootProjection.aaState
        let bbBinding = aaBinding.bbState
        let ccBinding = bbBinding.ccState
        let ddBinding = ccBinding.ddState
        let eeBinding = ddBinding.eeState
        let ffBinding = eeBinding.ffState
        let ffDirect = ffBinding.ff
        XCTAssertEqual(ffDirect.value, "ff")
    }

    func testObservableProjection_deeplyNestedEdit() throws {
        let aaBinding = rootProjection.aaState
        let bbBinding = aaBinding.bbState
        let ccBinding = bbBinding.ccState
        let ddBinding = ccBinding.ddState
        let eeBinding = ddBinding.eeState
        let ffBinding = eeBinding.ffState
        let ffDirect = ffBinding.ff
        ffDirect.value = "FF"
        XCTAssertEqual(
            rootState.aaState.bbState.ccState.ddState.eeState.ffState.ff,
            "FF"
        )
    }

    func testObservableProjection_deeplyNestedView_rootEdit() throws {
        let aaBinding = rootProjection.aaState
        let bbBinding = aaBinding.bbState
        let ccBinding = bbBinding.ccState
        let ddBinding = ccBinding.ddState
        let eeBinding = ddBinding.eeState
        let ffBinding = eeBinding.ffState
        let ffDirect = ffBinding.ff
        rootState.aaState.bbState.ccState.ddState.eeState.ffState.ff = "FF"
        XCTAssertEqual(
            ffDirect.value,
            "FF"
        )
    }

    func testProjection_indexingWriteToRoot() throws {
        var arrayState = ArrayState(
            substates: [
                .init(text: "one"),
                .init(text: "two"),
                .init(text: "three"),
                .init(text: "four"),
            ]
        )
        let rootProjection: Projection<ArrayState> = .captured(
            getter: { arrayState },
            setter: { arrayState = $0 }
        )

        rootProjection.substates[0].value.text = "HELLO"
        XCTAssertEqual(arrayState.substates[0].text, "HELLO")
    }

    func testProjection_indexingReadFromLeaf() throws {
        var arrayState = ArrayState(
            substates: [
                .init(text: "one"),
                .init(text: "two"),
                .init(text: "three"),
                .init(text: "four"),
            ]
        )
        let rootProjection: Projection<ArrayState> = .captured(
            getter: { arrayState },
            setter: { arrayState = $0 }
        )
        let leafProjection = rootProjection.substates[2].text
        rootProjection.substates[2].text.value = "HELLO"
        XCTAssertEqual(leafProjection.value, "HELLO")

        leafProjection.value = "YOLO"
        XCTAssertEqual(rootProjection.substates[2].text.value, "YOLO")
    }

    func testProjection_additiveMapping() throws {
        let next = rootProjection
            ._statefulMap(
                into: OtherState(
                    abc: "Hello",
                    aaState: rootProjection.value.aaState
                )
            ) { from, to in
                from.aaState <-> to.aaState
            }

        rootProjection.aaState.aa.value = "new-aa"
        XCTAssertEqual(rootState.aaState.aa, "new-aa")
        XCTAssertEqual(next.aaState.aa.value, "new-aa")

        next.aaState.aa.value = "other-aa"

        XCTAssertEqual(rootProjection.aaState.aa.value, "other-aa")
        XCTAssertEqual(rootState.aaState.aa, "other-aa")
    }

}
