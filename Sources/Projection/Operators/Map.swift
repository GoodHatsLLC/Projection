
extension Access {
    public func map<T>(
        validity: Validity<Value> = .ifParent,
        map: some Transformer<Value, T>
    ) -> Projection<T> {
        .init(
            upstream: self,
            validity: validity,
            map: map,
            mapValidity: .ifParent
        )
    }
}

// MARK: Map
extension Projection {

    public func map<Downstream>(
        validity: Validity<Value> = .ifParent,
        downwards: @escaping (
            _ upstream: Value
        ) -> Downstream,
        upwards: @escaping (
            _ varUpstream: inout Value,
            _ downstream: Downstream
        ) -> Void
    ) -> Projection<Downstream> {
        .init(
            upstream: self,
            validity: validity,
            map: Transforming.CapturedTransformer(
                downwards: downwards,
                upwards: { downstream in
                    var upstream = value
                    upwards(&upstream, downstream)
                    return upstream
                }
            )
        )
    }

    public func map<Downstream>(
        validity: Validity<Value> = .ifParent,
        _ keyPath: WritableKeyPath<Value, Downstream>
    ) -> Projection<Downstream> {
        .init(
            upstream: self,
            validity: validity,
            map: Transforming.CapturedTransformer(
                downwards: { upstream in
                    upstream[keyPath: keyPath]
                }, upwards: { downstream in
                    var value = value
                    value[keyPath: keyPath] = downstream
                    return value
                }
            )
        )
    }

    public func map<Downstream>(
        validity: Validity<Value> = .ifParent,
        map: some Transformer<Value, Downstream>
    ) -> Projection<Downstream> {
        .init(
            upstream: self,
            validity: validity,
            map: map,
            mapValidity: .ifParent
        )
    }
}
