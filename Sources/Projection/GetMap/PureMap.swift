/// A PureMap can directly and statelessly convert an upstream value
/// to a downstream value and vice versa.
@MainActor
struct PureMap<Upstream, Downstream>: GetMap {

    public init(
        downwards: @escaping (_ upstream: Upstream) -> Downstream,
        upwards: @escaping (_ downstream: Downstream) -> Upstream
    ) {
        self.downwards = downwards
        self.upwards = upwards
    }

    private let downwards: (Upstream) -> Downstream
    private let upwards: (Downstream) -> Upstream

    func downstream(from: Upstream) -> Downstream {
        downwards(from)
    }

    func upstream(from: Downstream) -> Upstream {
        upwards(from)
    }
}
