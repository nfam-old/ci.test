//
//  Expression.Array.swift
//  Simex
//
//  Created by Ninh on 9/02/2015.
//  Copyright © 2015 Ninh. All rights reserved.
//

private enum SkipType: String {
    case empty
    case invalid
}

extension Expression {
    struct Array {
        fileprivate let separator: [Bytes]
        fileprivate let skip: [SkipType]?
        fileprivate let subexp: Subexpression?

        fileprivate let separatorInArray: Bool
        fileprivate let skipInArray: Bool
    }
}

extension Expression.Array: Codable {
    enum CodingKeys: String, CodingKey {
        case separator
        case skip
        case slice
        case array
        case dictionary
    }

    init(from decoder: Decoder) throws {
        // The container must be a dictionary.
        let container = try decoder.container(keyedBy: CodingKeys.self, forError: .array)

        do {
            // Gets the required `separator`.
            if let (strings, inArray) = try container.decodeIfDefined(
                valueOrArrayOf: String.self,
                forKey: .separator,
                forError: .separator
            ) {
                separator = strings.map({ $0.toBytes() })
                separatorInArray = inArray

                for item in separator where item.count == 0 {
                    throw Expression.Error(.separator)
                }
            }
            else {
                throw Expression.Error(.separatorMissing)
            }

            // Gets the optional `skip`.
            if let (strings, inArray) = try container.decodeIfDefined(
                valueOrArrayOf: String.self,
                forKey: .skip,
                forError: .skip) {
                self.skip = try strings.map { value in
                    guard let skip = SkipType(rawValue: value) else {
                        throw Expression.Error(.skip)
                    }
                    return skip
                }
                self.skipInArray = inArray
            }
            else {
                skip = nil
                skipInArray = false
            }

            // Gets the optional one of `slice`, `array`, `dictioanry`.
            if container.contains(.slice) {
                guard !container.contains(.array) && !container.contains(.dictionary) else {
                        throw Expression.Error(.subexpressions)
                }
                subexp = try container.decodeIfDefined(
                    Expression.Slice.self,
                    forKey: .slice,
                    forError: .slice)
            }
            else if container.contains(.array) {
                guard !container.contains(.dictionary) else {
                    throw Expression.Error(.subexpressions)
                }
                subexp = try container.decodeIfDefined(
                    Expression.Array.self,
                    forKey: .array,
                    forError: .array)
            }
            else if container.contains(.dictionary) {
                subexp = try container.decodeIfDefined(
                    Expression.Dictionary.self,
                    forKey: .dictionary,
                    forError: .dictionary)
            }
            else {
                subexp = nil
            }
        }
        catch var error as Expression.Error {
            error.prepend(at: "array")
            throw error
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Sets the optional `separator`.
        if self.separatorInArray {
            try container.encodeIfPresent(separator.map({ $0.toString() }), forKey: .separator)
        }
        else {
            try container.encodeIfPresent(separator[0].toString(), forKey: .separator)
        }

        // Sets the optional `skip`.
        if self.skipInArray {
            try container.encodeIfPresent(skip?.map({ $0.rawValue }), forKey: .skip)
        }
        else {
            try container.encodeIfPresent(skip?[0].rawValue, forKey: .skip)
        }

        // Sets the optional one of `slice`, `array`, `dictioanry`.
        if let subexp = self.subexp {
            switch subexp.subtype {
            case .slice:
                if let value = subexp as? Expression.Slice {
                    try container.encode(value, forKey: .slice)
                }
            case .array:
                if let value = subexp as? Expression.Array {
                    try container.encode(value, forKey: .array)
                }
            case .dictionary:
                if let value = subexp as? Expression.Dictionary {
                    try container.encode(value, forKey: .dictionary)
                }
            }
        }
    }
}

extension Expression.Array: Subexpression {
    var subtype: SubexpressionType {
        return .array
    }

    func extract(_ input: ArraySlice<UInt8>) throws -> Expression.Result {
        let skip = self.skip ?? [SkipType]()
        var results: [Expression.Result] = []
        do {
            var items = [input]
            for separator in self.separator {
                var array: [ArraySlice<UInt8>] = []
                for item in items {
                    array.append(contentsOf: item.split(separator: separator))
                }
                items = array
            }
            for item in items {
                if skip.contains(.empty) && item.count == 0 {
                    continue
                }
                if let subexp = self.subexp {
                    do {
                        let result = try subexp.extract(item)
                        if case .string(let string) = result, string == "" && skip.contains(.empty) {
                            continue
                        }
                        else {
                            results.append(result)
                        }
                    }
                    catch {
                        if !skip.contains(.invalid) {
                            throw error
                        }
                    }
                }
                else {
                    results.append(Expression.Result.string(item.toString()))
                }
            }
        }
        catch var error as Expression.Error {
            error.prepend(at: "array")
            throw error
        }
        return Expression.Result.array(results)
    }
}
