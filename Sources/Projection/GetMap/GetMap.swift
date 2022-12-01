/// A PureMap can convert an upstream value to a downstream value and
/// vice versa. Unless it is also a `PureMap` it may do so using stored
/// state and/or triggering side effects.
@MainActor
public protocol GetMap<Upstream, Downstream> {
    associatedtype Upstream
    associatedtype Downstream

    func downstream(from: Upstream) -> Downstream
    func upstream(from: Downstream) -> Upstream

}
