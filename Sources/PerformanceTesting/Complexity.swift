//
//  Complexity.swift
//  PerformanceTesting
//
//  Created by James Bean on 8/10/17.
//

import Darwin

/// Classes of complexity (big-oh style).
public enum Complexity {

    case constant
    case logarithmic
    case squareRoot
    case linear
    case quadratic
    case cubic
    case exponential
    case customComplexity(inverseFunction: (Double) -> Double)

    /// The inverse function of the function represented by this complexity.
    /// For example, the inverse of squareRoot is squaring.
    public var inverse: (Double) -> Double {
        switch self {
        case .constant:
            return { $0 }
        case .logarithmic:
            return exp
        case .squareRoot:
            return { pow($0, 2) }
        case .linear:
            return { $0 }
        case .quadratic:
            return sqrt
        case .cubic:
            return { pow($0, 1/3) }
        case .exponential:
            return log
        case .customComplexity(let inverseFunction):
            return inverseFunction
        }
    }
}
