/// A type whose behavior can be pre-validated for correctness.
@MainActor
public protocol Validateable {
  /// Indicates whether or not an instance is currently able act.
  func isValid() -> Bool
}
