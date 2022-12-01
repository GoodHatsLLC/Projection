import Foundation

// MARK: - RootState

struct RootState: Codable & Equatable & Hashable & Sendable {
    var root = "root"
    var aaState = AState()
    var optionalTest = OptionalTest()
}

// MARK: - AState

struct AState: Codable & Equatable & Hashable & Sendable {
    var aa = "aa"
    var bbState = BState()
}

// MARK: - BState

struct BState: Codable & Equatable & Hashable & Sendable {
    var bb = "bb"
    var ccState = CState()
}

// MARK: - CState

struct CState: Codable & Equatable & Hashable & Sendable {
    var cc = "cc"
    var ddState = DState()
}

// MARK: - DState

struct DState: Codable & Equatable & Hashable & Sendable {
    var dd = "dd"
    var eeState = EState()
}

// MARK: - EState

struct EState: Codable & Equatable & Hashable & Sendable {
    var ee = "ee"
    var ffState = FState()
}

// MARK: - FState

struct FState: Codable & Equatable & Hashable & Sendable {
    var ff = "ff"
    var counter = 0
}

// MARK: - ArrayState

struct ArrayState: Codable & Equatable & Hashable & Sendable {
    struct Substate: Codable & Equatable & Hashable & Sendable {
        var text: String
    }

    var substates: [Substate]
}

// MARK: - OptionalTest

struct OptionalTest: Codable & Equatable & Hashable & Sendable {
    var optionalPresentState: OtherState? = .init(abc: "Optional", aaState: .init())
    var optionalNilState: OtherState? = nil
}

// MARK: - OtherState

struct OtherState: Codable & Equatable & Hashable & Sendable {
    var abc: String
    var aaState: AState
}

// MARK: - TestError

enum TestError: Error {
    case one
}
