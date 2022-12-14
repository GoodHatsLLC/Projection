import Bimapping

// MARK: - Projection + Sequence

extension Projection: Sequence where Value: MutableCollection {
  public typealias Element = Projection<Value.Element>
  public typealias Iterator = IndexingIterator<Projection<Value>>
  public typealias SubSequence = Slice<Projection<Value>>
}

// MARK: - Projection + Collection

extension Projection: Collection where Value: MutableCollection {
  public typealias Index = Value.Index
  public typealias Indices = Value.Indices

  public var startIndex: Projection<Value>.Index {
    value.startIndex
  }

  public var endIndex: Projection<Value>.Index {
    value.endIndex
  }

  public var indices: Value.Indices {
    value.indices
  }

  public func index(
    after i: Value.Index
  )
    -> Value.Index
  {
    value.index(after: i)
  }

  public subscript(
    position: Projection<Value>.Index
  ) -> Projection<Value.Element> {
    map(
      Transform.Stateful(
        map: Update.Bimap(
          bFromA: { $0 = $1[position] },
          aFromB: { $0[position] = $1 }
        ),
        upstream: Access.CapturedAccess(
          getter: { value },
          setter: { value = $0 }
        ),
        downstream: Access.ValueAccess(
          value[position]
        ),
        isValid: {
          $0.startIndex <= position && position < $0.endIndex
        }
      )
    )
  }
}

// MARK: - Projection + BidirectionalCollection

extension Projection: BidirectionalCollection
where
  Value: BidirectionalCollection,
  Value: MutableCollection
{

  public func index(
    before i: Projection<Value>.Index
  ) -> Projection<Value>.Index {
    value.index(before: i)
  }

  public func formIndex(
    before i: inout Projection<Value>.Index
  ) {
    value.formIndex(before: &i)
  }
}

// MARK: - Projection + RandomAccessCollection

extension Projection: RandomAccessCollection
where
  Value: MutableCollection,
  Value: RandomAccessCollection
{}
