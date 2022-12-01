import Projection
import XCTest

// MARK: - BenchmarkTests

@MainActor
final class BenchmarkTests: XCTestCase {

    var nested: Nested.Value = .end

    override func setUpWithError() throws {
        nested = .recurse(Nested(depth: 1000))
    }

    override func tearDownWithError() throws {
        nested = .end
    }

    func test_projectionPerformance() throws {
        measure { // Time: 0.725 sec
            let projection = Projection<Nested.Value>() {
                self.nested
            } setter: { value in
                self.nested = value
            }
            var next: Projection<Nested?> = projection.nested
            while next.value != nil {
                if let recurse = next.compact()?.recurse.nested {
                    next = recurse
                }
            }
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI
extension BenchmarkTests {
    func testBindingPerformance() throws {
        measure { // Time: 0.629 sec
            let projection = Binding {
                self.nested
            } set: { value in
                self.nested = value
            }
            var next: Binding<Nested?> = projection.nested
            while next.wrappedValue != nil {
                if let recurse = Binding<Nested>(next)?.recurse.nested {
                    next = recurse
                }
            }
        }
    }
}
#endif

// MARK: - Nested

final class Nested {
    init(depth: Int) {
        if depth > 0 {
            recurse = .recurse(Nested(depth: depth - 1))
        } else {
            recurse = .end
        }
    }

    enum Value {
        case recurse(Nested)
        case end

        var nested: Nested? {
            get {
                switch self {
                case .recurse(let nested): return nested
                case .end: return nil
                }
            }
            set {
                self = newValue.map { .recurse($0) } ?? .end
            }
        }
    }

    var one = 1
    var two = 2
    var recurse: Value

    var isEnd: Bool {
        switch recurse {
        case .end: return true
        case .recurse: return false
        }
    }
}
