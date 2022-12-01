/// An `Access` conformer which uses capturing closures to provide a `Value`.
@MainActor
public struct CapturedAccess<Value>: Access {

    public init(
        getter: @escaping () -> Value,
        setter: @escaping (_ value: Value) -> Void,
        isValid: @escaping () -> Bool = { true }
    ) {
        self.getter = getter
        self.setter = setter
        isValidFunc = isValid
    }

    public var value: Value {
        get { getter() }
        nonmutating set { setter(newValue) }
    }

    public func isValid() -> Bool { isValidFunc() }

    private let getter: () -> Value
    private let setter: (Value) -> Void
    private let isValidFunc: () -> Bool

}
