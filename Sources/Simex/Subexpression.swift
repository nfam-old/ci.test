//
//  Expression.Subexpression.swift
//  Simex
//
//  Created by Ninh on 9/02/2015.
//  Copyright © 2015 Ninh. All rights reserved.
//

enum SubexpressionType {
    case slice
    case array
    case dictionary
}

protocol Subexpression {
    var subtype: SubexpressionType { get }
    func extract(_ input: ArraySlice<UInt8>) throws -> Expression.Result
}
