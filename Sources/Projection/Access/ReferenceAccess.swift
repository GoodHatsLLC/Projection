/// An `Access` conformer which provides an object's field as its `Value`.
@MainActor
public struct ReferenceAccess<Value>: Access {

    public init<T: AnyObject>(from: T, path: ReferenceWritableKeyPath<T, Value>) {
        getter = {
            from[keyPath: path]
        }
        setter = {
            from[keyPath: path] = $0
        }
    }

    private let getter: () -> Value
    private let setter: (Value) -> Void

    public var value: Value {
        get { getter() }
        nonmutating set { setter(newValue) }
    }

    public func isValid() -> Bool { true }
}
