//
//  Trial.swift
//  PerformanceTesting
//
//  Created by James Bean on 7/19/18.
//

import Foundation

/// Interface for values which can measure the time that it takes for perform and operation.
public protocol Trial {
    var time: Double { get }
}

public struct TimeTrial: Trial {
    public let time: Double
}

public struct NonMutatingTrial <Subject>: Trial {

    // MARK: - Instance Properties

    public var time: Double {
        return measure { operation(subject) }
    }

    let subject: Subject
    let operation: (Subject) -> Void

    // MARK: - Initializers

    public init(subject: Subject, operation: @escaping (Subject) -> Void) {
        self.subject = subject
        self.operation = operation
    }
}

/// All of the information needed to measure the time that it takes for a single performance of a
/// given `operation` which mutates a given `subject`.
public struct MutatingTrial <Subject>: Trial {

    // MARK: - Instance Properties

    public var time: Double {
        var subject = self.subject
        return measure { operation(&subject) }
    }

    var subject: Subject
    let operation: (inout Subject) -> Void

    public init(subject: Subject, operation: @escaping (inout Subject) -> Void) {
        self.subject = subject
        self.operation = operation
    }
}

/// - Returns: The amount of time that it takes to perform the given `operation`.
internal func measure (operation: () -> Void) -> Double {
    let start = CFAbsoluteTimeGetCurrent()
    operation()
    let finish = CFAbsoluteTimeGetCurrent()
    return finish - start
}
