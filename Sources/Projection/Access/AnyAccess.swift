/// A type erased ``Access``.
@MainActor
public struct AnyAccess<Value>: Access {

    init(access: some Access<Value>) {
        isValidFunc = { access.isValid() }
        getFunc = { access.value }
        setFunc = { access.value = $0 }
    }

    init(
        isValid: @escaping @MainActor () -> Bool,
        getter: @escaping @MainActor () -> Value,
        setter: @escaping @MainActor (Value) -> Void
    ) {
        isValidFunc = isValid
        getFunc = getter
        setFunc = setter
    }

    public var value: Value {
        get { getFunc() }
        nonmutating set { setFunc(newValue) }
    }

    public func isValid() -> Bool {
        isValidFunc()
    }

    public func erase() -> AnyAccess<Value> {
        self
    }

    private let setFunc: @MainActor (Value) -> Void
    private let getFunc: @MainActor () -> Value
    private let isValidFunc: @MainActor () -> Bool

}
