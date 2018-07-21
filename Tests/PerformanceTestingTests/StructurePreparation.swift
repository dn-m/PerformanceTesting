//
//  StructurePreparation.swift
//  PerformanceTestingTests
//
//  Created by James Bean on 7/21/18.
//

/// Whether to fill a collection with increasing elements or random elements.
enum FillStrategy {
    case increasing
    case random
}

// MARK: - Array Preparation

/// - Returns: An `Array` with the given `size`, filled with the given `strategy`.
func array (_ strategy: FillStrategy) -> (_ size: Int) -> Array<Int> {
    switch strategy {
    case .increasing:
        return array { $0 }
    case .random:
        return { size in (array { _ in .random(in: 0..<size) })(size) }
    }
}

/// - Returns: An `Array` with the given `size`, filled with the given `generator`.
func array <T> (_ generator: @escaping (Int) -> T) -> (_ size: Int) -> Array<T> {
    return { size in .init((0..<size).map { generator($0) }) }
}

// MARK: - Set Preparation

/// - Returns: A pair of `Set` values with the given `size`, filled with the given `strategy`.
func setPair (_ strategy: FillStrategy) -> (_ size: Int) -> (Set<Int>,Set<Int>) {
    return { size in
        (set(strategy)(size),set(strategy)(size))
    }
}

/// - Returns: A `Set` with the given `size`, filled with the given `strategy`.
func set (_ strategy: FillStrategy) -> (_ size: Int) -> Set<Int> {
    switch strategy {
    case .increasing:
        return set { $0 }
    case .random:
        return { size in (set { _ in .random(in: 0..<size) })(size) }
    }
}

/// - Returns: A `Set` with the given `size`, filled with the given `generator`.
func set <T> (_ generator: @escaping (Int) -> T) -> (_ size: Int) -> Set<T> {
    return { size in .init((0..<size).map { generator($0) }) }
}

// MARK: - Dictionary Preparation

/// - Returns: A pair of `Dictionary` values with the given `size`, filled with the given `strategy`.
func dictPair (_ strategy: FillStrategy)
    -> (_ size: Int)
    -> (Dictionary<Int,Int>,Dictionary<Int,Int>)
{
    return { size in
        (dict(strategy)(size),dict(strategy)(size))
    }
}

/// - Returns: A `Dictionary` with the given `size`, filled with the given `strategy`.
func dict (_ strategy: FillStrategy) -> (_ size: Int) -> Dictionary<Int,Int> {
    switch strategy {
    case .increasing:
        return dict { $0 }
    case .random:
        return { size in (dict { _ in .random(in: 0..<size) })(size) }    }
}


/// - Returns: An `Array` with the given `size`, filled with the given `generator`.
func dict <T> (_ generator: @escaping (Int) -> T) -> (_ size: Int) -> [T:T] {
    return { size in
        .init(uniqueKeysWithValues: (0..<size).map { (generator($0),generator($0)) })
    }
}
