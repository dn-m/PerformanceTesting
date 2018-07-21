//
//  StructurePreparation.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 7/21/18.
//

enum FillStrategy {
    case increasing
    case random
}

func array (_ strategy: FillStrategy) -> (_ size: Int) -> Array<Int> {
    switch strategy {
    case .increasing:
        return { size in .init(0..<size) }
    case .random:
        return { size in .init((0..<size).map { _ in Int.random(in: 0..<size) }) }
    }
}
