
extension Projection where Value: MutableCollection, Value: RangeReplaceableCollection,
    Value.Element: Identifiable
{

    public func first(where isIncluded: @escaping (Value.Element) -> Bool) -> Projection<Value.Element?> {
        map(
            validity: .condition({ $0.contains(where: isIncluded) })
        ) { upstream in
            upstream.first(where: isIncluded)
        } upwards: { varUpstream, downstream in
            if
                let downstream,
                let index = varUpstream.firstIndex(where: isIncluded)
            {
                varUpstream[index] = downstream
            }
        }
    }
}
