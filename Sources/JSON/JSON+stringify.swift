//
//  JSON+serialize.swift
//  JSON
//
//  Created by Ninh on 12/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

extension JSON {

    /// Returns stringifed JSON in UTF8 encoding.
    ///
    /// - Paramter pretty: Specifies whether white space and indentation
    /// will be used to make the output more readable. Default is `true`.
    ///
    /// - Returns: Bytes of stringified JSON in UTF8 encoding.
    public func serialized(pretty: Bool = false) -> [UInt8] {
        return Serializer(pretty: pretty).serialize(self)
    }

    // Returns stringifed JSON in `String`.
    ///
    /// - Paramter pretty: Specifies whether white space and indentation
    /// will be used to make the output more readable. Default is `true`.
    ///
    /// - Returns: Stringified JSON in `String`.
    public func stringified(pretty: Bool = false) -> String {
        return self.serialized(pretty: pretty).toString()
    }
}

private class Serializer {

    var buffer: [UInt8] = []
    var pretty: Bool
    var level: Int = 0
    var line: Int = 0

    init(pretty: Bool) {
        self.pretty = pretty
    }

    func serialize(_ json: JSON) -> [UInt8] {
        populate(json: json)
        let result = self.buffer
        self.buffer = []
        return result
    }

    private func populate(json: JSON) {
        switch json {

        case .null:
            buffer.append(0x6E)
            buffer.append(0x75)
            buffer.append(0x6C)
            buffer.append(0x6C)

        case .dictionary(let value):
            populate(dictionary: value)

        case .array(let value):
            populate(array: value)

        case .double(let value):
            buffer.append(contentsOf: String(value).utf8)

        case .int(let value):
            populate(int: value)

        case .bool(let value):
            if value {
                buffer.append(0x74)
                buffer.append(0x72)
                buffer.append(0x75)
                buffer.append(0x65)
            } else {
                buffer.append(0x66)
                buffer.append(0x61)
                buffer.append(0x6C)
                buffer.append(0x73)
                buffer.append(0x65)
            }

        case .string(let value):
            populate(string: value)
        }
    }

    private func populate(array: [JSON]) {

        // Append array-begin "[".
        buffer.append(0x5B)

        // Indent in.
        level += 1
        var hasItems = false

        // Populate values.
        for element in array {

            // Append value-separator ",".
            if hasItems {
                buffer.append(0x2C)
            } else {
                hasItems = true
            }

            if pretty {
                appendIndent()
            }

            // Append value.
            populate(json: element)
        }

        // Indent out.
        level -= 1
        if pretty && hasItems {
            appendIndent()
        }

        // Append array-end "]".
        buffer.append(0x5D)
    }

    private func populate(dictionary: [String: JSON]) {

        // Append object-begin "[".
        buffer.append(0x7B)

        if dictionary.isEmpty {
            buffer.append(0x7D) // }
            return
        }

        // Indent in.
        level += 1
        var hasItems = false

        // Object propertys' name should be printed out sortedly.
        for name in dictionary.keys.sorted() {

            // Append value-separator ",".
            if hasItems {
                buffer.append(0x2C)
            } else {
                hasItems = true
            }

            if pretty {
                appendIndent()
            }

            // Append name.
            populate(string: name)

            // Append name-separator ":".
            buffer.append(0x3A)

            if pretty {
                buffer.append(0x20) // ws
            }

            // Append value.
            populate(json: dictionary[name]!)
        }

        // Indent out.
        level -= 1
        if pretty && hasItems {
            appendIndent()
        }

        // Append object-end "}".
        buffer.append(0x7D)
    }

    private func populate(int: Int) {
        var value = int
        if value < 0 {
            buffer.append(0x2D) // '-'
            value = -value
        }

        var stack: [UInt8] = []
        repeat {
            let next = value / 10
            stack.append(UInt8(value - (next * 10)))
            value = next
        } while value > 0

        for digit in stack.reversed() {
            buffer.append(digit + 0x30)
        }
    }

    private func populate(string: String) {
        buffer.append(0x22) // "
        for byte in string.utf8 {
            if byte < 0x20 {
                buffer.append(0x5C)
                switch byte {
                case 0x08: // \b
                    buffer.append(0x62)
                case 0x0C: // \f
                    buffer.append(0x66)
                case 0x0A: // \n
                    buffer.append(0x6E)
                    line += 1
                case 0x0D: // \r
                    buffer.append(0x72)
                case 0x09: // \t
                    buffer.append(0x74)
                default: // \u00XX
                    buffer.append(0x75)
                    buffer.append(0x30)
                    buffer.append(0x30)
                    buffer.append(byte.hexEncoded(of: .high))
                    buffer.append(byte.hexEncoded(of: .low))
                }
            } else {
                switch byte {
                case 0x22: // \"
                    buffer.append(0x5C)
                    buffer.append(0x22)
                case 0x2F: // \/
                    buffer.append(0x5C)
                    buffer.append(0x2F)
                case 0x5C: // \\
                    buffer.append(0x5C)
                    buffer.append(0x5C)
                default:
                    buffer.append(byte)
                }
            }
        }
        buffer.append(0x22) // "
    }

    private func appendIndent() {
        if pretty {
            buffer.append(0x0D)
            buffer.append(0x0A)
            for _ in 0 ..< level {
                buffer.append(0x09)
            }
        }
    }
}
