//
//  JSON+Collection.swift
//  JSON
//
//  Created by Ninh on 11/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

extension JSON {
    /// Returns an `Dictionary` of `Bool` if it is `JSON.dictionary` and
    /// every value within is `JSON.bool`, otherwise returns `nil`.
    public var dictionaryOfBool: [String: Bool]? {
        guard case .dictionary(let dictionary) = self else {
            return nil
        }
        var result = [String: Bool](minimumCapacity: dictionary.count)
        for (key, item) in dictionary {
            guard let value = item.toJSON().bool else {
                return nil
            }
            result[key] = value
        }
        return result
    }

    /// Returns an `Dictionary` of `Int` if it is `JSON.dictionary` and
    /// every value within is `JSON.int` or `JSON.double` onvertable
    /// to integer without losing precision, otherwise returns `nil`.
    public var dictionaryOfInt: [String: Int]? {
        guard case .dictionary(let dictionary) = self else {
            return nil
        }
        var result = [String: Int](minimumCapacity: dictionary.count)
        for (key, item) in dictionary {
            guard let value = item.toJSON().int else {
                return nil
            }
            result[key] = value
        }
        return result
    }

    /// Returns an `Dictionary` of `Double` if it is `JSON.dictionary` and
    // every value within is`JSON.double` or `JSON.int`, otherwise returns `nil`.
    public var dictionaryOfDouble: [String: Double]? {
        guard case .dictionary(let dictionary) = self else {
            return nil
        }
        var result = [String: Double](minimumCapacity: dictionary.count)
        for (key, item) in dictionary {
            guard let value = item.toJSON().double else {
                return nil
            }
            result[key] = value
        }
        return result
    }

    /// Returns an `Dictionary` of `String` if it is `JSON.dictionary` and
    /// every value within is `JSON.string`, otherwise returns `nil`.
    public var dictionaryOfString: [String: String]? {
        guard case .dictionary(let dictionary) = self else {
            return nil
        }
        var result = [String: String](minimumCapacity: dictionary.count)
        for (key, item) in dictionary {
            guard let value = item.toJSON().string else {
                return nil
            }
            result[key] = value
        }
        return result
    }
}
