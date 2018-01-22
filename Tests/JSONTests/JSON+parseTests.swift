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
        ("testBool", testBool),
        ("testInt", testInt),
        ("testDouble", testDouble),
        ("testDoubleExp", testDoubleExp),
        ("testUTF8", testUTF8)
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

    // number        = [ minus ] int [ frac ] [ exp ]
    // decimal-point = %x2E       ; .
    // digit1-9      = %x31-39         ; 1-9
    // e             = %x65 / %x45            ; e E
    // exp           = e [ minus / plus ] 1*DIGIT
    // frac          = decimal-point 1*DIGIT
    // int           = zero / ( digit1-9 *DIGIT )
    // minus         = %x2D               ; -
    // plus          = %x2B                ; +
    // zero          = %x30                ; 0

    func testInt() {
        assertThrows(try JSON.parse(string: "+"), "Unexpected token at (1,1)")
        assertThrows(try JSON.parse(string: "-"), "Invalid number syntax at (1,1)")
        assertThrows(try JSON.parse(string: "+0"), "Unexpected token at (1,1)")
        assertNoThrow(try JSON.parse(string: "0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertThrows(try JSON.parse(string: "-0"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "00"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "01"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "+10"), "Unexpected token at (1,1)")
        assertNoThrow(try JSON.parse(string: "10")) { json in
            XCTAssertEqual(json.int, 10)
            XCTAssertEqual(json.double, 10.0)
        }
        assertNoThrow(try JSON.parse(string: " 10 ")) { json in
            XCTAssertEqual(json.int, 10)
            XCTAssertEqual(json.double, 10.0)
        }
        assertNoThrow(try JSON.parse(string: "-10")) { json in
            XCTAssertEqual(json.int, -10)
            XCTAssertEqual(json.double, -10.0)
        }
        assertNoThrow(try JSON.parse(string: " -10 ")) { json in
            XCTAssertEqual(json.int, -10)
            XCTAssertEqual(json.double, -10.0)
        }
        assertThrows(try JSON.parse(string: "10-"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "10A"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "10+"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "10-2"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "10+3"), "Invalid number syntax at (1,3)")

        assertThrows(try JSON.parse(string: "9999999999999999999999999999999999"), "Invalid number syntax at (1,1)")
    }

    func testDouble() {
        assertThrows(try JSON.parse(string: "0."), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "00."), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "01."), "Invalid number syntax at (1,2)")
        assertNoThrow(try JSON.parse(string: "0.00")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0.10")) { json in
            XCTAssertNil(json.int)
            XCTAssertEqual(json.double, 0.1)
        }
        assertThrows(try JSON.parse(string: "12."), "Invalid number syntax at (1,3)")
        assertNoThrow(try JSON.parse(string: "12.00")) { json in
            XCTAssertEqual(json.int, 12)
            XCTAssertEqual(json.double, 12.0)
        }
        assertNoThrow(try JSON.parse(string: "12.1")) { json in
            XCTAssertNil(json.int)
            XCTAssertEqual(json.double, 12.1)
        }
        assertThrows(try JSON.parse(string: "12.1."), "Invalid number syntax at (1,5)")
    }

    func testDoubleExp() {
        assertThrows(try JSON.parse(string: "-e"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "-E"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "1e"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "1E"), "Invalid number syntax at (1,2)")
        assertThrows(try JSON.parse(string: "1.e"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "1.E"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "1e+"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "1E+"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "1e-"), "Invalid number syntax at (1,3)")
        assertThrows(try JSON.parse(string: "1E-"), "Invalid number syntax at (1,3)")

        assertNoThrow(try JSON.parse(string: "0e+0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0E+0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0e-0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0E-0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0.0e+0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0.0E+0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0.0e-0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "0.0E-0")) { json in
            XCTAssertEqual(json.int, 0)
            XCTAssertEqual(json.double, 0.0)
        }
        assertNoThrow(try JSON.parse(string: "1e+0")) { json in
            XCTAssertEqual(json.int, 1)
            XCTAssertEqual(json.double, 1.0)
        }
        assertNoThrow(try JSON.parse(string: "1e-0")) { json in
            XCTAssertEqual(json.int, 1)
            XCTAssertEqual(json.double, 1.0)
        }
        assertNoThrow(try JSON.parse(string: "1.0e+0")) { json in
            XCTAssertEqual(json.int, 1)
            XCTAssertEqual(json.double, 1.0)
        }
        assertNoThrow(try JSON.parse(string: "1.0e-0")) { json in
            XCTAssertEqual(json.int, 1)
            XCTAssertEqual(json.double, 1.0)
        }
        assertNoThrow(try JSON.parse(string: "1.1E-00")) { json in
            XCTAssertNil(json.int)
            XCTAssertEqual(json.double, 1.1)
        }
        assertNoThrow(try JSON.parse(string: "1.1E-01")) { json in
            XCTAssertNil(json.int)
            XCTAssertEqual(json.double, 0.11)
        }
        assertNoThrow(try JSON.parse(string: "1.1E+01")) { json in
            XCTAssertEqual(json.int, 11)
            XCTAssertEqual(json.double, 11.0)
        }
    }

    func testUTF8() {
        assertThrows(try JSON.parse(bytes: [0x22, 0xC2]), "Unclosed string")
        assertNoThrow(try JSON.parse(bytes: [0x22, 0xC2, 0xA9, 0x22])) { json in
            XCTAssertEqual(json.string, "©")
        }
        assertThrows(try JSON.parse(bytes: [0x22, 0xC0, 0x00, 0x22]), "Invalid character at (1,2)")

        assertThrows(try JSON.parse(bytes: [0x22, 0xE2, 0x98]), "Unclosed string")
        assertNoThrow(try JSON.parse(bytes: [0x22, 0xE2, 0x98, 0x83, 0x22])) { json in
            XCTAssertEqual(json.string, "☃")
        }
         assertThrows(try JSON.parse(bytes: [0x22, 0xED, 0xA0, 0x81, 0x22]), "Invalid character at (1,2)")

        assertThrows(try JSON.parse(bytes: [0x22, 0xF0, 0x9D, 0x8C]), "Unclosed string")
        assertNoThrow(try JSON.parse(bytes: [0x22, 0xF0, 0x9D, 0x8C, 0x86, 0x22])) { json in
            XCTAssertEqual(json.string, "𝌆")
        }
         assertThrows(try JSON.parse(bytes: [0x22, 247, 191, 191, 191, 0x22]), "Invalid character at (1,2)")
    }
}
