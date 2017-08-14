//
// ArrayExtensions.swift
// 2017-08-14
// Author: Brian Heim
//

extension Array where Element == Double {

    public var sum: Double {
        return reduce(0,+)
    }

    public var average: Double {
        assert(count > 0)
        return sum / Double(count)
    }
}
