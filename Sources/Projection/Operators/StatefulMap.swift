
extension Projection {

    public func _statefulMap<Downstream>(
        into initial: Downstream,
        validity: Validity<Value> = .ifParent,
        biMap: Bimapper<Value, Downstream>
    ) -> Projection<Downstream> {
        let getMap = Transforming.StatefulBimap(
            map: biMap,
            upstream: self,
            downstream: Projecting.ValueAccess(initial)
        )
        return map(
            validity: validity,
            map: getMap
        )
    }

    public func statefulMap<Downstream>(
        into initial: Downstream,
        validity: Validity<Value> = .ifParent,
        @Bimapping<Value, Downstream> mapping: (
            _ up: Path<Value, Value>,
            _ down: Path<Downstream, Downstream>
        ) -> Bimapper<Value, Downstream>
    ) -> Projection<Downstream> {
        let biMap = mapping(
            Path(\Value.self),
            Path(\Downstream.self)
        )
        let getMap = Transforming.StatefulBimap(
            map: biMap,
            upstream: self,
            downstream: Projecting.ValueAccess(initial)
        )
        return map(
            validity: validity,
            map: getMap
        )
    }
}
