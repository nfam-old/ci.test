//
//  Expression.swift
//  Simex
//
//  Created by Ninh on 9/02/2015.
//  Copyright © 2015 Ninh. All rights reserved.
//

 /// Represents an instance of `Expression`.
public struct Expression: Codable {

    /// The addiotional key for hooking a collection of user-defined
    /// processors to the `Expression`.
    public static let processorsKey = CodingUserInfoKey(rawValue: "processors")!

    private let slice: SliceInternal

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws `Expression.Error`: If the provided expression definition is invalid.
    public init(from decoder: Decoder) throws {
        slice = try SliceInternal(from: decoder, type: .root)
    }

    /// Encodes this value into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        try self.slice.encode(to: encoder)
    }

    /// Returns the extraction result from input string.
    ///
    /// - Parameter input: An input string to extract content from.
    /// - Returns: An `Expression.Result`.
    /// - Throws `Expression.Error`: If the input does not comply to the expression.
    public func extract(_ input: String) throws -> Result {
        let bytes = input.toBytes()
        return try self.slice.extract(bytes[bytes.startIndex...])
    }
}
