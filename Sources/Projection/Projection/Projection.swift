import Bimapping

// MARK: - Projection

/// A `Projection` is an `Access` conformer providing many of the
/// properties of a SwiftUI `Binding`.
///
/// A projection uses some other `Access` conformer as its root
/// value access. When an operator is performed on the projection
/// a new projection is made which performs some 'projection' from
/// the last. This 'projection' function may only be valid in some
/// subset of cases.
///
/// i.e. A `Projection` is a SwiftUI `Binding` that:
/// - Has a customizable source
/// - May only be conditionally valid
/// - Can be checked for validity prior to access via `isValid()`
///
/// In loosening the constrains imposed on a SwiftUI `Binding`
/// Projections can safely be made to implement useful operators
/// not available to `Bindings`.
///
/// Operators available on `Projections` and not on `Bindings` include:
/// - `compactMap`
/// - `first`
/// - `filter`
@MainActor
@dynamicMemberLookup
public struct Projection<Value>: Access {
    public init<Upstream>(
        upstream: some Access<Upstream>,
        validity: Validity<Upstream> = .ifParent,
        map: some GetMap<Upstream, Value>,
        mapValidity: Validity<Value> = .ifParent
    ) {
        self = .init(
            AnyAccess(
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
                        return condition(map.downstream(from: upstream.value))
                    }
                },
                getter: { map.downstream(from: upstream.value) },
                setter: { newValue in
                    upstream.value = map.upstream(from: newValue)
                }
            )
        )
    }

    public init(_ access: some Access<Value>) {
        self.proxy = ProxyAccess(access)
    }

    public init(
        get getter: @escaping () -> Value,
        set setter: @escaping (_ value: Value) -> Void,
        isValid: @escaping () -> Bool = { true }
    ) {
        self = .init(
            CapturedAccess(
                getter: getter,
                setter: setter,
                isValid: isValid
            )
        )
    }

    public var value: Value {
        get { proxy.value }
        nonmutating set { proxy.value = newValue }
    }

    public func isValid() -> Bool {
        proxy.isValid()
    }

    public func set(access newAccess: some Access<Value>) {
        proxy.set(access: newAccess)
    }

    private var proxy: ProxyAccess<Value>

}

extension Projection {
    public static func value<V>(_ value: V) -> Projection<V> {
        ValueAccess(value)
            .map(map: PassthroughMap())
    }

    public static func constant<V>(_ value: V) -> Projection<V> {
        ConstantAccess(value)
            .map(map: PassthroughMap())
    }

    public static func captured<V>(
        getter: @escaping () -> V,
        setter: @escaping (V) -> Void
    ) -> Projection<V> {
        CapturedAccess(getter: getter, setter: setter)
            .map(map: PassthroughMap())
    }

    public static func reference<T: AnyObject, V>(
        from: T,
        path: ReferenceWritableKeyPath<T, V>
    ) -> Projection<V> {
        ReferenceAccess(from: from, path: path)
            .map(map: PassthroughMap())
    }
}

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

// MARK: Map
extension Projection {

    public func map<Downstream>(
        validity: Validity<Value> = .ifParent,
        downwards: @escaping (_ upstream: Value) -> Downstream,
        upwards: @escaping (_ varUpstream: inout Value, _ downstream: Downstream) -> Void
    ) -> Projection<Downstream> {
        .init(
            upstream: self,
            validity: validity,
            map: PureMap(
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
            map: PureMap(
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
        map: some GetMap<Value, Downstream>
    ) -> Projection<Downstream> {
        .init(
            upstream: self,
            validity: validity,
            map: map,
            mapValidity: .ifParent
        )
    }

    public func _statefulMap<Downstream>(
        into initial: Downstream,
        validity: Validity<Value> = .ifParent,
        biMap: Bimapper<Value, Downstream>
    ) -> Projection<Downstream> {
        let getMap = AccessingBimap(
            map: biMap,
            upstream: self,
            downstream: ValueAccess(initial)
        )
        return map(
            validity: validity,
            map: getMap
        )
    }

    public func _statefulMap<Downstream>(
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
        let getMap = AccessingBimap(
            map: biMap,
            upstream: self,
            downstream: ValueAccess(initial)
        )
        return map(
            validity: validity,
            map: getMap
        )
    }

}

// MARK: CompactMap
extension Projection {
    public func compact<Downstream>() -> Projection<Downstream>? where Value == Downstream? {
        value.map { _ in
            .init(
                upstream: self,
                validity: .condition({ $0 != nil }),
                map: PureMap(
                    downwards: { upstream in
                        upstream!
                    }, upwards: { downstream in
                        downstream
                    }
                )
            )
        }
    }

    public func replaceNil<Downstream>(default defaultValue: Downstream) -> Projection<Downstream>
        where Value == Downstream? {
        map { upstream in
            upstream ?? defaultValue
        } upwards: { varUpstream, downstream in
            varUpstream = downstream
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

// MARK: Join

extension Projection {
    public func join<OtherValue>(
        _ other: some Access<OtherValue>
    ) -> Projection<Tuple.Size2<Value, OtherValue>> {
        .init(
            upstream: TupleAccess.SizeTwo(a: self, b: other),
            validity: .ifParent,
            map: PassthroughMap()
        )
    }

    public func joinTwo<OtherValueOne, OtherValueTwo>(
        _ otherOne: some Access<OtherValueOne>,
        _ otherTwo: some Access<OtherValueTwo>
    ) -> Projection<Tuple.Size3<Value, OtherValueOne, OtherValueTwo>> {
        .init(
            upstream: TupleAccess.SizeThree(a: self, b: otherOne, c: otherTwo),
            validity: .ifParent,
            map: PassthroughMap()
        )
    }
}

// MARK: Sequence

extension Projection: Sequence where Value: MutableCollection {
    public typealias Element = Projection<Value.Element>
    public typealias Iterator = IndexingIterator<Projection<Value>>
    public typealias SubSequence = Slice<Projection<Value>>
}

// MARK: Collection

extension Projection: Collection where Value: MutableCollection {
    public typealias Index = Value.Index
    public typealias Indices = Value.Indices

    public var startIndex: Projection<Value>.Index {
        value.startIndex
    }

    public var endIndex: Projection<Value>.Index {
        value.endIndex
    }

    public var indices: Value.Indices {
        value.indices
    }

    public func index(
        after i: Value.Index
    )
        -> Value.Index {
        value.index(after: i)
    }

    public subscript(
        position: Projection<Value>.Index
    ) -> Projection<Value.Element> {
        map(
            validity: .condition({ value in
                value.startIndex <= position
                    && position < value.endIndex
            }),
            map: AccessingBimap(
                map: Bimapper(paths: [
                    Bijection(
                        bFromA: { b, a in
                            b = a[position]
                        },
                        aFromB: { a, b in
                            a[position] = b
                        }
                    ).erase()
                ]),
                upstream: CapturedAccess(getter: { value }, setter: { value = $0 }),
                downstream: ValueAccess(value[position])
            )
        )
    }
}

// MARK: BidirectionalCollection

extension Projection: BidirectionalCollection
    where Value: BidirectionalCollection, Value: MutableCollection {
    public func index(
        before i: Projection<Value>.Index
    ) -> Projection<Value>.Index {
        value.index(before: i)
    }

    public func formIndex(
        before i: inout Projection<Value>.Index
    ) {
        value.formIndex(before: &i)
    }
}

// MARK: RandomAccessCollection

extension Projection: RandomAccessCollection
    where Value: MutableCollection, Value: RandomAccessCollection {}

extension Projection where Value: MutableCollection, Value: RangeReplaceableCollection,
    Value.Element: Identifiable {

    public func first(where isIncluded: @escaping (Value.Element) -> Bool) -> Projection<Value.Element?> {
        map(validity: .condition({ $0.contains(where: isIncluded) })) { upstream in
            upstream.first(where: isIncluded)
        } upwards: { varUpstream, downstream in
            if
                let downstream,
                let index = varUpstream.firstIndex(where: isIncluded)
            {
                varUpstream[index] = downstream
            }
        }
    }

    public func filter(
        isIncluded: @escaping (Value.Element) -> Bool
    ) -> Projection<[Value.Element]> {
        map(
            validity: .ifParent,
            downwards: { upstream in
                upstream.filter(isIncluded)
            },
            upwards: { varUpstream, downstream in
                let upstreamCandidates = varUpstream.filter(isIncluded)
                let upstreamSet = Set(upstreamCandidates.map(\.id))
                let downstreamSet = Set(downstream.map(\.id))

                let deletions = upstreamSet.subtracting(downstreamSet)
                let additions = downstreamSet.subtracting(upstreamSet)
                let updates = upstreamSet.intersection(downstreamSet)

                let index = downstream.reduce(into: [AnyHashable: Value.Element]()) { acc, curr in
                    acc[curr.id] = curr
                }

                var new = varUpstream.filter { !deletions.contains($0.id) }
                for i in new.indices where updates.contains(new[i].id) {
                    if let update = index[new[i].id] {
                        new[i] = update
                    }
                }
                new += additions.compactMap { index[$0] }
                varUpstream = new
            }
        )
    }
}
