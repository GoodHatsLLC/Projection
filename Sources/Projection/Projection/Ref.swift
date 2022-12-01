import Foundation

@MainActor
final class Ref<V> {
    init(_ value: V) {
        self.value = value
    }

    var value: V
}
