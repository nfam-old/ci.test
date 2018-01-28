//
//  Expression.Error.swift
//  EXJN
//
//  Created by Ninh on 9/02/2015.
//  Copyright © 2015 Ninh. All rights reserved.
//

extension Expression {

    /// Represents the type of `Expression.Error`.`
    public enum ErrorType {

        /// Property "array" must be an object.
        case array

        /// Property "backward" must be boolean.
        case backward

        /// Property "between" must be an object.
        case between

        /// Property "dictionary" must be an object.
        case dictionary

        /// Expression must be an object.
        case expression

        /// Property "has" must be a string.
        case has

        /// Member value of dictionary must be an object.
        case member

        /// Property "prefix" must be either a string or an array of strings.
        case prefix

        /// Property "process" must be a string in format "function[:args]" args is optional.
        case process

        /// Function is not found in processors.
        case processUndefined

        /// Property "required" must be boolean or a non-empty string.
        case required

        /// Property "separator" must be either a non-empty string or an array of non-empty strings.
        case separator

        ///"Property "separator" is missing.
        case separatorMissing

        /// Property "skip" must be either a string or an array of strings of "empty" or "invalid".
        case skip

        /// Property "slice" must be an object.
        case slice

        /// Only one of slice, array, and dictionary shall be defined.
        case subexpressions

        /// Property "suffix" must be either a string or an array of strings.
        case suffix

        /// Property "trim" must be boolean.
        case trim

        /// Provided input does not match the expression.
        case unmatch
    }
}

extension Expression {

    /// Holds the details of error thrown from initiating `Expression` or extracting content.
    public struct Error: Swift.Error {

        /// Returns the type of error.
        public let type: ErrorType

        /// Returns the location on the expression that threw error.
        public private(set) var at: String // swiftlint:disable:this identifier_name

        init(_ type: ErrorType, at location: String) {
            self.type = type
            self.at = location
        }

        init(_ type: ErrorType) {
            self.init(type, at: errors[type]!.1)
        }

        mutating func prepend(at prefix: String) {
            self.at = self.at != "" ? (prefix + "." + self.at) : prefix
        }
    }
}

extension Expression.Error {
    fileprivate var message: String {
        return errors[type]!.0
    }
}

extension Expression.Error: CustomStringConvertible {

    /// Represents itself int text.
    public var description: String {
        return message + " @ " + at
    }
}

extension Expression.Error: CustomDebugStringConvertible {

    /// Represents itself int text.
    public var debugDescription: String {
        return self.description
    }
}

private let errors: [Expression.ErrorType: (String, String)] = [
    .array: ("Property \"array\" must be an object.", "array"),
    .backward: ("Property \"backward\" must be boolean.", "between.backward"),
    .between: ("Property \"between\" must be an object.", "between"),
    .dictionary: ("Property \"dictionary\" must be an object.", "dictionary"),
    .expression: ("Expression must be an object.", ""),
    .has: ("Property \"has\" must be a string.", "has"),
    .member: ("Member value of dictionary must be an object.", ""),
    .prefix: ("Property \"prefix\" must be either a string or an array of strings.", "between.prefix"),
    .process: ("Property \"process\" must be a string in format \"function[:args]\" args is optional.", "process"),
    .processUndefined: ("Function is not found in processors.", "process"),
    .required: ("Property \"required\" must be boolean or a non-empty string.", "required"),
    .separator: ("Property \"separator\" must be either a non-empty string or an array of non-empty strings.", "separator"),
    .separatorMissing: ("Property \"separator\" is missing.", ""),
    .skip: ("Property \"skip\" must be either a string or an array of strings of \"empty\" or \"invalid\".", "skip"),
    .slice: ("Property \"slice\" must be an object.", "slice"),
    .subexpressions: ("Only one of slice, array, and dictionary shall be defined.", ""),
    .suffix: ("Property \"suffix\" must be either a string or an array of strings.", "between.suffix"),
    .trim: ("Property \"trim\" must be boolean.", "between.trim"),
    .unmatch: ("Provided input does not match the expression.", "")
]
