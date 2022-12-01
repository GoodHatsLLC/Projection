/// A PassthroughMap forwards an upstream value as a downstream value
/// without making any changes, using stored state, or triggering side effects.
@MainActor
public struct PassthroughMap<Value>: GetMap {

    public init() {}

    public typealias Upstream = Value
    public typealias Downstream = Value

    public func downstream(from: Upstream) -> Downstream {
        from
    }

    public func upstream(from: Downstream) -> Upstream {
        from
    }
}
