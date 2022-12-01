public typealias AnyAccess<Value> = Access.CapturedAccess<Value>

extension Accessor {

  public func erase() -> AnyAccess<Value> {
    AnyAccess(self)
  }

  public func any() -> any Accessor<Value> {
    self
  }
}
