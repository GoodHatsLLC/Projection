/// A namespace for varios sizes of tuples containing multiple `Access` conformers.
enum TupleAccess {}

extension TupleAccess {

    /// An `Access` conformer containing two underlying accesses.
    @MainActor
    struct SizeTwo<A, B>: Access {
        init(a: some Access<A>, b: some Access<B>) {
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

        private let aAccess: any Access<A>
        private let bAccess: any Access<B>

    }

    /// An `Access` conformer containing three underlying accesses.
    @MainActor
    struct SizeThree<A, B, C>: Access {
        init(a: some Access<A>, b: some Access<B>, c: some Access<C>) {
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

        private let aAccess: any Access<A>
        private let bAccess: any Access<B>
        private let cAccess: any Access<C>

    }

}
