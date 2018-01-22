//
//  JSONTests.swift
// JSON
//
//  Created by Ninh on 10/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

@testable import JSON
import XCTest

class JSONTests: XCTestCase {

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
        XCTAssertEqual(JSON.null.type, .null)

        XCTAssertEqual(JSON.null.debugDescription, "null")
        XCTAssertEqual(JSON(nil as Bool?).type, .null)
    }

    func testBool() {
        XCTAssertEqual(JSON.bool(true).type, .bool)
        XCTAssertEqual(JSON.bool(false).type, .bool)

        XCTAssertEqual(JSON.bool(true).bool, true)
        XCTAssertEqual(JSON.bool(false).bool, false)
        XCTAssertEqual(JSON(true).bool, true)
        XCTAssertEqual(JSON(false).bool, false)
        XCTAssertNil(JSON.null.bool)
        XCTAssertNil(JSON.string("test").bool)

        XCTAssertEqual(JSON(nil as Bool?).type, .null)
        XCTAssertEqual(JSON(true).description, "true")
        XCTAssertEqual(JSON(false).description, "false")
    }

    func testInt() {
        XCTAssertEqual(JSON.int(1234).type, .int)

        XCTAssertEqual(JSON.int(1234).int, 1234)
        XCTAssertEqual(JSON(1234).int, 1234)
        XCTAssertNil(JSON.null.int)
        XCTAssertNil(JSON.string("test").int)

        XCTAssertEqual(JSON.double(1234.0).int, 1234)
        XCTAssertEqual(JSON(1234.0).int, 1234)
        XCTAssertNil(JSON.double(1234.1).int)
        XCTAssertNil(JSON(1234.1).int)

        XCTAssertEqual(JSON(nil as Int?).type, .null)
        XCTAssertEqual(JSON(1234).description, "1234")
    }

    func testDouble() {
        XCTAssertEqual(JSON.double(1234).type, .double)

        XCTAssertEqual(JSON.double(1234.1).double, 1234.1)
        XCTAssertEqual(JSON(1234.1).double, 1234.1)
        XCTAssertNil(JSON.null.double)
        XCTAssertNil(JSON.string("test").double)

        XCTAssertEqual(JSON.int(1234).double, 1234.0)
        XCTAssertEqual(JSON(1234).double, 1234.0)

        XCTAssertEqual(JSON(nil as Double?).type, .null)
        XCTAssertEqual(JSON(1234.0).description, "1234.0")
        XCTAssertEqual(JSON(1234.1).description, "1234.1")
    }

    func testString() {
        XCTAssertEqual(JSON.string("test").type, .string)

        XCTAssertEqual(JSON.string("test").string, "test")
        XCTAssertEqual(JSON("test").string, "test")
        XCTAssertNil(JSON.null.bool)
        XCTAssertNil(JSON.int(1234).string)

        XCTAssertEqual(JSON(nil as String?).type, .null)
        XCTAssertEqual(JSON("test").description, "\"test\"")

        enum TestEnum: String {
            case red = "redColor"
        }
        XCTAssertEqual(JSON(TestEnum.red).string, "redColor")
        XCTAssertEqual(JSON(nil as TestEnum?).type, .null)
    }

    func testArray() {
        let array = [JSON(1), JSON("2")]
        let json = JSON(array)

        XCTAssertEqual(json.type, .array)

        XCTAssertNotNil(json.array)
        XCTAssertEqual(json.array?[0].int, 1)
        XCTAssertEqual(json.array?[1].string, "2")
        XCTAssertEqual(json[0].int, 1)
        XCTAssertEqual(json[1].string, "2")
        XCTAssertEqual(json[-1].type, .null)
        XCTAssertEqual(json[2].type, .null)
        XCTAssertEqual(JSON(1)[0].type, .null)

        XCTAssertEqual(JSON(nil as [JSON]?).type, .null)
        XCTAssertEqual(json.description, "[1, \"2\"]")
    }

    func testDictionary() {
        let dictionary = [
            "1": JSON.int(1),
            "2": JSON.string("2")
        ]
        let json = JSON.dictionary(dictionary)

        XCTAssertEqual(json.type, .dictionary)

        XCTAssertNotNil(json.dictionary)
        XCTAssertEqual(json.dictionary?["1"]?.int, 1)
        XCTAssertEqual(json.dictionary?["2"]?.string, "2")
        XCTAssertEqual(json["1"].int, 1)
        XCTAssertEqual(json["2"].string, "2")
        XCTAssertNil(json["3"].string)
        XCTAssertEqual(JSON(1)["1"].type, .null)

        XCTAssertEqual(JSON(nil as [String: JSON]?).type, .null)
        XCTAssertEqual(JSON(["1": "1"]).description, "[\"1\": \"1\"]")
    }
}
