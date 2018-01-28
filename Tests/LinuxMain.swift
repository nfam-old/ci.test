import XCTest
@testable import SimexTests

XCTMain([
    testCase(SyntaxTests.allTests),
    testCase(ExtractionTests.allTests),
    testCase(SyntaxTests.allTests)
])
