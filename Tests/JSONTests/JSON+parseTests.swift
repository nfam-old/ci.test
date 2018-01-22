//
//  JSONParseTests.swift
//  JSON
//
//  Created by Ninh on 10/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

@testable import JSON
import XCTest

func assertThrows(
    _ expression: @autoclosure () throws -> JSON,
    _ errorDescription: String,
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertThrowsError(try expression(), file: file, line: line) { error in
        if let error = error as? JSON.ParsingError {
             XCTAssertEqual(error.description, errorDescription, file: file, line: line)
             XCTAssertEqual(error.debugDescription, errorDescription, file: file, line: line)
        } else {
            XCTFail("\((error))", file: file, line: line)
        }
    }
}

func assertNoThrow(
    _ expression: @autoclosure () throws -> JSON,
    file: StaticString = #file,
    line: UInt = #line,
    completion: (JSON) -> Void
) {
    var json: JSON?
    do {
        json = try expression()
    } catch {
        XCTFail("\((error))", file: file, line: line)
    }
    if let json = json {
        completion(json)
    }
}

class JSONParseTests: XCTestCase {

    static var allTests = [
        ("testDocument", testDocument),
        ("testNull", testNull),
        ("testBool", testBool)
    ]

    func testDocument() {
        assertThrows(try JSON.parse(string: ""), "Empty document")
        assertThrows(try JSON.parse(string: "  "), "Empty document")
        assertThrows(try JSON.parse(string: "+  "), "Unexpected token at (1,1)")
        assertThrows(try JSON.parse(string: " + "), "Unexpected token at (1,2)")
        assertThrows(try JSON.parse(string: " a "), "Unexpected token at (1,2)")
    }

    func testNull() {
        assertNoThrow(try JSON.parse(string: "null")) { json in
            XCTAssertTrue(json.type == .null)
        }
        assertNoThrow(try JSON.parse(string: " null")) { json in
            XCTAssertTrue(json.type == .null)
        }
        assertNoThrow(try JSON.parse(string: "null ")) { json in
            XCTAssertTrue(json.type == .null)
        }
        assertThrows(try JSON.parse(string: "null+"), "Unexpected token at (1,1)")
        assertThrows(try JSON.parse(string: "null +"), "Unexpected token at (1,6)")
    }

    func testBool() {
        assertNoThrow(try JSON.parse(string: "true")) { json in
            XCTAssertEqual(json.bool, true)
        }
        assertNoThrow(try JSON.parse(string: "false ")) { json in
            XCTAssertEqual(json.bool, false)
        }
        assertNoThrow(try JSON.parse(string: " true")) { json in
            XCTAssertEqual(json.bool, true)
        }
        assertNoThrow(try JSON.parse(string: "false ")) { json in
            XCTAssertEqual(json.bool, false)
        }
        assertThrows(try JSON.parse(string: "trueA"), "Unexpected token at (1,1)")
        assertThrows(try JSON.parse(string: "false A"), "Unexpected token at (1,7)")
    }
}
