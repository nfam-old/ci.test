//
// JSON+dictionaryOfTests.swift
// JSON
//
//  Created by Ninh on 10/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

@testable import JSON
import XCTest

class JSONDictionaryOfTests: XCTestCase {

    static var allTests = [
        ("testBool", testBool),
        ("testInt", testInt),
        ("testDouble", testDouble),
        ("testString", testString)
    ]

    func testBool() {
        XCTAssertNil(JSON.null.dictionaryOfBool)

        let dictionary1 = ["0": true, "1": false, "2": true]
        let json1 = JSON(dictionary1)
        XCTAssertNotNil(json1.dictionaryOfBool)
        if let dictionary = json1.dictionaryOfBool {
            XCTAssertEqual(dictionary, dictionary1)
        }

        let json2: JSON = ["0": true, "1": "false", "2": true]
        XCTAssertNil(json2.dictionaryOfBool)
    }

    func testInt() {
        XCTAssertNil(JSON.null.dictionaryOfInt)

        let dictionary1 = ["0": 0, "1": 1, "2": 2]
        let json1 = JSON(dictionary1)
        XCTAssertNotNil(json1.dictionaryOfInt)
        if let dictionary = json1.dictionaryOfInt {
            XCTAssertEqual(dictionary, dictionary1)
        }

        let json2: JSON = ["0": 0, "1": 1, "2": "2"]
        XCTAssertNil(json2.dictionaryOfInt)

        let dictionary3 = ["0": 0.0, "1": 1.0, "2": 2.0]
        let json3 = JSON(dictionary3)
        XCTAssertNotNil(json3.dictionaryOfInt)
        if let dictionary = json3.dictionaryOfInt {
            XCTAssertEqual(dictionary, dictionary1)
        }

        let dictionary4 = ["0": 0, "1": 1.1, "2": 2]
        let json4 = JSON(dictionary4)
        XCTAssertNil(json4.dictionaryOfInt)
    }

    func testDouble() {
        XCTAssertNil(JSON.null.dictionaryOfDouble)

        let dictionary1 = ["0": 0.0, "1": 1.1, "2": 2.2]
        let json1 = JSON(dictionary1)
        XCTAssertNotNil(json1.dictionaryOfDouble)
        if let dictionary = json1.dictionaryOfDouble {
            XCTAssertEqual(dictionary, dictionary1)
        }

        let json2: JSON = ["0": 0.0, "1": 1.1, "2": "2.2"]
        XCTAssertNil(json2.dictionaryOfDouble)

        let dictionary3 = ["0": 0, "1": 1, "2": 2]
        let json3 = JSON(dictionary3)
        XCTAssertNotNil(json3.dictionaryOfDouble)
        if let dictionary = json3.dictionaryOfDouble {
            XCTAssertEqual(dictionary, dictionary3.mapValues { Double($0) })
        }
    }

    func testString() {
        XCTAssertNil(JSON.null.dictionaryOfString)

        let dictionary1 = ["0": "0", "1": "1", "2": "2"]
        let json1 = JSON(dictionary1)
        XCTAssertNotNil(json1.dictionaryOfString)
        if let dictionary = json1.dictionaryOfString {
            XCTAssertEqual(dictionary, dictionary1)
        }

        let json2: JSON = ["0": "0", "1": 1, "2": "2"]
        XCTAssertNil(json2.dictionaryOfString)
    }
}