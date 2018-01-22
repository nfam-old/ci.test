//
//  JSON+parse.swift
//  JSON
//
//  Created by Ninh on 11/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

//! swiftlint:disable cyclomatic_complexity
//! swiftlint:disable file_length
//! swiftlint:disable function_body_length
//! swiftlint:disable type_body_length

extension JSON {
    /// Parses a JSON string, constructing the `JSON`` value described by the string.
    ///
    /// - Parameter bytes: The string encoded in UTF8 to parse as JSON.
    /// - Parameter count: The number of bytes.
    /// - Retruns: A `JSON`` value.
    public static func parse(bytes: UnsafePointer<UInt8>, count: Int) throws -> JSON {
        let parser = Parser(bytes: bytes, count: count)
        guard let json = parser.parse() else {
            throw parser.error!
        }
        return json
    }

    /// Parses a JSON string, constructing the `JSON`` value described by the string.
    ///
    /// - Parameter bytes: The string encoded in UTF8 to parse as JSON.
    /// - Parameter count: The number of bytes.
    /// - Retruns: A `JSON`` value.
    public static func parse(bytes: [UInt8]) throws -> JSON {
        return try bytes.withUnsafeBufferPointer { buffer in
            return try JSON.parse(
                bytes: buffer.baseAddress!,
                count: buffer.count
            )
        }
    }

    /// Parses a JSON string, constructing the `JSON`` value described by the string.
    ///
    /// - Parameter bytes: The string to parse as JSON.
    /// - Retruns: A `JSON`` value.
    public static func parse(string: String) throws -> JSON {
        return try string.utf8CString.withUnsafeBytes { buffer in
            return try JSON.parse(
                bytes: buffer.baseAddress!.assumingMemoryBound(to: UInt8.self),
                count: buffer.count - 1
            )
        }
    }
}

extension JSON {
    /// Describes an error of parsing a JSON string.
    public struct ParsingError: Error, CustomStringConvertible, CustomDebugStringConvertible {
        fileprivate init(description: String) {
            self.description = description
        }

        /// Represents the error itself int text.
        public let description: String

        /// Represents the error itself int text.
        public var debugDescription: String {
            return description
        }
    }
}

private class Parser {
    let bytes: UnsafePointer<UInt8>
    let count: Int
    var index: Int = 0

    var buffer: [UInt8] = []

    // From RFC 7159, 2.5. Strings:
    //
    // To escape an extended character that is not in the Basic Multilingual
    // Plane, the character is represented as a twelve-character sequence,
    // encoding the UTF-16 surrogate pair.  So, for example, a string
    // containing only the G clef character (U+1D11E) may be represented as
    // "\uD834\uDD1E".
    var highSurrogate: UInt? // UTF16 high surrogate
    var highSurrogateIndex = 0

    var error: JSON.ParsingError?
    var line = 0
    var lineStartOffset = 0

    init(bytes: UnsafePointer<UInt8>, count: Int) {
        self.bytes = bytes
        self.count = count
    }

    fileprivate func parse() -> JSON? {
        guard index < count else {
            makeError(.emptyDocument)
            return nil
        }
        let json = parseValue()
        if json == nil {
            if error == nil {
                makeError(.emptyDocument)
                return nil
            }
        } else if index < count {
            skipWhitespaces()
            if index < count {
                makeError(.unexpectedToken)
                return nil
            }
        }
        return json
    }

    // value = false / null / true / object / array / number / string
    private func parseValue() -> JSON? {
        let byte = bytes[index]
        if byte == 0x2D || (byte >= 0x30 && byte <= 0x39) { // -, 0..9
            return parseNumber()
        } else {
            switch byte {
            case 0x22: // \"
                return parseString()
            case 0x5B: // [
                return parseArray()
            case 0x7B: // {
                return parseDictionary()
            case 0x20, 0x09, 0x0A, 0x0D: // space \t \n \r
                skipWhitespaces()
                if index < count {
                    return parseValue()
                } else {
                    return nil
                }
            default:
                return parseName()
            }
        }
    }

    // array           = begin-array [ value *( value-separator value ) ] end-array
    // begin-array     = ws %x5B ws  ; [ left square bracket
    // end-array       = ws %x5D ws  ; ] right square bracket
    // value-separator = ws %x2C ws  ; , comma
    private func parseArray() -> JSON? {
        var array = [JSON]()

        index += 1 // [
        while index < count {

            // ws
            skipWhitespaces()
            if index >= count { // unclosed ]
                makeError(.unclosedArray)
                return nil
            }

            // ]
            if bytes[index] == 0x5D {
                index += 1
                return JSON(array)
            }

            // value
            guard let value = parseValue() else {
                makeError(.unclosedArray)
                return nil
            }
            array.append(value)

            // ws
            skipWhitespaces()
            if index >= count { // unclosed ]
                makeError(.unclosedArray)
                return nil
            }

            // , or ]
            let byte = bytes[index]
            if byte == 0x2C {
                index += 1
                continue
            } else if byte == 0x5D {
                continue
            }

            // unepxected token
            makeError(.unexpectedToken)
            return nil
        }

        makeError(.unclosedArray)
        return nil // unclosed ]
    }

    // object          = begin-object [ member *( value-separator member ) ] end-object
    // begin-array     = ws %x5B ws  ; [ left square bracket
    // end-object      = ws %x7D ws  ; } right curly bracket
    // member          = string name-separator value
    // name-separator  = ws %x3A ws  ; : colon
    // value-separator = ws %x2C ws  ; , comma
    private func parseDictionary() -> JSON? {
        var dictionary = [String: JSON]()

        index += 1 // {
        while index < count {

            // ws
            skipWhitespaces()
            if index >= count { // unclosed }
                makeError(.unclosedDictionary)
                return nil
            }

            // }
            if bytes[index] == 0x7D {
                index += 1
                return JSON(dictionary)
            }

            // " is expected - "key"
            guard bytes[index] == 0x22 else {
                makeError(.unexpectedToken)
                return nil
            }
            guard let key = parseString()?.string else {
                return nil
            }

            // ws
            skipWhitespaces()
            if index >= count { // unclosed }
                makeError(.unclosedDictionary)
                return nil
            }

            // : is expected
            guard bytes[index] == 0x3A else {
                makeError(.unexpectedToken)
                return nil
            }
            index += 1

            // ws
            skipWhitespaces()
            if index >= count { // unclosed }
                makeError(.unclosedDictionary)
                return nil
            }

            // value
            guard let value = parseValue() else {
                makeError(.unclosedDictionary)
                return nil
            }

            // add to dictionary
            dictionary[key] = value

            // ws
            skipWhitespaces()
            if index >= count { // unclosed }
                makeError(.unclosedDictionary)
                return nil
            }

            // , or }
            let byte = bytes[index]
            if byte == 0x2C {
                index += 1
                continue
            } else if byte == 0x7D {
                continue
            }

            // unexpected token
            makeError(.unexpectedToken)
            return nil
        }

        makeError(.unclosedDictionary)
        return nil // unclosed }
    }

    // number        = [ minus ] int [ frac ] [ exp ]
    // decimal-point = %x2E       ; .
    // digit1-9      = %x31-39         ; 1-9
    // e             = %x65 / %x45            ; e E
    // exp           = e [ minus / plus ] 1*DIGIT
    // frac          = decimal-point 1*DIGIT
    // int           = zero / ( digit1-9 *DIGIT )
    // minus         = %x2D               ; -
    // plus          = %x2B                ; +
    // zero          = %x30                ; 0
    private func parseNumber() -> JSON? {
        enum State {
            case minusOrInt
            case zero
            case int
            case intDigits
            case frac
            case fracDigits
            case expSign
            case exp
            case expDigits
        }
        var state = State.minusOrInt
        var string = ""
        let firstIndex = index

        read: while index < count {
            let byte = bytes[index]

            // 0..9
            if 0x30 <= byte && byte <= 0x39 {
                switch state {
                case .minusOrInt:
                    if byte == 0x30 { // 0
                        state = .zero
                    } else {
                        state = .intDigits
                    }
                case .int:
                    guard byte != 0x30 else { // must not be 0
                        makeError(.numberSyntax)
                        return nil
                    }
                    state = .intDigits
                case .frac:
                    state = .fracDigits
                case .exp:
                    state = .expDigits
                case .intDigits, .fracDigits, .expDigits:
                    break
                default:
                    makeError(.numberSyntax)
                    return nil
                }

                let digit = String(byte - 0x30, radix: 10)
                string.append(digit)

            // + - e E .
            } else {

                switch byte {
                case 0x2D: // -
                    switch state {
                    case .minusOrInt:
                        state = .int
                    case .expSign:
                        state = .exp
                    default:
                        makeError(.numberSyntax)
                        return nil
                    }
                    string.append("-")

                case 0x2E: // .
                    switch state {
                    case .zero, .intDigits:
                        state = .frac
                    default:
                        makeError(.numberSyntax)
                        return nil
                    }
                    string.append(".")

                case 0x65, 0x45: // e E
                    switch state {
                    case .zero, .intDigits, .fracDigits:
                        state = .expSign
                    default:
                        makeError(.numberSyntax)
                        return nil
                    }
                    string.append(byte == 0x65 ? "e" : "E")

                case 0x2B: // +
                    switch state {
                    case .expSign:
                        state = .exp
                    default:
                        makeError(.numberSyntax)
                        return nil
                    }
                    string.append("+")

                case 0x2C, 0x5D, 0x7D, 0x20, 0x09, 0x0A, 0x0D:  // , ] } space \t \n \r
                    break read

                default:
                    makeError(.numberSyntax)
                    return nil
                }
            }

            index += 1
        }

        // number must be terminated at state of only Zero, or
        // reading remainding digits (from the 2nd on) of int, frac or exp
        switch state {
        case .zero:
            return JSON(0)
        case .intDigits:
            guard let value = Int(string, radix: 10) else {
                index = firstIndex
                makeError(.numberSyntax)
                return nil
            }
            return JSON(value)
        case .fracDigits, .expDigits:
            guard let value = Double(string) else {
                index = firstIndex
                makeError(.numberSyntax)
                return nil
            }
            return JSON(value)
        default:
            makeError(.numberSyntax)
            return nil
        }
    }

    // string         = quotation-mark *char quotation-mark
    // char           = unescaped / escaped
    // quotation-mark = %x22      ; "
    // unescaped      = %x20-21 / %x23-5B / %x5D-10FFFF
    private func parseString() -> JSON? {
        buffer.removeAll(keepingCapacity: true)

        // skip "
        index += 1
        while index < count {
            let byte = bytes[index]
            if byte == 0x5C { // \
                guard parseEscaped() else {
                    return nil
                }
            } else {
                if hasSurrogateError() {
                    return nil
                }
                if byte == 0x22 { // "
                    index += 1
                    return JSON(buffer.toString())
                } else if byte >= 0x20 { // valid unit, check code
                    let length = utf8Length(first: byte)

                    // Most of JSON needs one byte only, this is for performance.
                    if length == 1 {
                        buffer.append(byte)
                        index += 1
                    } else {
                        guard index + length <= count && (
                            (length == 2 && utf8Validate(byte, bytes[index + 1])) ||
                            (length == 3 && utf8Validate(byte, bytes[index + 1], bytes[index + 2])) ||
                            (length == 4 && utf8Validate(byte, bytes[index + 1], bytes[index + 2], bytes[index + 3]))
                        ) else {
                            makeError(.invalidCharacter)
                            return nil
                        }

                        buffer.append(byte)
                        if length == 2 {
                            buffer.append(bytes[index + 1])
                        } else if length == 3 {
                            buffer.append(bytes[index + 1])
                            buffer.append(bytes[index + 2])
                        } else if length == 4 {
                            buffer.append(bytes[index + 1])
                            buffer.append(bytes[index + 2])
                            buffer.append(bytes[index + 3])
                        }
                        index += length
                    }
                } else {
                    makeError(.invalidCharacter)
                    return nil
                }
            }
        }

        makeError(.unclosedString)
        return nil // unclosed "
    }

    // escaped =  escape (
    //            %x22 /          ; "    quotation mark  U+0022
    //            %x5C /          ; \    reverse solidus U+005C
    //            %x2F /          ; /    solidus         U+002F
    //            %x62 /          ; b    backspace       U+0008
    //            %x66 /          ; f    form feed       U+000C
    //            %x6E /          ; n    line feed       U+000A
    //            %x72 /          ; r    carriage return U+000D
    //            %x74 /          ; t    tab             U+0009
    //            %x75 4HEXDIG )  ; uXXXX                U+XXXX
    // escape = %x5C              ; \
    private func parseEscaped() -> Bool {
        index += 1 // \
        if index >= count {
            buffer.append(0x5C)
            return true // end of data, return true so it will raise unclosedString error
        }
        let byte = bytes[index]

        // \uXXXX -> Unicode escape sequences
        if byte == 0x75 {
            index += 1
            guard index + 4 <= count,
            let u0 = bytes[index].hexDecoded(),
            let u1 = bytes[index + 1].hexDecoded(),
            let u2 = bytes[index + 2].hexDecoded(),
            let u3 = bytes[index + 3].hexDecoded() else {
                makeError(.escapeSyntax)
                return false
            }
            let code = (UInt(u0) << 12) + (UInt(u1) << 8) + (UInt(u2) << 4) + UInt(u3)

            if 0xD800 <= code && code <= 0xDBFF { // UTF16 high surrogate
                if hasSurrogateError() {
                    return false
                }
                self.highSurrogate = code
                self.highSurrogateIndex = index
            } else if 0xDC00 <= code && code <= 0xDFFF { // UTF16 low surrogate
                guard let surrogate = self.highSurrogate else {
                    makeError(.unpairedSurrogate)
                    return false
                }
                self.highSurrogate = nil
                buffer.append(unicode: 0x10000 + ((surrogate & 0x03FF) << 10) + (code & 0x03FF))
            } else {
                if hasSurrogateError() {
                    return false
                }
                buffer.append(unicode: code)
            }
            index += 4
        } else {
            if hasSurrogateError() {
                return false
            }
            switch byte {
            case 0x22, 0x5C, 0x2F: // \", \\, \/
                buffer.append(byte)
            case 0x62: // \b
                buffer.append(0x08)
            case 0x66: // \f
                buffer.append(0x0C)
            case 0x6E: // \n
                buffer.append(0x0A)
            case 0x72: // \r
                buffer.append(0x0D)
            case 0x74: // \t
                buffer.append(0x09)
            default:
                makeError(.escapeSyntax)
                return false
            }
            index += 1
        }
        return true
    }

    // Returns the value indicating the UTF16 high surrogate is not paired
    private func hasSurrogateError() -> Bool {
        if highSurrogate != nil {
            index = highSurrogateIndex
            makeError(.unpairedSurrogate)
            return true
        }
        return false
    }

    // name = false / null / true
    func parseName() -> JSON? {
        var result: JSON?
        let firstIndex = index

        if result == nil
        && index + 4 <= count {

            if bytes[index + 0] == 0x74 // true
            && bytes[index + 1] == 0x72
            && bytes[index + 2] == 0x75
            && bytes[index + 3] == 0x65 {
                index += 4
                result = JSON(true)

            } else if bytes[index + 0] == 0x6E // null
            && bytes[index + 1] == 0x75
            && bytes[index + 2] == 0x6C
            && bytes[index + 3] == 0x6C {
                index += 4
                result = JSON.null
            }
        }

        if result == nil
        && index + 5 <= count {
            if bytes[index + 0] == 0x66 // false
            && bytes[index + 1] == 0x61
            && bytes[index + 2] == 0x6C
            && bytes[index + 3] == 0x73
            && bytes[index + 4] == 0x65 {
                index += 5
                result = false
            }
        }

        if result == nil {
            makeError(.unexpectedToken)
        } else if index < count {
            let byte = bytes[index]
            if !(byte == 0x2C   // ,
            || byte == 0x5D     // ]
            || byte == 0x7D     // }
            || byte == 0x20     // ws
            || (0x08 <= byte && byte <= 0x0D)) {
                index = firstIndex
                makeError(.unexpectedToken)
                result = nil
            }
        }
        return result
    }

    // ws = *(
    //            %x20 /              ; Space
    //            %x09 /              ; Horizontal tab
    //            %x0A /              ; Line feed or New line
    //            %x0D                ; Carriage return
    //        )
    func skipWhitespaces() {
        while index < count {
            let byte = bytes[index]
            if byte == 0x20 || byte == 0x09 || byte == 0x0A || byte == 0x0D {
                index += 1
                if byte == 0x0A {
                    line += 1
                    lineStartOffset = index
                }
            } else {
                break
            }
        }
    }

    func makeError(_ type: ParsingErrorType) {
        if error == nil {
            let x = (index < count ? index : (count - 1)) - lineStartOffset + 1
            let y = line + 1

            switch type {
            case .emptyDocument:
                error = JSON.ParsingError(description: "Empty document")
            case .unexpectedToken:
                error = JSON.ParsingError(description: "Unexpected token at (\(y),\(x))")
            case .unclosedArray:
                error = JSON.ParsingError(description: "Unclosed array")
            case .unclosedDictionary:
                error = JSON.ParsingError(description: "Unclosed dictionary")
            case .unclosedString:
                error = JSON.ParsingError(description: "Unclosed string")
            case .unpairedSurrogate:
                error = JSON.ParsingError(description: "Unpaired escaped surrogate at (\(y),\(x))")
            case .invalidCharacter:
                error = JSON.ParsingError(description: "Invalid character at (\(y),\(x))")
            case .numberSyntax:
                error = JSON.ParsingError(description: "Invalid number syntax at (\(y),\(x))")
            case .escapeSyntax:
                error = JSON.ParsingError(description: "Invalid escape syntax at (\(y),\(x))")
            }
        }
    }
}

extension Parser {
    fileprivate enum ParsingErrorType {
        case emptyDocument
        case unexpectedToken
        case unclosedArray
        case unclosedDictionary
        case unclosedString
        case invalidCharacter
        case unpairedSurrogate
        case numberSyntax
        case escapeSyntax
    }
}
