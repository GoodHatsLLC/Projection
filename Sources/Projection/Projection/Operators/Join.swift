// MARK: Join

extension Accessor {
  public func join<OtherValue>(
    _ other: some Accessor<OtherValue>
  ) -> Projection<Tuple.Size2<Value, OtherValue>> {
    .init(
      upstream: Access.Tuple.SizeTwo(a: self, b: other),
      map: Transform.Passthrough()
    )
  }

  public func joinTwo<OtherValueOne, OtherValueTwo>(
    _ otherOne: some Accessor<OtherValueOne>,
    _ otherTwo: some Accessor<OtherValueTwo>
  ) -> Projection<Tuple.Size3<Value, OtherValueOne, OtherValueTwo>> {
    .init(
      upstream: Access.Tuple.SizeThree(a: self, b: otherOne, c: otherTwo),
      map: Transform.Passthrough()
    )
  }
}
