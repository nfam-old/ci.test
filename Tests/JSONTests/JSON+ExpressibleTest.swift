//
//  JSON+ExpressibleTests.swift
//  JSON
//
//  Created by Ninh on 10/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

@testable import JSON
import XCTest

class JSONExpressibleTests: XCTestCase {
    static var allTests = [
        ("testExpressible", testExpressible)
    ]

    func testExpressible() {
        XCTAssertEqual(json["null"].type, .null)
        XCTAssertEqual(json["int"].type, .int)
        XCTAssertNil(json["null"].bool)
        XCTAssertNil(json["null"].int)
        XCTAssertNil(json["null"].double)
        XCTAssertNil(json["null"].string)
        XCTAssertNil(json["null"].array)
        XCTAssertNil(json["null"].dictionary)
        XCTAssertEqual(json["string1"].string, "Foo Bar")
        XCTAssertEqual(json["string2"].string, "\" \t \n \r \\ \u{2665}")
        XCTAssertEqual(json["bool"].bool, true)
        XCTAssertEqual(json["int"].int, 1)
        XCTAssertEqual(json["int"].double, 1)
        XCTAssertEqual(json["double"].double, -1.1)
        XCTAssertEqual(json["array"][1].int, 2)
        XCTAssertEqual(json["object"]["d"].bool, false)
        XCTAssertEqual(json["object"]["e"][2].type, .null)
        XCTAssertEqual(json["object"]["f"][3].bool, true)
        XCTAssertEqual(json["object"]["f"][5]["a"].string, "b")
    }
}

let json: JSON = [
    "null": nil,
    "int": 1,
    "double": -1.1,
    "string1": "Foo Bar",
    "string2": "\" \t \n \r \\ \u{2665}",
    "bool": true,
    "array": [
        "1",
        2,
        nil,
        true,
        [
            "1",
            2,
            nil,
            false
        ],
        [
            "a": "b"
        ]
    ],
    "object": [
        "a": "1",
        "b": 2,
        "c": nil,
        "d": false,
        "e": ["1", 2, nil, false],
        "f": ["1", 2, nil, true, ["1", 2, nil, false], ["a": "b"]],
        "g": ["a": "b"]
    ],
    "number": 1969
]
