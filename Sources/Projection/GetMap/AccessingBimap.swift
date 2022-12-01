import Bimapping

/// An AccessingBimap uses a `Bimapper` and stored upstream and
/// downstream state to fulfill the `GetMap` contract.
///
/// > Warning: AccessingBimaps are impure and stateful. Using them
/// will trigger side effects and use some opaque storage.
/// They can not be safely reused across different value instances.
@MainActor
public struct AccessingBimap<Upstream, Downstream>: GetMap {

    public init(
        map: Bimapper<Upstream, Downstream>,
        upstream: some Access<Upstream>,
        downstream: some Access<Downstream>
    ) {
        biMap = map
        upstreamAccess = upstream
        downstreamAccess = downstream
    }

    public func downstream(from upstream: Upstream) -> Downstream {
        var downstream = downstreamAccess.value
        biMap.update(b: &downstream, from: upstream)
        downstreamAccess.value = downstream
        return downstream
    }

    public func upstream(from downstream: Downstream) -> Upstream {
        var upstream = upstreamAccess.value
        biMap.update(a: &upstream, from: downstream)
        upstreamAccess.value = upstream
        return upstream
    }

    private let biMap: Bimapper<Upstream, Downstream>
    private let upstreamAccess: any Access<Upstream>
    private let downstreamAccess: any Access<Downstream>

}
