extension Transforming {
    /// A CapturedTransformer can directly and statelessly convert an upstream value
    /// to a downstream value and vice versa.
    @MainActor
    public struct CapturedTransformer<Upstream, Downstream>: Transformer {

        public init(
            downwards: @escaping (_ upstream: Upstream) -> Downstream,
            upwards: @escaping (_ downstream: Downstream) -> Upstream
        ) {
            self.downwards = downwards
            self.upwards = upwards
        }

        private let downwards: (Upstream) -> Downstream
        private let upwards: (Downstream) -> Upstream

        public func downstream(from: Upstream) -> Downstream {
            downwards(from)
        }

        public func upstream(from: Downstream) -> Upstream {
            upwards(from)
        }

    }
}
