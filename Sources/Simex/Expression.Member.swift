//
//  Expression.Member.swift
//  Simex
//
//  Created by Ninh on 9/02/2015.
//  Copyright © 2015 Ninh. All rights reserved.
//

extension Expression {
    struct Member {
        fileprivate let slice: SliceInternal
    }
}

extension Expression.Member: Codable {
    init(from decoder: Decoder) throws {
        slice = try Expression.SliceInternal(from: decoder, type: .member)
    }

    func encode(to encoder: Encoder) throws {
        try slice.encode(to: encoder)
    }
}

extension Expression.Member {
    var required: Bool {
        return slice.required ?? true
    }

    var requiredLabel: String? {
        return slice.requiredLabel
    }

    func extract(_ input: ArraySlice<UInt8>) throws -> Expression.Result {
        return try slice.extract(input)
    }
}
