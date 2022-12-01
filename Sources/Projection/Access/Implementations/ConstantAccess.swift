extension Access {
  /// An `Access` conformer which provides a constant value.
  ///
  /// > Warning: `Access.ConstantAccess` ignores value setter calls.
  @MainActor
  public struct ConstantAccess<Value>: Accessor {

    public init(_ value: Value) {
      constant = value
    }

    private let constant: Value

    public var value: Value {
      get { constant }
      nonmutating set {}
    }

    public func isValid() -> Bool { true }
  }
}
