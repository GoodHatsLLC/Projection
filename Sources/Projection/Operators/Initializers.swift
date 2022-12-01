
extension Projection {

    public init<T>(
        _ path: ReferenceWritableKeyPath<T, Value>,
        on reference: T,
        isValid: @escaping @autoclosure () -> Bool = true
    ) {
        self = .init(
            Projecting.CapturedAccess(
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
            Projecting.CapturedAccess(
                getter: getter,
                setter: setter,
                isValid: isValid
            )
        )
    }

    public init<Upstream>(
        upstream: some Access<Upstream>,
        validity: Validity<Upstream> = .ifParent,
        map: some Transformer<Upstream, Value>,
        mapValidity: Validity<Value> = .ifParent
    ) {
        self = .init(
            Projecting.CapturedAccess(
                getter: {
                    map.downstream(
                        from: upstream.value
                    )
                },
                setter: { newValue in
                    upstream.value = map
                        .upstream(
                            from: newValue
                        )
                },
                isValid: {
                    guard upstream.isValid()
                    else {
                        return false
                    }
                    let initialValidity: Bool
                    switch validity {
                    case .ifParent:
                        initialValidity = true
                    case .condition(let condition):
                        initialValidity = condition(upstream.value)
                    }
                    if !initialValidity {
                        return false
                    }
                    switch mapValidity {
                    case .ifParent:
                        return true
                    case .condition(let condition):
                        return condition(
                            map.downstream(
                                from: upstream.value
                            )
                        )
                    }
                }
            )
        )
    }
}
