// MARK: - Access.Tuple

extension Access {
  public enum Tuple {}
}

extension Access.Tuple {
  /// An ``Accessor`` containing two underlying accesses.
  @MainActor
  struct SizeTwo<A, B>: Accessor {
    init(a: some Accessor<A>, b: some Accessor<B>) {
      aAccess = a
      bAccess = b
    }

    typealias Value = Tuple.Size2<A, B>

    var value: Tuple.Size2<A, B> {
      get { Tuple.create(aAccess.value, bAccess.value) }
      nonmutating set {
        aAccess.value = newValue.a
        bAccess.value = newValue.b
      }
    }

    func isValid() -> Bool {
      aAccess.isValid() && bAccess.isValid()
    }

    private let aAccess: any Accessor<A>
    private let bAccess: any Accessor<B>

  }

  /// An ``Accessor`` containing three underlying accesses.
  @MainActor
  struct SizeThree<A, B, C>: Accessor {
    init(a: some Accessor<A>, b: some Accessor<B>, c: some Accessor<C>) {
      aAccess = a
      bAccess = b
      cAccess = c
    }

    typealias Value = Tuple.Size3<A, B, C>

    var value: Tuple.Size3<A, B, C> {
      get { Tuple.create(aAccess.value, bAccess.value, cAccess.value) }
      nonmutating set {
        aAccess.value = newValue.a
        bAccess.value = newValue.b
        cAccess.value = newValue.c
      }
    }

    func isValid() -> Bool {
      aAccess.isValid() && bAccess.isValid() && cAccess.isValid()
    }

    private let aAccess: any Accessor<A>
    private let bAccess: any Accessor<B>
    private let cAccess: any Accessor<C>

  }
}
