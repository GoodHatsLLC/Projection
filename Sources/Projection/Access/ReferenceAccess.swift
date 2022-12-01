extension Projecting {
    /// An `Access` conformer which provides an object's field as its `Value`.
    @MainActor
    public struct ReferenceAccess<Root: AnyObject, Value>: Access {

        public init(from root: Root, path: ReferenceWritableKeyPath<Root, Value>) {
            self.root = root
            self.path = path
        }

        let root: Root
        let path: ReferenceWritableKeyPath<Root, Value>

        public var value: Value {
            get { root[keyPath: path] }
            nonmutating set { root[keyPath: path] = newValue }
        }

        public func isValid() -> Bool { true }
    }
}
