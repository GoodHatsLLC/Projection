/// A proxy layer over some other `Access` conformer.
///
/// `ProxyAccess` allows its underlying `Access` to be swapped at runtime.
@MainActor
struct ProxyAccess<Value>: Access {

    init(
        _ access: some Access<Value>
    ) {
        self.access = Ref(access.erase())
    }

    var value: Value {
        get { access.value.value }
        nonmutating set { access.value.value = newValue }
    }

    func isValid() -> Bool {
        access.value.isValid()
    }

    func set(access: some Access<Value>) {
        self.access.value = access.erase()
    }

    private var access: Ref<AnyAccess<Value>>

}
