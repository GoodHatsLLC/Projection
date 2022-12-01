# Projection

A `Projection` is a SwiftUI `Binding` that:
- Supports arbitrary bidirectional transforms, bijections, surjections, and injections.
- May only be conditionally valid, and may be checked with `isValid()`.
- Integrates with the [`Bimapping`](https://github.com/GoodHatsLLC/Bimapping) bidirectional transform DSL.
- Can have its source instances swapped at runtime.

## Purpose

`Projection` be used to represent complicated relationships where SwiftUI's `Binding`
falls short, including ones which may become invalid over time as the source
value changes or that require complex bidirectional transformations.

1. Projections allow full `map` behavior from source to target and vice versa.
    * Bindings are limited to projecting KeyPath based subsets of a source model
2. Projections can have their source `Access` swapped out, and so represent
the same mapping, but between new instances
    * Bindings are fully attached to the source entity that was used to construct them. 
3. Projections may specifiy their validity and so signal to consumers that the current
state of the source model does not allow for the construction of the projected target.  
    * A Binding to an array value like `$array[4]` may _silently become_ invalid and then crash on access.
4. Projections integrate with the [`Bimapping`](https://github.com/GoodHatsLLC/Bimapping) bidirectional transform DSL
and provides good ergonomics for writing complicated mappings, whether they're [bijections, surjections, or injections](https://en.wikipedia.org/wiki/Bijection,_injection_and_surjection).
    * Bindings can only map into subfields of a model

Operators available on `Projections` and not on `Bindings` include:
- `map`
- `compactMap`
- `first`
- `filter`
- `statefulMap`

## Limitations

`Projections` are current only about [2/3 as fast as `Bindings`](https://github.com/GoodHatsLLC/Projection/blob/main/Tests/ProjectionTests/Benchmarks.swift).

## Examples

Simple uses of `Projections` work just like `Bindings`:
```swift
// Create a capturing Projection
let rootProjection = Projection {
  self.rootState
} setter: {
  self.rootState = $0
}

// Access subfields the same syntax as in Bindings
let subStateProjection = rootProjection.someState

// Set the field value on `.value`
subStateProjection.field.value = "Hello"

// Observe the change in the source and in the initial binding
XCTAssertEqual(self.rootState.someState.field, "Hello")
XCTAssertEqual(rootProjection.someState.field.value, "Hello")
```

Indefinitely more complex transformations are also expressible:
```swift
// Create a Projection
let root = Projection(\.rootState, on: self)
let bimapProjection = root
  .statefulMap(into: OtherModel()) { up, down in

    // Bidirectionally map the `bbState` and `ccState` fields across models.
    up.aaState.bbState <-> down.bbState
    up.aaState.bbState.ccState <-> down.ccState

    // Define a (one way) function joining the the upstream's
    // `aa` and `dd` fields into a string.
    let upAA = up.aaState.aa
    let upDD = up.aaState.bbState.ccState.ddState.dd
    let compound = upAA.join(upDD) { first, second in
      "\(first) and \(second) joined"
    }
    
    // Map the new string representation unidirectionally into
    // the downstream's `compoundState` field.
    compound --> down.compoundState
    
    // If we can create the opposite transformation we can make the
    // previous unidirectional link bidirectional.
    let regex = Regex { /*...*/ }
    upAA <-- down.compoundState
        .map { $0.firstMatch(of: regex)?.1 ?? -1 }
    upDD <-- down.compoundState
        .map { $0.firstMatch(of: regex)?.2 ?? -1 }
    }
}

// When we change a value on the root projection… 
root.aaState.aa.value = 1
// …or on the referenced source model…
self.rootState.aaState.bbState.ccState.ddState.dd.value = 2
// …we can observe the change to the derived projection.
XCTAssertEqual("1 and 2 joined", bimapProjection.compoundState)


```
