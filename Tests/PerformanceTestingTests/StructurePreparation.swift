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

// MARK: - Array Preparation

func array (_ strategy: FillStrategy) -> (_ size: Int) -> Array<Int> {
    switch strategy {
    case .increasing:
        return { size in .init(0..<size) }
    case .random:
        return { size in .init((0..<size).map { _ in Int.random(in: 0..<size) }) }
    }
}

// MARK: - Set Preparation

func set (_ strategy: FillStrategy) -> (_ size: Int) -> Set<Int> {
    switch strategy {
    case .increasing:
        return { size in .init(0..<size) }
    case .random:
        return { size in .init((0..<size).map { _ in Int.random(in: 0..<size) }) }
    }
}

func setPair (_ strategy: FillStrategy) -> (_ size: Int) -> (Set<Int>,Set<Int>) {
    return { size in
        (set(strategy)(size),set(strategy)(size))
    }
}

// MARK: - Dictionary Preparation

func dict (_ strategy: FillStrategy) -> (_ size: Int) -> Dictionary<Int,Int> {
    switch strategy {
    case .increasing:
        return { size in
            Dictionary(uniqueKeysWithValues: (0..<size).map { (key: $0, value: $0) })
        }
    case .random:
        return { size in
            Dictionary(
                uniqueKeysWithValues: (0..<size).map {
                    (key: Int.random(in: 0..<$0), value: Int.random(in: 0..<$0))
                }
            )
        }
    }
}

func dictPair (_ strategy: FillStrategy)
    -> (_ size: Int)
    -> (Dictionary<Int,Int>,Dictionary<Int,Int>)
{
    return { size in
        (dict(strategy)(size),dict(strategy)(size))
    }
}
