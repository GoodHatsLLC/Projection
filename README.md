# Projection

A `Projection` is a SwiftUI `Binding` that:
- Has a customizable source
- May only be conditionally valid
- Can be checked for validity prior to access via `isValid()`

In loosening the constrains imposed on a SwiftUI `Binding`
Projections can safely be made to implement useful operators
not available to `Bindings`.

Operators available on `Projections` and not on `Bindings` include:
- `compactMap`
- `first`
- `filter`
