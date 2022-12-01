extension Projection {

  public init<T>(
    _ path: ReferenceWritableKeyPath<T, Value>,
    on reference: T,
    isValid: @escaping @autoclosure () -> Bool = true
  ) {
    self = .init(
      Access.CapturedAccess(
        getter: {
          reference[keyPath: path]
        },
        setter: {
          reference[keyPath: path] = $0
        },
        isValid: isValid
      )
    )
  }

  public init(
    isValid: @escaping @autoclosure () -> Bool = true,
    getter: @escaping () -> Value,
    setter: @escaping (_ value: Value) -> Void
  ) {
    self = .init(
      Access.CapturedAccess(
        getter: getter,
        setter: setter,
        isValid: isValid
      )
    )
  }

  public init<Upstream>(
    upstream: some Accessor<Upstream>,
    map: some Transformer<Upstream, Value>
  ) {
    self = .init(
      Access.CapturedAccess(
        getter: {
          map.downstream(
            from: upstream.value
          )
        },
        setter: { newValue in
          upstream.value =
            map
            .upstream(
              from: newValue
            )
        },
        isValid: {
          upstream
            .isValid()
            && map
              .isValid(
                given: upstream.value
              )
        }
      )
    )
  }
}
