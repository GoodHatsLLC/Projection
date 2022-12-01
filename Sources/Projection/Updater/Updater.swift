import Bimapping

/// An `Updater` can update a downstream value given and upstream
/// and vice versa.
///
/// (Types which are able to to *create* their upstream or downstream,
/// should conform to a stronger contract.)
public protocol Updater: UpstreamValidateable {
  associatedtype Upstream
  associatedtype Downstream
  func update(
    mutableDownstream: inout Downstream,
    from upstream: Upstream
  )
  func update(
    mutableUpstream: inout Upstream,
    from downstream: Downstream
  )
  func isValid(given: Upstream) -> Bool
}

public enum Update {}

extension Updater {
  public func erase() -> AnyUpdater<Upstream, Downstream> {
    AnyUpdater(
      updateDownstream: update(mutableDownstream:from:),
      updateUpstream: update(mutableUpstream:from:),
      isValid: isValid
    )
  }
}
