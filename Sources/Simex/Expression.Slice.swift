//
//  Expression.Slice.swift
//  Simex
//
//  Created by Ninh on 9/02/2015.
//  Copyright © 2015 Ninh. All rights reserved.
//

extension Expression {
    struct Slice {
        fileprivate let slice: SliceInternal
    }
}

extension Expression.Slice: Codable {
    init(from decoder: Decoder) throws {
        slice = try Expression.SliceInternal(from: decoder, type: .slice)
    }

    func encode(to encoder: Encoder) throws {
        try slice.encode(to: encoder)
    }
}

extension Expression.Slice: Subexpression {
    var subtype: SubexpressionType {
        return .slice
    }

    func extract(_ input: ArraySlice<UInt8>) throws -> Expression.Result {
        return try slice.extract(input)
    }
}
