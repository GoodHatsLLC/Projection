// MARK: - Access

/// An Access provides some opaque access to an underlying `Value`.
///
/// An access should allow a consumer to check its validity prior to use.
@MainActor
public protocol Access<Value> {
    associatedtype Value
    var value: Value { get nonmutating set }
    func isValid() -> Bool
}

extension Access {

    public func erase() -> AnyAccess<Value> {
        AnyAccess(access: self)
    }

    public func any() -> any Access<Value> {
        self
    }
}
