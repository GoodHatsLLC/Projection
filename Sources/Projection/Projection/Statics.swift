extension Accessor {

  public static func proxy<V>(
    getter: @escaping () -> V,
    setter: @escaping (V) -> Void
  ) -> (proxy: Access.ProxyAccess<V>, projection: Projection<V>) {
    let proxy = Access.ProxyAccess(
      Access.CapturedAccess(
        getter: getter,
        setter: setter
      )
    )
    return (proxy: proxy, projection: .init(proxy))
  }

  public static func value<V>(_ value: V) -> Projection<V> {
    .init(Access.ValueAccess(value))
  }

  public static func constant<V>(_ value: V) -> Projection<V> {
    .init(Access.ConstantAccess(value))
  }

  public static func captured<V>(
    getter: @escaping () -> V,
    setter: @escaping (V) -> Void
  ) -> Projection<V> {
    .init(
      Access.CapturedAccess(
        getter: getter,
        setter: setter
      )
    )
  }

  public static func reference<T: AnyObject, V>(
    from: T,
    path: ReferenceWritableKeyPath<T, V>
  ) -> Projection<V> {
    .init(
      Access.ReferenceAccess(
        from: from,
        path: path
      )
    )
  }
}
