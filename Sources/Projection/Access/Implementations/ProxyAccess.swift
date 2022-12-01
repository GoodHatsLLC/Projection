extension Access {
  /// A proxy layer over some other `Access` conformer.
  ///
  /// `ProxyAccess` allows its underlying `Access` to be swapped at runtime.
  @MainActor
  public final class ProxyAccess<Value>: Accessor {

    public init(
      _ access: some Accessor<Value>
    ) {
      self.access = access
    }

    public var value: Value {
      get { access.value }
      set { access.value = newValue }
    }

    public func isValid() -> Bool {
      access.isValid()
    }

    public func set(access: some Accessor<Value>) {
      self.access = access
    }

    private var access: any Accessor<Value>

  }
}
