extension Projecting {
    /// An `Access` conformer which provides a constant value.
    ///
    /// > Warning: `Projecting.ConstantAccess` ignores value setter calls.
    @MainActor
    public struct ConstantAccess<Value>: Access {

        public init(_ value: Value) {
            constant = value
        }

        private let constant: Value

        public var value: Value {
            get { constant }
            nonmutating set {}
        }

        public func isValid() -> Bool { true }
    }
}
