//
//  JSONTests.swift
//  JSON
//
//  Created by Ninh on 10/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

@testable import JSON
import XCTest

class JSONStringifyTests: XCTestCase {

    static var allTests = [
        ("testNull", testNull),
        ("testBool", testBool),
        ("testInt", testInt),
        ("testDouble", testDouble),
        ("testString", testString),
        ("testArray", testArray),
        ("testDictionary", testDictionary)
    ]

    func testNull() {
        XCTAssertEqual(JSON.null.stringified(), "null")
        XCTAssertEqual(JSON.null.stringified(pretty: true), "null")
    }

    func testBool() {
        XCTAssertEqual(JSON(true).stringified(), "true")
        XCTAssertEqual(JSON(false).stringified(), "false")
        XCTAssertEqual(JSON(true).stringified(pretty: true), "true")
        XCTAssertEqual(JSON(false).stringified(pretty: true), "false")
    }

    func testInt() {
        XCTAssertEqual(JSON(1).stringified(), "1")
        XCTAssertEqual(JSON(-1).stringified(), "-1")
        XCTAssertEqual(JSON(1).stringified(pretty: true), "1")
    }

    func testDouble() {
        XCTAssertEqual(JSON(1.1).stringified(), "1.1")
        XCTAssertEqual(JSON(1.1).stringified(pretty: true), "1.1")
    }

    func testString() {
        let string1 = "test\"\\ / \u{08} \u{0} \u{0b} \u{0c} \n \r \t"
        let string2 = "\"test\\\"\\\\ \\/ \\b \\u0000 \\u000B \\f \\n \\r \\t\""
        XCTAssertEqual(JSON(string1).stringified(), string2)
        XCTAssertEqual(JSON(string1).stringified(pretty: true), string2)
    }

    func testArray() {
        let json: JSON = [false, 0, 1.1, "2"]

        XCTAssertEqual(json.stringified(),
            "[false,0,1.1,\"2\"]")

        XCTAssertEqual(json.stringified(pretty: true),
            "[\r\n\tfalse,\r\n\t0,\r\n\t1.1,\r\n\t\"2\"\r\n]")
    }

    func testDictionary() {
        let json: JSON = ["0": 0, "1.1": 1.1, "2": "2", "false": false]

        XCTAssertEqual(json.stringified(),
            "{\"0\":0,\"1.1\":1.1,\"2\":\"2\",\"false\":false}")

        XCTAssertEqual(json.stringified(pretty: true),
            "{\r\n\t\"0\": 0,\r\n\t\"1.1\": 1.1,\r\n\t\"2\": \"2\",\r\n\t\"false\": false\r\n}")
    }
}
