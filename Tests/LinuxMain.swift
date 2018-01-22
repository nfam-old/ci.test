//
//  LinuxMain.swift
//
//  LinuxMain.swift
//  JSON
//
//  Created by Ninh on 10/02/2016.
//  Copyright © 2016 Ninh. All rights reserved.
//

@testable import JSONTests
import XCTest

XCTMain([
    testCase(JSONTests.allTests),
    testCase(JSONArrayOfTests.allTests),
    testCase(JSONDictionaryOfTests.allTests),
    testCase(JSONExpressibleTests.allTests),
    testCase(JSONStringifyTests.allTests),
    testCase(JSONParseTests.allTests)
])
