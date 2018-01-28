//
//  Expression.Dictionary.swift
//  Simex
//
//  Created by Ninh on 9/02/2015.
//  Copyright © 2015 Ninh. All rights reserved.
//

extension Expression {
    struct Dictionary {
        fileprivate let members: [String: Member]
    }
}

extension Expression.Dictionary: Codable {
    struct CodingKeys: CodingKey {
        var intValue: Int?
        var stringValue: String

        init?(intValue: Int) { self.intValue = intValue; self.stringValue = "\(intValue)" }
        init?(stringValue: String) { self.stringValue = stringValue }
    }

    init(from decoder: Decoder) throws {

        // The container must be a dictionary.
        let container = try decoder.container(keyedBy: CodingKeys.self, forError: .dictionary)

        // Loops throught all keys.
        var members = [String: Expression.Member](minimumCapacity: container.allKeys.count)
        for key in container.allKeys {
            do {
                let member = try container.decodeIfDefined(Expression.Member.self, forKey: key, forError: .member)
                members[key.stringValue] = member
            }
            catch var error as Expression.Error {
                error.prepend(at: "dictionary." + key.stringValue)
                throw error
            }
        }
        self.members = members
    }

    func encode(to encoder: Encoder) throws {
        try members.encode(to: encoder)
    }
}

extension Expression.Dictionary: Subexpression {
    var subtype: SubexpressionType {
        return .dictionary
    }

    func extract(_ input: ArraySlice<UInt8>) throws -> Expression.Result {
        var results: [String: Expression.Result] = [:]
        var errors: [String: Expression.Error] = [:]
        var valid: [String: Bool] = [:]

        for (name, member) in members {
            do {
                results[name] = try member.extract(input)
                if let requiredLabel = member.requiredLabel {
                    errors[requiredLabel] = nil
                    valid[requiredLabel] = true
                }
            }
            catch var error as Expression.Error {
                if member.required {
                    guard let requiredLabel = member.requiredLabel else {
                        error.prepend(at: "dictionary." + name)
                        throw error
                    }
                    if valid[requiredLabel] == nil {
                        error.prepend(at: "dictionary." + name + "(" + requiredLabel + ")")
                        errors[requiredLabel] = error
                    }
                }
            }
        }

        if let error = errors.first?.value {
            throw error
        }

        return Expression.Result.dictionary(results)
    }
}
