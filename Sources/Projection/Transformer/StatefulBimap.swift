import Bimapping

extension Transforming {
    /// An ``StatefulBimap`` uses a ``Bimapper`` and stored upstream and
    /// downstream state to fulfill the ``Transformer`` contract.
    ///
    /// > Warning: Since StatefulBimaps are stateful, they save values.
    /// They can not be safely reused across different value instances.
    @MainActor
    public struct StatefulBimap<Upstream, Downstream>: Transformer {

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
}
