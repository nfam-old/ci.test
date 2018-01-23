//
//  JSON+Collection.swift
//  JSON
//
//  Created by Ninh on 11/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

extension JSON {
    /// Returns an `Array` of `Bool` if it is `JSON.array` and
    /// every value within is `JSON.bool`, otherwise returns `nil`.
    public var arrayOfBool: [Bool]? {
        guard case .array(let array) = self else {
            return nil
        }
        var result = Array(repeating: false, count: array.count)
        var index = 0
        for item in array {
            guard let value = item.toJSON().bool else {
                return nil
            }
            result[index] = value
            index += 1
        }
        return result
    }

    /// Returns an `Array` of `Int` if it is `JSON.array` and
    /// every value within is `JSON.int` or `JSON.double` onvertable
    /// to integer without losing precision, otherwise returns `nil`.
    public var arrayOfInt: [Int]? {
        guard case .array(let array) = self else {
            return nil
        }
        var result = Array(repeating: 0, count: array.count)
        var index = 0
        for item in array {
            guard let value = item.toJSON().int else {
                return nil
            }
            result[index] = value
            index += 1
        }
        return result
    }

    /// Returns an `Array` of `Double` if it is `JSON.array` and
    // every value within is`JSON.double` or `JSON.int`, otherwise returns `nil`.
    public var arrayOfDouble: [Double]? {
        guard case .array(let array) = self else {
            return nil
        }
        var result = Array(repeating: 0.0, count: array.count)
        var index = 0
        for item in array {
            guard let value = item.toJSON().double else {
                return nil
            }
            result[index] = value
            index += 1
        }
        return result
    }

    /// Returns an `Array` of `String` if it is `JSON.array` and
    /// every value within is `JSON.string`, otherwise returns `nil`.
    public var arrayOfString: [String]? {
        guard case .array(let array) = self else {
            return nil
        }
        var result = Array(repeating: "", count: Int(array.count))
        var index = 0
        for item in array {
            guard let value = item.toJSON().string else {
                return nil
            }
            result[index] = value
            index += 1
        }
        return result
    }
}
