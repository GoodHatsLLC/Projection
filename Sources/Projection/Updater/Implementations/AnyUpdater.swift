/// A type erased ``Updater``
public struct AnyUpdater<Upstream, Downstream>: Updater {
  public init(
    updateDownstream: @escaping (_ mutableDownstream: inout Downstream, _ upstream: Upstream) ->
      Void,
    updateUpstream: @escaping (_ mutableUpstream: inout Upstream, _ downstream: Downstream) -> Void,
    isValid: @escaping (_ given: Upstream) -> Bool
  ) {
    self.updateDownstreamFunc = updateDownstream
    self.updateUpstreamFunc = updateUpstream
    self.isValidFunc = isValid
  }

  let updateDownstreamFunc: (inout Downstream, Upstream) -> Void
  let updateUpstreamFunc: (inout Upstream, Downstream) -> Void
  let isValidFunc: (Upstream) -> Bool

  public func update(
    mutableDownstream: inout Downstream,
    from upstream: Upstream
  ) {
    updateDownstreamFunc(&mutableDownstream, upstream)
  }

  public func update(
    mutableUpstream: inout Upstream,
    from downstream: Downstream
  ) {
    updateUpstreamFunc(&mutableUpstream, downstream)
  }

  public func isValid(given upstream: Upstream) -> Bool {
    isValidFunc(upstream)
  }

  public func erase() -> AnyUpdater<Upstream, Downstream> { self }
}
