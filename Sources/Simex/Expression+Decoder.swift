//
//  Expresson+Decoder.swift
//  Simex
//
//  Created by Ninh on 11/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

extension Decoder {
    func singleValue(_ type: String.Type, forError errorType: Expression.ErrorType) throws -> String {
        let result: String
        do {
            let container = try self.singleValueContainer()
            result = try container.decode(type)
        }
        catch DecodingError.typeMismatch {
            throw Expression.Error(errorType)
        }
        return result
    }

    func container<T>(keyedBy type: T.Type, forError errorType: Expression.ErrorType) throws -> KeyedDecodingContainer<T> {
        let result: KeyedDecodingContainer<T>
        do {
            result = try self.container(keyedBy: type)
        }
        catch DecodingError.typeMismatch {
            throw Expression.Error(errorType)
        }
        return result
    }
}
