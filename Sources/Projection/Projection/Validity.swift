/// A type used to define the validity state of an `Access`.
///
/// An `Access` may be conditionally valid, or if it has an upstream
/// parent may be valid in all cases in which the parent is valid.
///
/// > Note: A `condition` definition is only evaluated if its `Access's`
/// parent is valid.
public enum Validity<Upstream> {
    case ifParent
    case condition((_ upstream: Upstream) -> Bool)
}
