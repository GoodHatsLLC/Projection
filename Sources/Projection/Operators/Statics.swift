
extension Projection {

    public static func proxy<V>(
        getter: @escaping () -> V,
        setter: @escaping (V) -> Void
    ) -> (proxy: Projecting.ProxyAccess<V>, projection: Projection<V>) {
        let proxy = Projecting.ProxyAccess(
            Projecting.CapturedAccess(
                getter: getter,
                setter: setter
            )
        )
        return (proxy: proxy, projection: .init(proxy))
    }

    public static func value<V>(_ value: V) -> Projection<V> {
        .init(Projecting.ValueAccess(value))
    }

    public static func constant<V>(_ value: V) -> Projection<V> {
        .init(Projecting.ConstantAccess(value))
    }

    public static func captured<V>(
        getter: @escaping () -> V,
        setter: @escaping (V) -> Void
    ) -> Projection<V> {
        .init(
            Projecting.CapturedAccess(
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
            Projecting.ReferenceAccess(
                from: from,
                path: path
            )
        )
    }
}
