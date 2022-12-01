// MARK: - Access

/// An `Accessor` provides some opaque access to an underlying `Value`.
///
/// An `Access` should allow a consumer to check its validity prior to use.
@MainActor
public protocol Accessor<Value>: Validateable {
  associatedtype Value
  var value: Value { get nonmutating set }
  func isValid() -> Bool
}

public enum Access {}
