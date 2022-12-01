import Bimapping

extension Transform {
  /// A ``Transform.Stateful``  uses a stored upstream and
  /// downstream state to fulfil the ``Transformer`` contract.
  ///
  /// > Warning: Since Statefuls are stateful, they save values.
  /// They can not be safely reused across different value instances.
  @MainActor
  public struct Stateful<U: Updater, UpAccess: Accessor, DownAccess: Accessor>: Transformer
  where
    UpAccess.Value == U.Upstream,
    DownAccess.Value == U.Downstream
  {

    public typealias Upstream = U.Upstream
    public typealias Downstream = U.Downstream

    public init(
      map: U,
      upstream: UpAccess,
      downstream: DownAccess,
      isValid: @escaping (_ upstream: Upstream) -> Bool
    ) {
      updater = map
      upstreamAccess = upstream
      downstreamAccess = downstream
      isValidFunc = isValid
    }

    public func downstream(from upstream: U.Upstream) -> U.Downstream {
      var downstream = downstreamAccess.value
      updater.update(mutableDownstream: &downstream, from: upstream)
      downstreamAccess.value = downstream
      return downstream
    }

    public func upstream(from downstream: U.Downstream) -> U.Upstream {
      var upstream = upstreamAccess.value
      updater.update(mutableUpstream: &upstream, from: downstream)
      upstreamAccess.value = upstream
      return upstream
    }

    nonisolated public func isValid(given upstream: U.Upstream) -> Bool {
      updater.isValid(given: upstream) && isValidFunc(upstream)
    }

    private let updater: U
    private let upstreamAccess: UpAccess
    private let downstreamAccess: DownAccess
    private let isValidFunc: (Upstream) -> Bool
  }
}

extension Transform.Stateful: Accessor {
  public var value: Downstream {
    get {
      downstream(from: upstreamAccess.value)
    }
    nonmutating set {
      if upstreamAccess.isValid() {
        upstreamAccess.value = upstream(from: newValue)
      }
    }
  }

  public func isValid() -> Bool {
    upstreamAccess.isValid()
      && isValidFunc(upstreamAccess.value)
  }

  public typealias Value = Downstream
}
