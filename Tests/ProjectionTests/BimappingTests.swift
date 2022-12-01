import Foundation
import RegexBuilder
import XCTest
@testable import Projection

// MARK: - BimappingTests

@MainActor
final class BimappingTests: XCTestCase {

    var rootProjection: Projection<RootState>!

    var rootState: RootState {
        get { rootProjection.value }
        set { rootProjection.value = newValue }
    }

    override func setUpWithError() throws {
        rootProjection = .value(RootState())
    }

    func testObservableProjection_bimapping() throws {
        let bimapProjection = rootProjection
            .statefulMap(into: CompoundState()) { up, down in

                // Fully map the bbState and ccState fields across models
                up.aaState.bbState <-> down.bbState
                up.aaState.bbState.ccState <-> down.ccState

                let upAA = up.aaState.aa
                let upDD = up.aaState.bbState.ccState.ddState.dd
                let compound = upAA.join(upDD) { first, second in
                    "\(first) and \(second) joined"
                }

                compound --> down.compoundState
            }

        XCTAssertEqual(
            bimapProjection.compoundState.value,
            "\(rootProjection.aaState.aa.value) and \(rootProjection.aaState.bbState.ccState.ddState.dd.value) joined"
        )
    }
}
