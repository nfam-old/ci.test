//
//  Decoder.swift
//  Simex
//
//  Created by Ninh on 11/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

extension KeyedDecodingContainer {

    /// Returns the value if the key is defined, nil otherwise.
    func decodeIfDefined(
        _ type: Bool.Type,
        forKey key: KeyedDecodingContainer.Key,
        forError errorType: Expression.ErrorType
    ) throws -> Bool? {
        guard self.contains(key) else {
            return nil
        }
        let result: Bool?
        do {
            result = try self.decode(type, forKey: key)
        }
        catch DecodingError.typeMismatch {
            throw Expression.Error(errorType)
        }
        catch DecodingError.valueNotFound {
            throw Expression.Error(errorType)
        }
        return result
    }

    /// Returns the value if the key is defined, nil otherwise.
    func decodeIfDefined(
        _ type: String.Type,
        forKey key: KeyedDecodingContainer.Key,
        forError errorType: Expression.ErrorType
    ) throws -> String? {
        guard self.contains(key) else {
            return nil
        }
        let result: String?
        do {
            result = try self.decode(type, forKey: key)
        }
        catch DecodingError.typeMismatch {
            throw Expression.Error(errorType)
        }
        catch DecodingError.valueNotFound {
            throw Expression.Error(errorType)
        }
        return result
    }

    /// Returns the value if the key is defined, nil otherwise.
    func decodeIfDefined<T>(
        _ type: T.Type,
        forKey key: KeyedDecodingContainer.Key,
        forError errorType: Expression.ErrorType
    ) throws -> T? where T: Decodable {
        guard self.contains(key) else {
            return nil
        }
        let result: T?
        do {
            result = try self.decode(type, forKey: key)
        }
        catch DecodingError.typeMismatch {
            throw Expression.Error(errorType)
        }
        catch DecodingError.valueNotFound {
            throw Expression.Error(errorType)
        }
        return result
    }

    /// Returns the single value or an array of value if the key is defined, nil otherwise.
    func decodeIfDefined(
        valueOrArrayOf type: String.Type,
        forKey key: KeyedDecodingContainer.Key,
        forError errorType: Expression.ErrorType
    ) throws -> ([String], Bool)? {
        guard self.contains(key) else {
            return nil
        }
        let result: ([String], Bool)?
        do {
            let string = try self.decode(String.self, forKey: key)
            result = ([string], false)
        }
        catch DecodingError.typeMismatch {
            do {
                let strings = try self.decode([String].self, forKey: key)
                result = (strings, true)
            }
            catch DecodingError.typeMismatch {
                throw Expression.Error(errorType)
            }
        }
        catch DecodingError.valueNotFound {
            throw Expression.Error(errorType)
        }
        return result
    }
}
