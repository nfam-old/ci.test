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
        guard let jsons = self.array else {
            return nil
        }
        var values = Array(repeating: false, count: jsons.count)
        var index = 0
        for json in jsons {
            guard let value = json.bool else {
                return nil
            }
            values[index] = value
            index += 1
        }
        return values
    }

    /// Returns an `Array` of `Int` if it is `JSON.array` and
    /// every value within is `JSON.int` or `JSON.double` onvertable
    /// to integer without losing precision, otherwise returns `nil`.
    public var arrayOfInt: [Int]? {
        guard let jsons = self.array else {
            return nil
        }
        var values = Array(repeating: 0, count: jsons.count)
        var index = 0
        for json in jsons {
            guard let value = json.int else {
                return nil
            }
            values[index] = value
            index += 1
        }
        return values
    }

    /// Returns an `Array` of `Double` if it is `JSON.array` and
    // every value within is`JSON.double` or `JSON.int`, otherwise returns `nil`.
    public var arrayOfDouble: [Double]? {
        guard let jsons = self.array else {
            return nil
        }
        var values = Array(repeating: 0.0, count: jsons.count)
        var index = 0
        for json in jsons {
            guard let value = json.double else {
                return nil
            }
            values[index] = value
            index += 1
        }
        return values
    }

    /// Returns an `Array` of `String` if it is `JSON.array` and
    /// every value within is `JSON.string`, otherwise returns `nil`.
    public var arrayOfString: [String]? {
        guard let jsons = self.array else {
            return nil
        }
        var values = Array(repeating: "", count: Int(jsons.count))
        var index = 0
        for json in jsons {
            guard let value = json.string else {
                return nil
            }
            values[index] = value
            index += 1
        }
        return values
    }
}
