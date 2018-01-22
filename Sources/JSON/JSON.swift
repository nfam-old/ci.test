//
//  JSON.swift
//  JSON
//
//  Created by Ninh on 11/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

/// An enum to describe the structure of JSON.
public enum JSON {
    /// Denotes null.
    case null

    /// Denotes a boolean with an associated value of `Swift.Bool`.
    case bool(Bool)

     /// Denotes a dictionary aka. object in `RFC 7159`` with an associated value of `[Swift.String: JSON]`
    case dictionary([String: JSON])

    /// Denotes an array with an associated value of `[JSON]`
    case array([JSON])

    /// Denotes a number with an associated value of `Swift.Double`.
    case double(Double)

    /// Denotes a number with an associated value of `Swift.Int`.
    case int(Int)

    /// Denotes a string with an associated value of `Swift.String`.
    case string(String)
}

extension JSON {

    /// An enum to describe the value data type of JSON.
    public enum ValueType {
        /// null
        case null

        /// bool
        case bool

        /// dictionary
        case dictionary

        /// array
        case array

        /// double
        case double

        /// int
        case int

        /// string
        case string
    }

    /// Returns the value data type of value of JSON.
    public var type: ValueType {
        switch self {
        case .null:
            return .null
        case .dictionary:
            return .dictionary
        case .array:
            return .array
        case .double:
            return .double
        case .int:
            return .int
        case .bool:
            return .bool
        case .string:
            return .string
        }
    }
}

extension JSON {

    /// Returns a `Bool` value if it is `JSON.bool`, otherwise `nil`.
    public var bool: Bool? {
        if case .bool(let value) = self {
            return value
        }
        return nil
    }

    /// Returns an `Dictionary` if it is `JSON.dictionary`, otherwise `nil`.
    public var dictionary: [String: JSON]? {
        if case .dictionary(let value) = self {
            return value
        }
        return nil
    }

    /// Returns an `Dictionary` if it is `JSON.array`, otherwise `nil`.
    public var array: [JSON]? {
        if case .array(let value) = self {
            return value
        }
        return nil
    }

    /// Returns a `Double` if it is `JSON.double` or `JSON.int`, otherwise `nil`.
    public var double: Double? {
        if case .double(let value) = self {
            return value
        } else if case .int(let value) = self {
            return Double(value)
        }
        return nil
    }

    /// Returns a `Double` if it is `JSON.int` or `JSON.double` convertable to integer
    /// without losing precision, otherwise `nil`.
    public var int: Int? {
        if case .int(let value) = self {
            return value
        } else if case .double(let value) = self {
            if value == value.rounded(.towardZero) {
                return Int(value)
            }
        }
        return nil
    }

    /// Returns a `String` if it is `JSON.string`, otherwise `nil`.
    public var string: String? {
        if case .string(let value) = self {
            return value
        }
        return nil
    }
}

extension JSON {

    /// Returns an element at a given index if it is `JSON.array`.
    ///
    /// - Parameter index: The position of the element to access. `index` must be
    ///   greater than or equal to 0 and less than the number of elements in the array.
    ///
    /// - Returns: If it is `JSON.array` and the given `index` is within the range, then
    ///   returns the element at the given `index`, otherwise retuns `JSON.null`.
    public subscript(index: Int) -> JSON {
        guard let array = self.array else {
            return JSON.null
        }
        guard 0 <= index, index < array.count else {
            return JSON.null
        }
        return array[index]
    }

    /// Returns an value at a given key if it is `JSON.dictionary`.
    ///
    /// - Parameter key: The key of the value to access. `key` must exit in the dictionary.
    ///
    /// - Returns: If it is `JSON.dictionary` and the given `key` exits, then
    ///   returns the value at the given key, otherwise retuns `JSON.null`.
    public subscript(key: String) -> JSON {
        guard let dictionary = self.dictionary else {
            return JSON.null
        }
        guard let value = dictionary[key] else {
            return JSON.null
        }
        return value
    }
}

extension JSON: CustomStringConvertible, CustomDebugStringConvertible {

    /// Represents itself int text.
    public var description: String {
        switch self {
        case .null:
            return "null"
        case .dictionary(let value):
            return String(describing: value)
        case .array(let value):
            return String(describing: value)
        case .double(let value):
            return String(describing: value)
        case .int(let value):
            return String(describing: value)
        case .bool(let value):
            return String(describing: value)
        case .string(let value):
            return "\"" + value + "\""
        }
    }

    /// Represents itself int text.
    public var debugDescription: String {
        return description
    }
}
