
// MARK: Join

extension Projection {
    public func join<OtherValue>(
        _ other: some Access<OtherValue>
    ) -> Projection<Tuple.Size2<Value, OtherValue>> {
        .init(
            upstream: Projecting.Tuple.SizeTwo(a: self, b: other),
            validity: .ifParent,
            map: Transforming.PassthroughTransformer()
        )
    }

    public func joinTwo<OtherValueOne, OtherValueTwo>(
        _ otherOne: some Access<OtherValueOne>,
        _ otherTwo: some Access<OtherValueTwo>
    ) -> Projection<Tuple.Size3<Value, OtherValueOne, OtherValueTwo>> {
        .init(
            upstream: Projecting.Tuple.SizeThree(a: self, b: otherOne, c: otherTwo),
            validity: .ifParent,
            map: Transforming.PassthroughTransformer()
        )
    }
}
