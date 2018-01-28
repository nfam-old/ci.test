//
//  Expression.Between.swift
//  Simex
//
//  Created by Ninh on 9/02/2015.
//  Copyright © 2015 Ninh. All rights reserved.
//

extension Expression {
    struct Between {
        fileprivate let backward: Bool?
        fileprivate let prefix: [Bytes]?
        fileprivate let suffix: [Bytes]?
        fileprivate let trim: Bool?

        fileprivate let prefixInArray: Bool
        fileprivate let suffixInArray: Bool
    }
}

extension Expression.Between: Codable {
    enum CodingKeys: String, CodingKey {
        case backward
        case prefix
        case suffix
        case trim
    }

    init(from decoder: Decoder) throws {

        // The container must be a dictionary.
        let container = try decoder.container(keyedBy: CodingKeys.self, forError: .between)

        // Gets the optional `backward`
        backward = try container.decodeIfDefined(Bool.self, forKey: .backward, forError: .backward)

        // Gets the optional `prefix`
        if let (strings, inArray) = try container.decodeIfDefined(
            valueOrArrayOf: String.self,
            forKey: .prefix,
            forError: .prefix
        ) {
            prefix = strings.map({ $0.toBytes() })
            prefixInArray = inArray
        }
        else {
            prefix = nil
            prefixInArray = false
        }

        // Gets the optional `suffix`.
        if let (strings, inArray) = try container.decodeIfDefined(
            valueOrArrayOf: String.self,
            forKey: .suffix,
            forError: .suffix
        ) {
            suffix = strings.map({ $0.toBytes() })
            suffixInArray = inArray
        }
        else {
            suffix = nil
            suffixInArray = false
        }

        // Gets the optional `trim`.
        trim = try container.decodeIfDefined(Bool.self, forKey: .trim, forError: .trim)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Sets the optional `backward`.
        try container.encodeIfPresent(backward, forKey: .backward)

        // Sets the optional `prefix` as an array of or a single string.
        if self.prefixInArray {
            try container.encodeIfPresent(prefix?.map({ $0.toString() }), forKey: .prefix)
        }
        else {
            try container.encodeIfPresent(prefix?[0].toString(), forKey: .prefix)
        }

        // Sets the optional `suffix` as an array of or a single string.
        if self.suffixInArray {
            try container.encodeIfPresent(suffix?.map({ $0.toString() }), forKey: .suffix)
        }
        else {
            try container.encodeIfPresent(suffix?[0].toString(), forKey: .suffix)
        }

        // Sets the optional `trim`.
        try container.encodeIfPresent(trim, forKey: .trim)
    }
}

extension Expression.Between {
    func extract(_ input: ArraySlice<UInt8>) throws -> ArraySlice<UInt8> {
        let backward = self.backward ?? false
        var bytes = input

        // prefix
        if let prefixes = self.prefix, prefixes.count > 0 {
            for (index, prefix) in prefixes.enumerated() where prefix.count > 0 {
                if backward {
                    guard let end = bytes.lastIndex(of: prefix) else {
                        let location = self.prefixInArray
                            ? "between.prefix." + prefix.toString() + "(" + String(index) + ")"
                            : "between.prefix."

                        throw Expression.Error(.unmatch, at: location)
                    }
                    bytes = bytes[bytes.startIndex ..< end]
                }
                else {
                    guard let start = bytes.index(of: prefix) else {
                        let location = self.prefixInArray
                            ? "between.prefix." + prefix.toString() + "(" + String(index) + ")"
                            : "between.prefix."

                        throw Expression.Error(.unmatch, at: location)
                    }
                    bytes = bytes[(start + prefix.count)...]
                }
            }
        }

        // suffix
        var suffixed = false
        var suffixesCount = 0
        if let suffixes = self.suffix, suffixes.count > 0 {
            for suffix in suffixes {
                suffixesCount += 1
                if suffix.count > 0 {
                    if backward {
                        if let start = bytes.lastIndex(of: suffix) {
                            bytes = bytes[(start + suffix.count)...]
                            suffixed = true
                            break
                        }
                    }
                    else {
                        if let end = bytes.index(of: suffix) {
                            bytes = bytes[bytes.startIndex ..< end]
                            suffixed = true
                            break
                        }
                    }
                }
                else {
                    suffixed = true
                    break
                }
            }
            if !suffixed && suffixesCount > 0 {
                throw Expression.Error(.unmatch, at: "between.suffix")
            }
        }

        // trim
        if let trim = self.trim, trim == true {
            var startIndex = bytes.startIndex
            for byte in bytes {
                if byte == 0x20 || (0x09 <= byte && byte <= 0x0D) {
                    startIndex += 1
                }
                else {
                    break
                }
            }
            bytes = bytes[startIndex...]

            var endIndex = bytes.endIndex
            for byte in bytes.reversed() {
                if byte == 0x20 || (0x09 <= byte && byte <= 0x0D) {
                    endIndex -= 1
                }
                else {
                    break
                }
            }
            bytes = bytes[startIndex ..< endIndex]
        }

        return bytes
    }
}
