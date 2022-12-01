
// MARK: CompactMap
extension Projection {
    public func compact<Downstream>() -> Projection<Downstream>? where Value == Downstream? {
        value.map { _ in
            .init(
                upstream: self,
                validity: .condition({ $0 != nil }),
                map: Transforming.CapturedTransformer(
                    downwards: { upstream in
                        upstream!
                    }, upwards: { downstream in
                        downstream
                    }
                )
            )
        }
    }

    public func compactMap<Downstream>(
        downwards: @escaping (Value) -> Downstream?,
        upwards: @escaping (Downstream) -> Value
    ) -> Projection<Downstream>? where Value == Downstream? {
        map(
            downwards: downwards,
            upwards: { upstream, downstream in
                if let downstream {
                    upstream = upwards(downstream)
                }
            }
        )
        .compact()
    }

}
