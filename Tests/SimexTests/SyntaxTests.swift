// swiftlint:disable file_length
import XCTest
import Foundation
@testable import Simex

class SyntaxTests: XCTestCase {
    static let allTests = [
        ("testExpression", testExpression),
        ("testSlice", testSlice),
        ("testSliceHas", testSliceHas),
        ("testSliceProcess", testSliceProcess),
        ("testSliceNested", testSliceNested),
        ("testSliceBetween", testSliceBetween),
        ("testSliceBetweenBackward", testSliceBetweenBackward),
        ("testSliceBetweenPrefix", testSliceBetweenPrefix),
        ("testSliceBetweenSuffix", testSliceBetweenSuffix),
        ("testSliceBetweenTrim", testSliceBetweenTrim),
        ("testArray", testArray),
        ("testArraySepartor", testArraySepartor),
        ("testArraySkip", testArraySkip),
        ("testArrayNested", testArrayNested),
        ("testDictionary", testDictionary),
        ("testDictionaryMember", testDictionaryMember),
        ("testDictionaryMemberRequired", testDictionaryMemberRequired)
    ]

    func testExpression() throws {
        // should load with {}
        try test("{}")

        // should fail with ["array"], and throw $expression
        try test("[\"array\"]", error: .expression, at: "")
    }

    func testSlice() throws {
        // should fail with {"slice":null}, and throw $slice
        try test("{\"slice\":null}", error: .slice, at: "slice")

        // should fail with {"slice":false}, and throw $slice
        try test("{\"slice\":false}", error: .slice, at: "slice")

        // should fail with {"slice":true}, and throw $slice
        try test("{\"slice\":true}", error: .slice, at: "slice")

        // should fail with {"slice":0}, and throw $slice
        try test("{\"slice\":0}", error: .slice, at: "slice")

        // should fail with {"slice":"string"}, and throw $slice
        try test("{\"slice\":\"string\"}", error: .slice, at: "slice")

        // should load with {"slice":{}}
        try test("{\"slice\":{}}")

        // should fail with {"slice":["array"]}, and throw $slice
        try test("{\"slice\":[\"array\"]}", error: .slice, at: "slice")
    }

    func testSliceHas() throws {
        // should fail with {"slice":{"has":null}}, and throw $has
        try test("{\"slice\":{\"has\":null}}", error: .has, at: "slice.has")

        // should fail with {"slice":{"has":false}}, and throw $has
        try test("{\"slice\":{\"has\":false}}", error: .has, at: "slice.has")

        // should fail with {"slice":{"has":true}}, and throw $has
        try test("{\"slice\":{\"has\":true}}", error: .has, at: "slice.has")

        // should fail with {"slice":{"has":0}}, and throw $has
        try test("{\"slice\":{\"has\":0}}", error: .has, at: "slice.has")

        // should load with {"slice":{"has":"string"}}
        try test("{\"slice\":{\"has\":\"string\"}}")

        // should fail with {"slice":{"has":{}}}, and throw $has
        try test("{\"slice\":{\"has\":{}}}", error: .has, at: "slice.has")

        // should fail with {"slice":{"has":["array"]}}, and throw $has
        try test("{\"slice\":{\"has\":[\"array\"]}}", error: .has, at: "slice.has")
    }

    func testSliceProcess() throws {
        // should fail with {"slice":{"process":null}}, and throw $process
        try test("{\"slice\":{\"process\":null}}", error: .process, at: "slice.process")

        // should fail with {"slice":{"process":false}}, and throw $process
        try test("{\"slice\":{\"process\":false}}", error: .process, at: "slice.process")

        // should fail with {"slice":{"process":true}}, and throw $process
        try test("{\"slice\":{\"process\":true}}", error: .process, at: "slice.process")

        // should fail with {"slice":{"process":0}}, and throw $process
        try test("{\"slice\":{\"process\":0}}", error: .process, at: "slice.process")

        // should fail with {"slice":{"process":"nofunction"}}, and throw $processUndefined
        try test("{\"slice\":{\"process\":\"nofunction\"}}", error: .processUndefined, at: "slice.process")

        // should fail with {"slice":{"process":":int"}}, and throw $processUndefined
        try test("{\"slice\":{\"process\":\":int\"}}", error: .processUndefined, at: "slice.process")

        // should load with {"slice":{"process":"int"}}
        try test("{\"slice\":{\"process\":\"int\"}}")

        // should load with {"slice":{"process":"int:"}}
        try test("{\"slice\":{\"process\":\"int:\"}}")

        // should load with {"slice":{"process":"int:10"}}
        try test("{\"slice\":{\"process\":\"int:10\"}}")

        // should load with {"slice":{"process":"int"}}
        try test("{\"slice\":{\"process\":\"int\"}}")

        // should fail with {"slice":{"process":{}}}, and throw $process
        try test("{\"slice\":{\"process\":{}}}", error: .process, at: "slice.process")

        // should fail with {"slice":{"process":["array"]}}, and throw $process
        try test("{\"slice\":{\"process\":[\"array\"]}}", error: .process, at: "slice.process")
    }

    func testSliceNested() throws {
        // should load with {"slice":{"slice":{}}}
        try test("{\"slice\":{\"slice\":{}}}")

        // should load with {"slice":{"array":{"separator":"|"}}}
        try test("{\"slice\":{\"array\":{\"separator\":\"|\"}}}")

        // should load with {"slice":{"dictionary":{}}}
        try test("{\"slice\":{\"dictionary\":{}}}")

        // should fail with {"slice":{"slice":0,"array":0}}, and throw $subexpressions
        try test("{\"slice\":{\"slice\":0,\"array\":0}}", error: .subexpressions, at: "slice")

        // should fail with {"slice":{"slice":0,"dictionary":0}}, and throw $subexpressions
        try test("{\"slice\":{\"slice\":0,\"dictionary\":0}}", error: .subexpressions, at: "slice")

        // should fail with {"slice":{"slice":0,"array":0,"dictionary":0}}, and throw $subexpressions
        try test("{\"slice\":{\"slice\":0,\"array\":0,\"dictionary\":0}}", error: .subexpressions, at: "slice")

        // should fail with {"slice":{"array":0,"dictionary":0}}, and throw $subexpressions
        try test("{\"slice\":{\"array\":0,\"dictionary\":0}}", error: .subexpressions, at: "slice")
    }

    func testSliceBetween() throws {
        // should fail with {"slice":{"between":null}}, and throw $between
        try test("{\"slice\":{\"between\":null}}", error: .between, at: "slice.between")

        // should fail with {"slice":{"between":false}}, and throw $between
        try test("{\"slice\":{\"between\":false}}", error: .between, at: "slice.between")

        // should fail with {"slice":{"between":true}}, and throw $between
        try test("{\"slice\":{\"between\":true}}", error: .between, at: "slice.between")

        // should fail with {"slice":{"between":0}}, and throw $between
        try test("{\"slice\":{\"between\":0}}", error: .between, at: "slice.between")

        // should fail with {"slice":{"between":"string"}}, and throw $between
        try test("{\"slice\":{\"between\":\"string\"}}", error: .between, at: "slice.between")

        // should load with {"slice":{"between":{}}}
        try test("{\"slice\":{\"between\":{}}}")

        // should fail with {"slice":{"between":["array"]}}, and throw $between
        try test("{\"slice\":{\"between\":[\"array\"]}}", error: .between, at: "slice.between")
    }

    func testSliceBetweenBackward() throws {
        // should fail with {"slice":{"between":{"backward":null}}}, and throw $backward
        try test("{\"slice\":{\"between\":{\"backward\":null}}}", error: .backward, at: "slice.between.backward")

        // should load with {"slice":{"between":{"backward":false}}}
        try test("{\"slice\":{\"between\":{\"backward\":false}}}")

        // should load with {"slice":{"between":{"backward":true}}}
        try test("{\"slice\":{\"between\":{\"backward\":true}}}")

        // should fail with {"slice":{"between":{"backward":0}}}, and throw $backward
        try test("{\"slice\":{\"between\":{\"backward\":0}}}", error: .backward, at: "slice.between.backward")

        // should fail with {"slice":{"between":{"backward":"string"}}}, and throw $backward
        try test("{\"slice\":{\"between\":{\"backward\":\"string\"}}}", error: .backward, at: "slice.between.backward")

        // should fail with {"slice":{"between":{"backward":{}}}}, and throw $backward
        try test("{\"slice\":{\"between\":{\"backward\":{}}}}", error: .backward, at: "slice.between.backward")

        // should fail with {"slice":{"between":{"backward":["array"]}}}, and throw $backward
        try test("{\"slice\":{\"between\":{\"backward\":[\"array\"]}}}", error: .backward, at: "slice.between.backward")
    }

    func testSliceBetweenPrefix() throws {
        // should fail with {"slice":{"between":{"prefix":null}}}, and throw $prefix
        try test("{\"slice\":{\"between\":{\"prefix\":null}}}", error: .prefix, at: "slice.between.prefix")

        // should fail with {"slice":{"between":{"prefix":false}}}, and throw $prefix
        try test("{\"slice\":{\"between\":{\"prefix\":false}}}", error: .prefix, at: "slice.between.prefix")

        // should fail with {"slice":{"between":{"prefix":true}}}, and throw $prefix
        try test("{\"slice\":{\"between\":{\"prefix\":true}}}", error: .prefix, at: "slice.between.prefix")

        // should fail with {"slice":{"between":{"prefix":0}}}, and throw $prefix
        try test("{\"slice\":{\"between\":{\"prefix\":0}}}", error: .prefix, at: "slice.between.prefix")

        // should load with {"slice":{"between":{"prefix":"string"}}}
        try test("{\"slice\":{\"between\":{\"prefix\":\"string\"}}}")

        // should fail with {"slice":{"between":{"prefix":{}}}}, and throw $prefix
        try test("{\"slice\":{\"between\":{\"prefix\":{}}}}", error: .prefix, at: "slice.between.prefix")

        // should load with {"slice":{"between":{"prefix":["string"]}}}
        try test("{\"slice\":{\"between\":{\"prefix\":[\"string\"]}}}")

        // should fail with {"slice":{"between":{"prefix":[0]}}}, and throw $prefix
        try test("{\"slice\":{\"between\":{\"prefix\":[0]}}}", error: .prefix, at: "slice.between.prefix")
    }

    func testSliceBetweenSuffix() throws {
        // should fail with {"slice":{"between":{"suffix":null}}}, and throw $suffix
        try test("{\"slice\":{\"between\":{\"suffix\":null}}}", error: .suffix, at: "slice.between.suffix")

        // should fail with {"slice":{"between":{"suffix":false}}}, and throw $suffix
        try test("{\"slice\":{\"between\":{\"suffix\":false}}}", error: .suffix, at: "slice.between.suffix")

        // should fail with {"slice":{"between":{"suffix":true}}}, and throw $suffix
        try test("{\"slice\":{\"between\":{\"suffix\":true}}}", error: .suffix, at: "slice.between.suffix")

        // should fail with {"slice":{"between":{"suffix":0}}}, and throw $suffix
        try test("{\"slice\":{\"between\":{\"suffix\":0}}}", error: .suffix, at: "slice.between.suffix")

        // should load with {"slice":{"between":{"suffix":"string"}}}
        try test("{\"slice\":{\"between\":{\"suffix\":\"string\"}}}")

        // should fail with {"slice":{"between":{"suffix":{}}}}, and throw $suffix
        try test("{\"slice\":{\"between\":{\"suffix\":{}}}}", error: .suffix, at: "slice.between.suffix")

        // should load with {"slice":{"between":{"suffix":["string"]}}}
        try test("{\"slice\":{\"between\":{\"suffix\":[\"string\"]}}}")

        // should fail with {"slice":{"between":{"suffix":[0]}}}, and throw $suffix
        try test("{\"slice\":{\"between\":{\"suffix\":[0]}}}", error: .suffix, at: "slice.between.suffix")
    }

    func testSliceBetweenTrim() throws {
        // should fail with {"slice":{"between":{"trim":null}}}, and throw $trim
        try test("{\"slice\":{\"between\":{\"trim\":null}}}", error: .trim, at: "slice.between.trim")

        // should load with {"slice":{"between":{"trim":false}}}
        try test("{\"slice\":{\"between\":{\"trim\":false}}}")

        // should load with {"slice":{"between":{"trim":true}}}
        try test("{\"slice\":{\"between\":{\"trim\":true}}}")

        // should fail with {"slice":{"between":{"trim":0}}}, and throw $trim
        try test("{\"slice\":{\"between\":{\"trim\":0}}}", error: .trim, at: "slice.between.trim")

        // should fail with {"slice":{"between":{"trim":"string"}}}, and throw $trim
        try test("{\"slice\":{\"between\":{\"trim\":\"string\"}}}", error: .trim, at: "slice.between.trim")

        // should fail with {"slice":{"between":{"trim":{}}}}, and throw $trim
        try test("{\"slice\":{\"between\":{\"trim\":{}}}}", error: .trim, at: "slice.between.trim")

        // should fail with {"slice":{"between":{"trim":["array"]}}}, and throw $trim
        try test("{\"slice\":{\"between\":{\"trim\":[\"array\"]}}}", error: .trim, at: "slice.between.trim")
    }

    func testArray() throws {
        // should fail with {"array":null}, and throw $array
        try test("{\"array\":null}", error: .array, at: "array")

        // should fail with {"array":false}, and throw $array
        try test("{\"array\":false}", error: .array, at: "array")

        // should fail with {"array":true}, and throw $array
        try test("{\"array\":true}", error: .array, at: "array")

        // should fail with {"array":0}, and throw $array
        try test("{\"array\":0}", error: .array, at: "array")

        // should fail with {"array":"string"}, and throw $array
        try test("{\"array\":\"string\"}", error: .array, at: "array")

        // should fail with {"array":{}}, and throw $separatorMissing
        try test("{\"array\":{}}", error: .separatorMissing, at: "array")

        // should load with {"array":{"separator":"|"}}
        try test("{\"array\":{\"separator\":\"|\"}}")

        // should fail with {"array":["array"]}, and throw $array
        try test("{\"array\":[\"array\"]}", error: .array, at: "array")
    }

    func testArraySepartor() throws {
        // should fail with {"array":{"separator":null}}, and throw $separator
        try test("{\"array\":{\"separator\":null}}", error: .separator, at: "array.separator")

        // should fail with {"array":{"separator":false}}, and throw $separator
        try test("{\"array\":{\"separator\":false}}", error: .separator, at: "array.separator")

        // should fail with {"array":{"separator":true}}, and throw $separator
        try test("{\"array\":{\"separator\":true}}", error: .separator, at: "array.separator")

        // should fail with {"array":{"separator":0}}, and throw $separator
        try test("{\"array\":{\"separator\":0}}", error: .separator, at: "array.separator")

        // should load with {"array":{"separator":"string"}}
        try test("{\"array\":{\"separator\":\"string\"}}")

        // should fail with {"array":{"separator":""}}, and throw $separator
        try test("{\"array\":{\"separator\":\"\"}}", error: .separator, at: "array.separator")

        // should fail with {"array":{"separator":{}}}, and throw $separator
        try test("{\"array\":{\"separator\":{}}}", error: .separator, at: "array.separator")

        // should load with {"array":{"separator":["array"]}}
        try test("{\"array\":{\"separator\":[\"array\"]}}")

        // should fail with {"array":{"separator":["array",""]}}, and throw $separator
        try test("{\"array\":{\"separator\":[\"array\",\"\"]}}", error: .separator, at: "array.separator")

        // should fail with {"array":{"separator":["array",0]}}, and throw $separator
        try test("{\"array\":{\"separator\":[\"array\",0]}}", error: .separator, at: "array.separator")
    }

    func testArraySkip() throws {
        // should fail with {"array":{"separator":"|","skip":null}}, and throw $skip
        try test("{\"array\":{\"separator\":\"|\",\"skip\":null}}", error: .skip, at: "array.skip")

        // should fail with {"array":{"separator":"|","skip":false}}, and throw $skip
        try test("{\"array\":{\"separator\":\"|\",\"skip\":false}}", error: .skip, at: "array.skip")

        // should fail with {"array":{"separator":"|","skip":true}}, and throw $skip
        try test("{\"array\":{\"separator\":\"|\",\"skip\":true}}", error: .skip, at: "array.skip")

        // should fail with {"array":{"separator":"|","skip":0}}, and throw $skip
        try test("{\"array\":{\"separator\":\"|\",\"skip\":0}}", error: .skip, at: "array.skip")

        // should fail with {"array":{"separator":"|","skip":"string"}}, and throw $skip
        try test("{\"array\":{\"separator\":\"|\",\"skip\":\"string\"}}", error: .skip, at: "array.skip")

        // should load with {"array":{"separator":"|","skip":"empty"}}
        try test("{\"array\":{\"separator\":\"|\",\"skip\":\"empty\"}}")

        // should load with {"array":{"separator":"|","skip":"invalid"}}
        try test("{\"array\":{\"separator\":\"|\",\"skip\":\"invalid\"}}")

        // should fail with {"array":{"separator":"|","skip":{}}}, and throw $skip
        try test("{\"array\":{\"separator\":\"|\",\"skip\":{}}}", error: .skip, at: "array.skip")

        // should fail with {"array":{"separator":"|","skip":["array"]}}, and throw $skip
        try test("{\"array\":{\"separator\":\"|\",\"skip\":[\"array\"]}}", error: .skip, at: "array.skip")

        // should load with {"array":{"separator":"|","skip":["empty"]}}
        try test("{\"array\":{\"separator\":\"|\",\"skip\":[\"empty\"]}}")

        // should load with {"array":{"separator":"|","skip":["invalid"]}}
        try test("{\"array\":{\"separator\":\"|\",\"skip\":[\"invalid\"]}}")

        // should load with {"array":{"separator":"|","skip":["empty","invalid"]}}
        try test("{\"array\":{\"separator\":\"|\",\"skip\":[\"empty\",\"invalid\"]}}")
    }

    func testArrayNested() throws {
        // should load with {"array":{"separator":"|","array":{"separator":"|","slice":{}}}}
        try test("{\"array\":{\"separator\":\"|\",\"array\":{\"separator\":\"|\",\"slice\":{}}}}")

        // should load with {"array":{"separator":"|","array":{"separator":"|","array":{"separator":"#"}}}}
        try test("{\"array\":{\"separator\":\"|\",\"array\":{\"separator\":\"|\",\"array\":{\"separator\":\"#\"}}}}")

        // should load with {"array":{"separator":"|","dictionary":{}}}
        try test("{\"array\":{\"separator\":\"|\",\"dictionary\":{}}}")

        // should fail with {"array":{"separator":"|","slice":0,"array":0}}, and throw $subexpressions
        try test("{\"array\":{\"separator\":\"|\",\"slice\":0,\"array\":0}}", error: .subexpressions, at: "array")

        // should fail with {"array":{"separator":"|","slice":0,"dictionary":0}}, and throw $subexpressions
        try test("{\"array\":{\"separator\":\"|\",\"slice\":0,\"dictionary\":0}}", error: .subexpressions, at: "array")

        // should fail with {"array":{"separator":"|","slice":0,"array":0,"dictionary":0}}, and throw $subexpressions
        try test("{\"array\":{\"separator\":\"|\",\"slice\":0,\"array\":0,\"dictionary\":0}}", error: .subexpressions, at: "array")

        // should fail with {"array":{"separator":"|","array":0,"dictionary":0}}, and throw $subexpressions
        try test("{\"array\":{\"separator\":\"|\",\"array\":0,\"dictionary\":0}}", error: .subexpressions, at: "array")
    }

    func testDictionary() throws {
        // should fail with {"dictionary":null}, and throw $dictionary
        try test("{\"dictionary\":null}", error: .dictionary, at: "dictionary")

        // should fail with {"dictionary":false}, and throw $dictionary
        try test("{\"dictionary\":false}", error: .dictionary, at: "dictionary")

        // should fail with {"dictionary":true}, and throw $dictionary
        try test("{\"dictionary\":true}", error: .dictionary, at: "dictionary")

        // should fail with {"dictionary":0}, and throw $dictionary
        try test("{\"dictionary\":0}", error: .dictionary, at: "dictionary")

        // should fail with {"dictionary":"string"}, and throw $dictionary
        try test("{\"dictionary\":\"string\"}", error: .dictionary, at: "dictionary")

        // should load with {"dictionary":{}}
        try test("{\"dictionary\":{}}")

        // should fail with {"dictionary":["array"]}, and throw $dictionary
        try test("{\"dictionary\":[\"array\"]}", error: .dictionary, at: "dictionary")
    }

    func testDictionaryMember() throws {
        // should fail with {"dictionary":{"name":null}}, and throw $member
        try test("{\"dictionary\":{\"name\":null}}", error: .member, at: "dictionary.name")

        // should fail with {"dictionary":{"name":false}}, and throw $member
        try test("{\"dictionary\":{\"name\":false}}", error: .member, at: "dictionary.name")

        // should fail with {"dictionary":{"name":true}}, and throw $member
        try test("{\"dictionary\":{\"name\":true}}", error: .member, at: "dictionary.name")

        // should fail with {"dictionary":{"name":0}}, and throw $member
        try test("{\"dictionary\":{\"name\":0}}", error: .member, at: "dictionary.name")

        // should fail with {"dictionary":{"name":"string"}}, and throw $member
        try test("{\"dictionary\":{\"name\":\"string\"}}", error: .member, at: "dictionary.name")

        // should load with {"dictionary":{"name":{}}}
        try test("{\"dictionary\":{\"name\":{}}}")

        // should fail with {"dictionary":{"name":["array"]}}, and throw $member
        try test("{\"dictionary\":{\"name\":[\"array\"]}}", error: .member, at: "dictionary.name")
    }

    func testDictionaryMemberRequired() throws {
        // should fail with {"dictionary":{"name":{"required":null}}}, and throw $required
        try test("{\"dictionary\":{\"name\":{\"required\":null}}}", error: .required, at: "dictionary.name.required")

        // should load with {"dictionary":{"name":{"required":false}}}
        try test("{\"dictionary\":{\"name\":{\"required\":false}}}")

        // should load with {"dictionary":{"name":{"required":true}}}
        try test("{\"dictionary\":{\"name\":{\"required\":true}}}")

        // should fail with {"dictionary":{"name":{"required":0}}}, and throw $required
        try test("{\"dictionary\":{\"name\":{\"required\":0}}}", error: .required, at: "dictionary.name.required")

        // should load with {"dictionary":{"name":{"required":"string"}}}
        try test("{\"dictionary\":{\"name\":{\"required\":\"string\"}}}")

        // should fail with {"dictionary":{"name":{"required":""}}}, and throw $required
        try test("{\"dictionary\":{\"name\":{\"required\":\"\"}}}", error: .required, at: "dictionary.name.required")

        // should fail with {"dictionary":{"name":{"required":{}}}}, and throw $required
        try test("{\"dictionary\":{\"name\":{\"required\":{}}}}", error: .required, at: "dictionary.name.required")

        // should fail with {"dictionary":{"name":{"required":["array"]}}}, and throw $required
        try test("{\"dictionary\":{\"name\":{\"required\":[\"array\"]}}}", error: .required, at: "dictionary.name.required")
    }
}
