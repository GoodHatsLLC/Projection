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

    public func map<T>(
        validity: Validity<Value> = .ifParent,
        map: some GetMap<Value, T>
    ) -> Projection<T> {
        .init(
            upstream: self,
            validity: validity,
            map: map,
            mapValidity: .ifParent
        )
    }
}
