
// MARK: - dynamiceMember

extension Projection {

    public subscript<Downstream>(
        dynamicMember keyPath: WritableKeyPath<Value, Downstream>
    ) -> Projection<Downstream> {
        map(keyPath)
    }

    public subscript<Upstream, Downstream>(
        dynamicMember keyPath: WritableKeyPath<Upstream, Downstream>
    ) -> Projection<Downstream>? where Upstream? == Value {
        map { value in
            value.map { $0[keyPath: keyPath] }
        } upwards: { upstream, downstream in
            if var up = upstream, let downstream {
                up[keyPath: keyPath] = downstream
                upstream = up
            }
        }
        .compact()
    }

}
