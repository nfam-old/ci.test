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
        guard let djsons = self.dictionary else {
            return nil
        }
        var dvalues = [String: Bool](minimumCapacity: djsons.count)
        for (key, json) in djsons {
            guard let value = json.bool else {
                return nil
            }
            dvalues[key] = value
        }
        return dvalues
    }

    /// Returns an `Dictionary` of `Int` if it is `JSON.dictionary` and
    /// every value within is `JSON.int` or `JSON.double` onvertable
    /// to integer without losing precision, otherwise returns `nil`.
    public var dictionaryOfInt: [String: Int]? {
        guard let djsons = self.dictionary else {
            return nil
        }
        var dvalues = [String: Int](minimumCapacity: djsons.count)
        for (key, json) in djsons {
            guard let value = json.int else {
                return nil
            }
            dvalues[key] = value
        }
        return dvalues
    }

    /// Returns an `Dictionary` of `Double` if it is `JSON.dictionary` and
    // every value within is`JSON.double` or `JSON.int`, otherwise returns `nil`.
    public var dictionaryOfDouble: [String: Double]? {
        guard let djsons = self.dictionary else {
            return nil
        }
        var dvalues = [String: Double](minimumCapacity: djsons.count)
        for (key, json) in djsons {
            guard let value = json.double else {
                return nil
            }
            dvalues[key] = value
        }
        return dvalues
    }

    /// Returns an `Dictionary` of `String` if it is `JSON.dictionary` and
    /// every value within is `JSON.string`, otherwise returns `nil`.
    public var dictionaryOfString: [String: String]? {
        guard let djsons = self.dictionary else {
            return nil
        }
        var dvalues = [String: String](minimumCapacity: djsons.count)
        for (key, json) in djsons {
            guard let value = json.string else {
                return nil
            }
            dvalues[key] = value
        }
        return dvalues
    }
}
