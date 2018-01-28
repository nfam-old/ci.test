//
//  Expression.Result.swift
// Simex
//
//  Created by Ninh on 9/02/2015.
//  Copyright © 2015 Ninh. All rights reserved.
//

extension Expression {
    /// Represents the result from extraction by `Expression`.
    public enum Result {

        // Denotes a single string value.
        case string(String)

        // Denotes a containers holdding a list of `Result` in ordered sequence.
        case array([Result])

        // Denotes a container holding a list of `Result` by theirs unique labels.
        case dictionary([String: Result])
    }
}

extension Expression.Result {
    /// Returns a single string value if the `Result` is a single `Result.string`.
    public var string: String? {
        if case .string(let string) = self {
            return string
        }
        return nil
    }

    /// Returns an array of `Result` if the `Result` is an `Result.array`.
    public var array: [Expression.Result]? {
        if case .array(let array) = self {
            return array
        }
        return nil
    }

    /// Returns an array of `Result` if the `Result` is an `Result.dictionary`.
    public var dictionary: [String: Expression.Result]? {
        if case .dictionary(let dictionary) = self {
            return dictionary
        }
        return nil
    }

    /// Returns a `Result` element at a given index if the `Result` is an `Result.array`.
    ///
    /// - Parameter index: The position of the element to access. `index` must be
    ///   greater than or equal to 0 and less than the number of elements in the array.
    ///
    /// - Returns: If the `Result` is an array and the given `index` is within the range, then
    ///   returns the `Result` element at the given `index`, otherwise retuns `nil`.
    public subscript(index: Int) -> Expression.Result? {
        if index >= 0 {
            if let array = self.array, array.count > index {
                return array[index]
            }
        }
        return nil
    }

    /// Returns a `Result` value at a given key if the `Result` is a `Result.dictionary`.
    ///
    /// - Parameter key: The key of the value to access. `key` must exist in the dictionary.
    ///
    /// - Returns: If the `Result` is a dictionary and the given `key` exits, then
    ///   returns the `Result` value at the given `key`, otherwise retuns nil.
    public subscript(key: String) -> Expression.Result? {
        if let dictionary = self.dictionary {
            if let value = dictionary[key] {
                return value
            }
        }
        return nil
    }
}

extension Expression.Result: Encodable {

    /// Encodes this value into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let string):
            var container = encoder.singleValueContainer()
            try container.encode(string)
        case .array(let array):
            try array.encode(to: encoder)
        case .dictionary(let dictionary):
            try dictionary.encode(to: encoder)
        }
    }
}