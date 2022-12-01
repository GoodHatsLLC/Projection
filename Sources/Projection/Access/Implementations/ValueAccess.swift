extension Access {
  /// An ``Accessor`` which stores and provides a `Value`.
  @MainActor
  public final class ValueAccess<Value>: Accessor {
    public init(_ value: Value) {
      self.value = value
    }

    public var value: Value

    public func isValid() -> Bool { true }
  }
}
