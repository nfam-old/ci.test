//
//  JSONRepresentable.swift
//  JSON
//
//  Created by Ninh on 11/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

/// A protocol to facilitate generating of `JSON`.
public protocol JSONRepresentable {
    /// Generates `JSON` from an instance of a conforming type.
    ///
    /// - Returns: An instance of `JSON`.
    /// - Note: If conforming to `JSONRepresentable` with a custom type of your own,
    /// an instance of `JSON.dictionary` shoul be returned.
    func toJSON() -> JSON
}

extension JSON {
    /// Creates a `JSON` from an instance of a conforming type.
    ///
    /// - Parameter value: an instance of conforming type.
    ///
    /// - Returns: An instance of `JSON`.
    public init<T>(_ value: T) where T: JSONRepresentable {
        self = value.toJSON()
    }

    /// Creates a `JSON` from an instance of a conforming type.
    ///
    /// - Parameter value: an instance of conforming type.
    ///
    /// - Returns: An instance of `JSON`.
    public init<T>(_ value: T?) where T: JSONRepresentable {
        self = value?.toJSON() ?? JSON.null
    }
}

extension JSON {
    /// Creates a `JSON` from an instance of a conforming type.
    ///
    /// - Parameter value: an instance of conforming type.
    ///
    /// - Returns: An instance of `JSON`.
    public init<T>(_ value: [T]) where T: JSONRepresentable {
        self = value.toJSON()
    }

    /// Creates a `JSON` from an instance of a conforming type.
    ///
    /// - Parameter value: an instance of conforming type.
    ///
    /// - Returns: An instance of `JSON`.
    public init<T>(_ value: [T]?) where T: JSONRepresentable {
        self = value?.toJSON() ?? JSON.null
    }
}

extension JSON {
    /// Creates a `JSON` from an instance of a conforming type.
    ///
    /// - Parameter value: an instance of conforming type.
    ///
    /// - Returns: An instance of `JSON`.
    public init<T>(_ value: [String: T]) where T: JSONRepresentable {
        self = value.toJSON()
    }

    /// Creates a `JSON` from an instance of a conforming type.
    ///
    /// - Parameter value: an instance of conforming type.
    ///
    /// - Returns: An instance of `JSON`.
    public init<T>(_ value: [String: T]?) where T: JSONRepresentable {
        self = value?.toJSON() ?? JSON.null
    }
}

extension JSON {
    /// Creates a `JSON` from an instance of a conforming type.
    ///
    /// - Returns: An instance of `JSON`.
    public init<T>(_ value: T) where T: RawRepresentable, T.RawValue: JSONRepresentable {
        self = value.toJSON()
    }

    /// Creates a `JSON` from an instance of a conforming type.
    ///
    /// - Returns: An instance of `JSON`.
    public init<T>(_ value: T?) where T: RawRepresentable, T.RawValue: JSONRepresentable {
        self = value?.toJSON() ?? JSON.null
    }
}

extension JSON: JSONRepresentable {
    /// Returns `JSON` itself.
    ///
    /// - Returns: the `JSON` instance itself.
    public func toJSON() -> JSON {
        return self
    }
}

extension Bool: JSONRepresentable {
    /// Generates `JSON` from an instance of a conforming type.
    ///
    /// - Returns: An instance of `JSON` where the enum case is `.bool`.
    public func toJSON() -> JSON {
        return self ? jsonOfTrue : jsonOfFalse
    }
}

extension Int: JSONRepresentable {
    /// Generates `JSON` from an instance of a conforming type.
    ///
    /// - Returns: An instance of `JSON` where the enum case is `.int`.
    public func toJSON() -> JSON {
        return self == 0 ? jsonOfZero : .int(self)
    }
}

extension Double: JSONRepresentable {
    /// Generates `JSON` from an instance of a conforming type.
    ///
    /// - Returns: An instance of `JSON` where the enum case is `.double`.
    public func toJSON() -> JSON {
        return .double(self)
    }
}

extension String: JSONRepresentable {
    /// Generates `JSON` from an instance of a conforming type.
    ///
    /// - Returns: An instance of `JSON` where the enum case is `.string`.
    public func toJSON() -> JSON {
        return self == "" ? jsonOfEmptyString : .string(self)
    }
}

extension Array where Element: JSONRepresentable {
    /// Generates `JSON` from an instance of `Array` whose elements conform to `JSONRepresentable`.
    ///
    /// - Returns: An instance of `JSON` where the enum case is `.array`.
    public func toJSON() -> JSON {
        return .array(self)
    }
}

extension Dictionary where Key == String, Value: JSONRepresentable {
    /// Generates `JSON` from an instance of `Dictionary` whose
    /// keys are `String` and values conform to `JSONRepresentable`.
    ///
    /// - Returns: An instance of `JSON` where the enum case is `.dictionary`.
    public func toJSON() -> JSON {
        return .dictionary(self)
    }
}

extension RawRepresentable where RawValue: JSONRepresentable {
    /// Generates `JSON` from an instance of a conforming type.
    ///
    /// - Returns: An instance of `JSON` where the enum case is whatever the underlying `RawValue` converts to.
    public func toJSON() -> JSON {
        return rawValue.toJSON()
    }
}

private let jsonOfTrue = JSON.bool(true)
private let jsonOfFalse = JSON.bool(false)
private let jsonOfZero = JSON.int(0)
private let jsonOfEmptyString = JSON.string("")
