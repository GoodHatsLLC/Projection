extension Access {
  /// An `Access` conformer which uses capturing closures to provide a `Value`.
  @MainActor
  public struct CapturedAccess<Value>: Accessor {

    public init(_ access: some Accessor<Value>) {
      getterFunc = { access.value }
      setterFunc = { access.value = $0 }
      isValidFunc = { access.isValid() }
    }

    public init(_ access: CapturedAccess<Value>) {
      getterFunc = access.getterFunc
      setterFunc = access.setterFunc
      isValidFunc = access.isValidFunc
    }

    public init(
      getter: @escaping () -> Value,
      setter: @escaping (_ value: Value) -> Void,
      isValid: @escaping () -> Bool = { true }
    ) {
      getterFunc = getter
      setterFunc = setter
      isValidFunc = isValid
    }

    public var value: Value {
      get { getterFunc() }
      nonmutating set { setterFunc(newValue) }
    }

    public func isValid() -> Bool { isValidFunc() }
    public func erase() -> CapturedAccess<Value> { self }

    private let getterFunc: () -> Value
    private let setterFunc: (Value) -> Void
    private let isValidFunc: () -> Bool

  }
}
