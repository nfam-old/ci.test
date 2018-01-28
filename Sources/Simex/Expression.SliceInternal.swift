//
//  Expression.SliceInternal.swift
//  Simex
//
//  Created by Ninh on 9/02/2015.
//  Copyright © 2015 Ninh. All rights reserved.
//

extension Expression {
    enum SliceType {
        case root
        case slice
        case member
    }
}

extension Expression {
    struct SliceInternal {
        fileprivate let type: SliceType

        let required: Bool?
        let requiredLabel: String?

        fileprivate let has: Bytes?
        fileprivate let between: Expression.Between?
        fileprivate let process: Expression.Process?

        fileprivate let subexp: Subexpression?
    }
}

extension Expression.SliceInternal: Encodable {
    enum CodingKeys: String, CodingKey {
        case required
        case has
        case between
        case process
        case slice
        case array
        case dictionary
    }

    init(from decoder: Decoder, type: Expression.SliceType) throws {
        self.type = type

        // Makes sure input is a dictionary
        let container = try decoder.container(keyedBy: CodingKeys.self, forError:
            type == .root ? .expression
            : (type == .member ? .member
            : .slice)
        )

        do {
            // Gets the optional `required` if the slice is member.
            if type == .member && container.contains(.required) {
                do {
                    requiredLabel = try container.decode(String.self, forKey: .required)
                    required = requiredLabel != nil ? true : false
                }
                catch DecodingError.typeMismatch {
                    requiredLabel = nil
                    required = try container.decodeIfDefined(Bool.self, forKey: .required, forError: .required)
                }
                catch DecodingError.valueNotFound {
                    throw Expression.Error(.required)
                }
                if requiredLabel == "" {
                    throw Expression.Error(.required)
                }
            }
            else {
                required = nil
                requiredLabel = nil
            }

            // Gets the optional `has`.
            has = try container.decodeIfDefined(String.self, forKey: .has, forError: .has)?.toBytes()

            // Gets the optional `between`.
            between = try container.decodeIfDefined(Expression.Between.self, forKey: .between, forError: .between)

            // Gets the optional `process`.
            process = try container.decodeIfDefined(Expression.Process.self, forKey: .process, forError: .process)

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
            if type == .slice {
                error.prepend(at: "slice")
            }
            throw error
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Sets the optional `required`.
        if let requiredLabel = requiredLabel {
            try container.encode(requiredLabel, forKey: .required)
        }
        else {
            try container.encodeIfPresent(required, forKey: .required)
        }

        // Sets the optional `has`.
        try container.encodeIfPresent(has?.toString(), forKey: .has)

        // Sets the optional `between`.
        try container.encodeIfPresent(between, forKey: .between)

        // Sets the optional `process`.
        try container.encodeIfPresent(process, forKey: .process)

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

extension Expression.SliceInternal {
    func extract(_ input: ArraySlice<UInt8>) throws -> Expression.Result {
        let result: Expression.Result
        do {
            if let has = self.has, has.count > 0 {
                guard input.index(of: has) != nil else {
                    throw Expression.Error(.unmatch, at: "has")
                }
            }

            var bytes = input
            if let between = self.between {
                bytes = try between.extract(bytes)
            }

            if let process = self.process {
                bytes = try process.extract(bytes)
            }

            if let subexp = subexp {
                result = try subexp.extract(bytes)
            }
            else {
                result = Expression.Result.string(bytes.toString())
            }
        }
        catch var error as Expression.Error {
            if self.type == .slice {
                error.prepend(at: "slice")
            }
            throw error
        }
        return result
    }
}
