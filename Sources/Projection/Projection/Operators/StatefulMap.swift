extension Accessor {

  public func statefulMap<Downstream>(
    into initial: Downstream,
    isValid: @escaping (_ upstream: Value) -> Bool = { _ in true },
    @Bimapping<Value, Downstream> mapping: (
      _ up: Path<Value, Value>,
      _ down: Path<Downstream, Downstream>
    ) -> Update.Bimap<Value, Downstream>
  ) -> Projection<Downstream> {
    self
      .map(
        Transform.Stateful(
          map: mapping(
            Path(),
            Path()
          ),
          upstream: self,
          downstream: Access.ValueAccess(initial),
          isValid: isValid
        )
      )
  }
}
