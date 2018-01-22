//
// JSON+arrayOfTests.swift
// JSON
//
//  Created by Ninh on 10/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

@testable import JSON
import XCTest

class JSONArrayOfTests: XCTestCase {

    static var allTests = [
        ("testBool", testBool),
        ("testInt", testInt),
        ("testDouble", testDouble),
        ("testString", testString)
    ]

    func testBool() {
        XCTAssertNil(JSON.null.arrayOfBool)

        let array1 = [true, false, true]
        let json1 = JSON(array1)
        XCTAssertNotNil(json1.arrayOfBool)
        if let array = json1.arrayOfBool {
            XCTAssertEqual(array, array1)
        }

        let json2: JSON = [true, "false", true]
        XCTAssertNil(json2.arrayOfBool)
    }

    func testInt() {
        XCTAssertNil(JSON.null.arrayOfInt)

        let array1 = [0, 1, 2]
        let json1 = JSON(array1)
        XCTAssertNotNil(json1.arrayOfInt)
        if let array = json1.arrayOfInt {
            XCTAssertEqual(array, array1)
        }

        let json2: JSON = [0, 1, "2"]
        XCTAssertNil(json2.arrayOfInt)

        let array3 = [0.0, 1.0, 2.0]
        let json3 = JSON(array3)
        XCTAssertNotNil(json3.arrayOfInt)
        if let array = json3.arrayOfInt {
            XCTAssertEqual(array, array1)
        }

        let array4 = [0, 1.1, 2]
        let json4 = JSON(array4)
        XCTAssertNil(json4.arrayOfInt)
    }

    func testDouble() {
        XCTAssertNil(JSON.null.arrayOfDouble)

        let array1 = [0.0, 1.1, 2.2]
        let json1 = JSON(array1)
        XCTAssertNotNil(json1.arrayOfDouble)
        if let array = json1.arrayOfDouble {
            XCTAssertEqual(array, array1)
        }

        let json2: JSON = [0.0, 1.1, "2.2"]
        XCTAssertNil(json2.arrayOfDouble)

        let array3 = [0, 1, 2]
        let json3 = JSON(array3)
        XCTAssertNotNil(json3.arrayOfDouble)
        if let array = json3.arrayOfDouble {
            XCTAssertEqual(array, array3.map { Double($0) })
        }
    }

    func testString() {
        XCTAssertNil(JSON.null.arrayOfString)

        let array1 = ["0", "1", "2"]
        let json1 = JSON(array1)
        XCTAssertNotNil(json1.arrayOfString)
        if let array = json1.arrayOfString {
            XCTAssertEqual(array, array1)
        }

        let json2: JSON = ["0", 1, "2"]
        XCTAssertNil(json2.arrayOfString)
    }
}