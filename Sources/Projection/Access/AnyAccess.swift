/// A type erased ``Access``.
@MainActor
public struct AnyAccess<Value>: Access {

    init(access: some Access<Value>) {
        self.access = .init(
            getter: { access.value },
            setter: { access.value = $0 },
            isValid: { access.isValid() }
        )
    }

    public var value: Value {
        get { access.value }
        nonmutating set { access.value = newValue }
    }

    public func isValid() -> Bool {
        access.isValid()
    }

    public func erase() -> AnyAccess<Value> {
        self
    }

    private let access: Projecting.CapturedAccess<Value>

}
