//
//  Processor.swift
//  Simex
//
//  Created by Ninh on 9/02/2015.
//  Copyright © 2015 Ninh. All rights reserved.
//

/// Holds a collection of user-defined processors to be hooked to an `Expression`.
public typealias Processors = [String: (String, String?) throws -> String]

extension Expression {
    struct Process {
        fileprivate let value: String
        fileprivate let function: (ArraySlice<UInt8>, String?) throws -> ArraySlice<UInt8>
        fileprivate let functionArgs: String?
    }
}

extension Expression.Process: Codable {
    init(from decoder: Decoder) throws {
        value = try decoder.singleValue(String.self, forError: .process)

        // Determines function name and args.
        let functionName: String
        if let index = value.index(of: ":") {
            functionName = String(value[value.startIndex ..< index])
            functionArgs = String(value[value.index(index, offsetBy: 1)...])
        }
        else {
            functionName = value
            functionArgs = nil
        }

        // Gets processors collection.
        if let pvalue = decoder.userInfo[Expression.processorsKey], let processors = pvalue as? Processors {
            guard let processor = processors[functionName] else {
                throw Expression.Error(.processUndefined)
            }
            function = { (input: ArraySlice<UInt8>, args: String?) throws -> ArraySlice<UInt8> in
                let string = try processor(input.toString(), args)
                let bytes = string.toBytes()
                return bytes[bytes.startIndex...]
            }
        }
        else {
            throw Expression.Error(.processUndefined)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}

extension Expression.Process {
    func extract(_ input: ArraySlice<UInt8>) throws -> ArraySlice<UInt8> {
        let result: ArraySlice<UInt8>
        do {
            result = try function(input, self.functionArgs)
        }
        catch {
            throw Expression.Error(.unmatch, at: "process")
        }
        return result
    }
}
