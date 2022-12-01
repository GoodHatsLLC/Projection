import Bimapping

extension Update {
  public typealias Bimap = Bimapper
}

extension Update.Bimap: Updater {
  public typealias Upstream = A
  public typealias Downstream = B

  /// Update an downstream value given a new upstream value.
  public func update(
    mutableDownstream: inout Downstream,
    from upstream: Upstream
  ) {
    update(b: &mutableDownstream, from: upstream)
  }

  /// Update an upstream value given a new downstream value.
  public func update(
    mutableUpstream: inout Upstream,
    from downstream: Downstream
  ) {
    update(a: &mutableUpstream, from: downstream)
  }

  /// A Bimap instance is a pure function and can not itself be invalid.
  public func isValid(given: Upstream) -> Bool {
    true
  }

}
