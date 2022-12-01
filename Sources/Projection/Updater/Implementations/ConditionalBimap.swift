extension Update {
  public struct ConditionalBimap<Upstream, Downstream>: Updater {
    public init(
      bimap: Bimapper<Upstream, Downstream>,
      condition: @escaping (Upstream) -> Bool
    ) {
      self.bimap = bimap
      self.condition = condition
    }

    let bimap: Bimap<Upstream, Downstream>
    let condition: (Upstream) -> Bool

    public func update(mutableDownstream: inout Downstream, from upstream: Upstream) {
      bimap.update(mutableDownstream: &mutableDownstream, from: upstream)
    }

    public func update(mutableUpstream: inout Upstream, from downstream: Downstream) {
      bimap.update(mutableUpstream: &mutableUpstream, from: downstream)
    }

    public func isValid(given upstream: Upstream) -> Bool {
      condition(upstream)
    }

  }
}
