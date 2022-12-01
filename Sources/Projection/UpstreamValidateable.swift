/// A type whose behavior can be pre-validated for correctness given an upstream value.
public protocol UpstreamValidateable {
  associatedtype Upstream
  /// Indicates whether or not an instance is currently able act given the input value.
  func isValid(given: Upstream) -> Bool
}
