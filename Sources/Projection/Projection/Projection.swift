import Bimapping

// MARK: - Projection

/// A `Projection` is an `Access` conformer providing many of the
/// properties of a SwiftUI `Binding`.
///
/// A projection uses some other `Access` conformer as its root
/// value access. When an operator is performed on the projection
/// a new projection is made which performs some 'projection' from
/// the last. This 'projection' function may only be valid in some
/// subset of cases.
///
/// i.e. A `Projection` is a SwiftUI `Binding` that:
/// - Has a customizable source
/// - May only be conditionally valid
/// - Can be checked for validity prior to access via `isValid()`
///
/// In loosening the constrains imposed on a SwiftUI `Binding`
/// Projections can safely be made to implement useful operators
/// not available to `Bindings`.
///
/// Operators available on `Projections` and not on `Bindings` include:
/// - `compactMap`
/// - `first`
/// - `filter`
@MainActor
@dynamicMemberLookup
public struct Projection<Value>: Access {

    public init(_ access: some Access<Value>) {
        self.access = access
    }

    public var value: Value {
        get { access.value }
        nonmutating set { access.value = newValue }
    }

    public func isValid() -> Bool {
        access.isValid()
    }

    private let access: any Access<Value>

}
