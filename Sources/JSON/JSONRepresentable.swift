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
    public init<T>(_ value: T?) where T: JSONRepresentable {
        self = value?.toJSON() ?? JSON.null
    }

    /// Creates a `JSON` from an instance of a conforming type.
    ///
    /// - Returns: An instance of `JSON`.
    public init<T>(_ array: [T]?) where T: JSONRepresentable {
        self = array?.toJSON() ?? JSON.null
    }

    /// Creates a `JSON` from an instance of a conforming type.
    ///
    /// - Returns: An instance of `JSON`.
    public init<T>(_ dictionary: [String: T]?) where T: JSONRepresentable {
        self = dictionary?.toJSON() ?? JSON.null
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
        return .bool(self)
    }
}

extension Dictionary where Value: JSONRepresentable {
    /// Generates `JSON` from an instance of `Dictionary` whose
    /// keys are `String` and values conform to `JSONRepresentable`.
    ///
    /// - Returns: An instance of `JSON` where the enum case is `.dictionary`.
    public func toJSON() -> JSON {
        var jsonDictionary = [String: JSON]()

        for (k, v) in self {
            let key = String(describing: k)
            jsonDictionary[key] = v.toJSON()
        }

        return .dictionary(jsonDictionary)
    }
}

extension Array where Element: JSONRepresentable {
    /// Generates `JSON` from an instance of `Array` whose elements conform to `JSONRepresentable`.
    ///
    /// - Returns: An instance of `JSON` where the enum case is `.array`.
    public func toJSON() -> JSON {
        let arrayOfJSON = self.map { $0.toJSON() }
        return .array(arrayOfJSON)
    }
}

extension Int: JSONRepresentable {
    /// Generates `JSON` from an instance of a conforming type.
    ///
    /// - Returns: An instance of `JSON` where the enum case is `.int`.
    public func toJSON() -> JSON {
        return .int(self)
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
        return .string(self)
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

extension JSON {
    /// Creates a `JSON` from an instance of a conforming type.
    ///
    /// - Returns: An instance of `JSON`.
    public init<T>(_ item: T?) where T: RawRepresentable, T.RawValue: JSONRepresentable {
        self = item?.toJSON() ?? JSON.null
    }
}
