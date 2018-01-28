// swiftlint:disable superfluous_disable_command line_length file_length
import XCTest
import Foundation
@testable import Simex

class ExtractionTests: XCTestCase {
    static let allTests = [
        ("testHas", testHas),
        ("testBetween", testBetween),
        ("testBetweenPrefix", testBetweenPrefix),
        ("testBetweenSuffix", testBetweenSuffix),
        ("testBetweenTrim", testBetweenTrim),
        ("testBetweenBackward", testBetweenBackward),
        ("testProcess", testProcess),
        ("testArray", testArray),
        ("testDictionary", testDictionary),
        ("testNested", testNested)
    ]

    func testHas() throws {
        // should extract with {"slice":{"has":"#"}} from "#0" to "#0"
        try test("{\"slice\":{\"has\":\"#\"}}", input: "#0", output: "\"#0\"")

        // should fail with {"slice":{"has":"#"}} from "0", throw $unmatch
        try test("{\"slice\":{\"has\":\"#\"}}", input: "0", error: .unmatch, at: "slice.has")

        // should extract with {"slice":{"has":"\u0000"}} from "0\u{0}1" to "0\u00001"
        try test("{\"slice\":{\"has\":\"\\u0000\"}}", input: "0\u{0}1", output: "\"0\u{0}1\"")
    }

    func testBetween() throws {
        // should extract with {"between":{"backward":true,"prefix":["0","2"],"suffix":"0","trim":true}} from " 0 X 2 0 1 " to "X"
        try test("{\"between\":{\"backward\":true,\"prefix\":[\"0\",\"2\"],\"suffix\":\"0\",\"trim\":true}}", input: " 0 X 2 0 1 ", output: "\"X\"")
    }

    func testBetweenPrefix() throws {
        // should extract with {"between":{"prefix":""}} from " 0 1 2 0 1 " to " 0 1 2 0 1 "
        try test("{\"between\":{\"prefix\":\"\"}}", input: " 0 1 2 0 1 ", output: "\" 0 1 2 0 1 \"")

        // should extract with {"between":{"prefix":"0"}} from " 0 1 2 0 1 " to " 1 2 0 1 "
        try test("{\"between\":{\"prefix\":\"0\"}}", input: " 0 1 2 0 1 ", output: "\" 1 2 0 1 \"")

        // should extract with {"between":{"prefix":["0","0"]}} from " 0 1 2 0 1 " to " 1 "
        try test("{\"between\":{\"prefix\":[\"0\",\"0\"]}}", input: " 0 1 2 0 1 ", output: "\" 1 \"")

        // should fail with {"between":{"prefix":"#"}} from " 0 1 2 3 ", throw $unmatch
        try test("{\"between\":{\"prefix\":\"#\"}}", input: " 0 1 2 3 ", error: .unmatch, at: "between.prefix")

        // should fail with {"between":{"prefix":["0","#"]}} from " 0 1 2 3 ", throw $unmatch
        try test("{\"between\":{\"prefix\":[\"0\",\"#\"]}}", input: " 0 1 2 3 ", error: .unmatch, at: "between.prefix.#(1)")
    }

    func testBetweenSuffix() throws {
        // should extract with {"between":{"suffix":""}} from " 0 1 2 0 1 " to " 0 1 2 0 1 "
        try test("{\"between\":{\"suffix\":\"\"}}", input: " 0 1 2 0 1 ", output: "\" 0 1 2 0 1 \"")

        // should extract with {"between":{"suffix":"1"}} from " 0 1 2 0 1 " to " 0 "
        try test("{\"between\":{\"suffix\":\"1\"}}", input: " 0 1 2 0 1 ", output: "\" 0 \"")

        // should extract with {"between":{"suffix":["3","1"]}} from " 0 1 2 0 1 " to " 0 "
        try test("{\"between\":{\"suffix\":[\"3\",\"1\"]}}", input: " 0 1 2 0 1 ", output: "\" 0 \"")

        // should fail with {"between":{"suffix":"#"}} from " 0 1 2 3 ", throw $unmatch
        try test("{\"between\":{\"suffix\":\"#\"}}", input: " 0 1 2 3 ", error: .unmatch, at: "between.suffix")

        // should fail with {"between":{"suffix":["@","#"]}} from " 0 1 2 3 ", throw $unmatch
        try test("{\"between\":{\"suffix\":[\"@\",\"#\"]}}", input: " 0 1 2 3 ", error: .unmatch, at: "between.suffix")
    }

    func testBetweenTrim() throws {
        // should extract with {"between":{"trim":true}} from " 0 1 2 0 1 " to "0 1 2 0 1"
        try test("{\"between\":{\"trim\":true}}", input: " 0 1 2 0 1 ", output: "\"0 1 2 0 1\"")
    }

    func testBetweenBackward() throws {
        // should extract with {"between":{"backward":true,"prefix":"","trim":true}} from " 0 1 2 3 " to "0 1 2 3"
        try test("{\"between\":{\"backward\":true,\"prefix\":\"\",\"trim\":true}}", input: " 0 1 2 3 ", output: "\"0 1 2 3\"")

        // should extract with {"between":{"backward":true,"prefix":"1"}} from " 0 1 2 3 " to " 0 "
        try test("{\"between\":{\"backward\":true,\"prefix\":\"1\"}}", input: " 0 1 2 3 ", output: "\" 0 \"")

        // should extract with {"between":{"backward":true,"prefix":"1","trim":true}} from " 0 1 2 3 " to "0"
        try test("{\"between\":{\"backward\":true,\"prefix\":\"1\",\"trim\":true}}", input: " 0 1 2 3 ", output: "\"0\"")

        // should extract with {"between":{"backward":true,"prefix":"3","trim":true}} from " 0 1 2 3 " to "0 1 2"
        try test("{\"between\":{\"backward\":true,\"prefix\":\"3\",\"trim\":true}}", input: " 0 1 2 3 ", output: "\"0 1 2\"")

        // should extract with {"between":{"backward":true,"prefix":["3","2"],"trim":true}} from " 0 1 2 3 " to "0 1"
        try test("{\"between\":{\"backward\":true,\"prefix\":[\"3\",\"2\"],\"trim\":true}}", input: " 0 1 2 3 ", output: "\"0 1\"")

        // should extract with {"between":{"backward":true,"prefix":["0",""],"trim":true}} from "0 1 2 3 " to ""
        try test("{\"between\":{\"backward\":true,\"prefix\":[\"0\",\"\"],\"trim\":true}}", input: "0 1 2 3 ", output: "\"\"")

        // should extract with {"between":{"backward":true,"suffix":"","trim":true}} from " 0 1 2 3 " to "0 1 2 3"
        try test("{\"between\":{\"backward\":true,\"suffix\":\"\",\"trim\":true}}", input: " 0 1 2 3 ", output: "\"0 1 2 3\"")

        // should extract with {"between":{"backward":true,"suffix":"1","trim":true}} from " 0 1 2 3 " to "2 3"
        try test("{\"between\":{\"backward\":true,\"suffix\":\"1\",\"trim\":true}}", input: " 0 1 2 3 ", output: "\"2 3\"")

        // should extract with {"between":{"backward":true,"suffix":"0","trim":true}} from " 0 1 2 3 " to "1 2 3"
        try test("{\"between\":{\"backward\":true,\"suffix\":\"0\",\"trim\":true}}", input: " 0 1 2 3 ", output: "\"1 2 3\"")

        // should extract with {"between":{"backward":true,"prefix":["3","2"],"suffix":"0","trim":true}} from " 0 1 2 3 " to "1"
        try test("{\"between\":{\"backward\":true,\"prefix\":[\"3\",\"2\"],\"suffix\":\"0\",\"trim\":true}}", input: " 0 1 2 3 ", output: "\"1\"")

        // should fail with {"between":{"backward":true,"prefix":"#"}} from " 0 1 2 3 ", throw $unmatch
        try test("{\"between\":{\"backward\":true,\"prefix\":\"#\"}}", input: " 0 1 2 3 ", error: .unmatch, at: "between.prefix")

        // should fail with {"between":{"backward":true,"prefix":["0","#"]}} from " 0 1 2 4 ", throw $unmatch
        try test("{\"between\":{\"backward\":true,\"prefix\":[\"0\",\"#\"]}}", input: " 0 1 2 4 ", error: .unmatch, at: "between.prefix.#(1)")

        // should fail with {"between":{"backward":true,"prefix":["0","#"]}} from "0 1 2 4 ", throw $unmatch
        try test("{\"between\":{\"backward\":true,\"prefix\":[\"0\",\"#\"]}}", input: "0 1 2 4 ", error: .unmatch, at: "between.prefix.#(1)")

        // should fail with {"between":{"backward":true,"suffix":"4 "}} from " 0 1 2 3 ", throw $unmatch
        try test("{\"between\":{\"backward\":true,\"suffix\":\"4 \"}}", input: " 0 1 2 3 ", error: .unmatch, at: "between.suffix")
    }

    func testProcess() throws {
        // should extract with {"process":"int"} from "1.1" to "1"
        try test("{\"process\":\"int\"}", input: "1.1", output: "\"1\"")

        // should fail with {"process":"int"} from "th", throw $unmatch
        try test("{\"process\":\"int\"}", input: "th", error: .unmatch, at: "process")

        // should extract with {"process":"float"} from "1.1" to "1.1"
        try test("{\"process\":\"float\"}", input: "1.1", output: "\"1.1\"")

        // should fail with {"process":"float"} from "th", throw $unmatch
        try test("{\"process\":\"float\"}", input: "th", error: .unmatch, at: "process")

        // should fail with {"slice":{"process":"float"}} from "th", throw $unmatch
        try test("{\"slice\":{\"process\":\"float\"}}", input: "th", error: .unmatch, at: "slice.process")
    }

    func testArray() throws {
        // should extract with {"array":{"separator":" "}} from " 0 " to ["","0",""]
        try test("{\"array\":{\"separator\":\" \"}}", input: " 0 ", output: "[\"\",\"0\",\"\"]")

        // should extract with {"array":{"separator":" ","skip":"empty"}} from " 0 " to ["0"]
        try test("{\"array\":{\"separator\":\" \",\"skip\":\"empty\"}}", input: " 0 ", output: "[\"0\"]")

        // should extract with {"array":{"separator":" "}} from " 0 1 2 3 " to ["","0","1","2","3",""]
        try test("{\"array\":{\"separator\":\" \"}}", input: " 0 1 2 3 ", output: "[\"\",\"0\",\"1\",\"2\",\"3\",\"\"]")

        // should extract with {"array":{"separator":" ","skip":"empty"}} from " 0 1 2 3 " to ["0","1","2","3"]
        try test("{\"array\":{\"separator\":\" \",\"skip\":\"empty\"}}", input: " 0 1 2 3 ", output: "[\"0\",\"1\",\"2\",\"3\"]")

        // should extract with {"array":{"separator":" "}} from " 0  1  2  3 " to ["","0","","1","","2","","3",""]
        try test("{\"array\":{\"separator\":\" \"}}", input: " 0  1  2  3 ", output: "[\"\",\"0\",\"\",\"1\",\"\",\"2\",\"\",\"3\",\"\"]")

        // should extract with {"array":{"separator":" ","skip":"empty"}} from " 0  1  2  3 " to ["0","1","2","3"]
        try test("{\"array\":{\"separator\":\" \",\"skip\":\"empty\"}}", input: " 0  1  2  3 ", output: "[\"0\",\"1\",\"2\",\"3\"]")

        // should extract with {"array":{"separator":[" ","|"]}} from " 0|1|2|3 " to ["","0","1","2","3",""]
        try test("{\"array\":{\"separator\":[\" \",\"|\"]}}", input: " 0|1|2|3 ", output: "[\"\",\"0\",\"1\",\"2\",\"3\",\"\"]")

        // should fail with {"array":{"separator":"|","slice":{"has":"#"}}} from "#0|#1|#2|3", throw $unmatch
        try test("{\"array\":{\"separator\":\"|\",\"slice\":{\"has\":\"#\"}}}", input: "#0|#1|#2|3", error: .unmatch, at: "array.slice.has")

        // should extract with {"array":{"separator":[" ","|"],"skip":"invalid","slice":{"has":"#"}}} from " #0|#1|#2|3 " to ["#0","#1","#2"]
        try test("{\"array\":{\"separator\":[\" \",\"|\"],\"skip\":\"invalid\",\"slice\":{\"has\":\"#\"}}}", input: " #0|#1|#2|3 ", output: "[\"#0\",\"#1\",\"#2\"]")

        // should extract with {"array":{"separator":"|","skip":["empty","invalid"],"slice":{"between":{"prefix":"#"}}}} from " #0|#|#2" to ["0","2"]
        try test("{\"array\":{\"separator\":\"|\",\"skip\":[\"empty\",\"invalid\"],\"slice\":{\"between\":{\"prefix\":\"#\"}}}}", input: " #0|#|#2", output: "[\"0\",\"2\"]")
    }

    func testDictionary() throws {
        // should extract with {"dictionary":{"name":{}}} from " 0 " to {"name":" 0 "}
        try test("{\"dictionary\":{\"name\":{}}}", input: " 0 ", output: "{\"name\":\" 0 \"}")

        // should extract with {"dictionary":{"name":{"between":{"trim":true}}}} from " 0 " to {"name":"0"}
        try test("{\"dictionary\":{\"name\":{\"between\":{\"trim\":true}}}}", input: " 0 ", output: "{\"name\":\"0\"}")

        // should extract with {"dictionary":{"n0":{"between":{"prefix":"n0:","suffix":" "}},"n1":{"between":{"prefix":"n1:","suffix":"#","trim":true}}}} from " n0:0 n1: 1# " to {"n0":"0","n1":"1"}
        try test("{\"dictionary\":{\"n0\":{\"between\":{\"prefix\":\"n0:\",\"suffix\":\" \"}},\"n1\":{\"between\":{\"prefix\":\"n1:\",\"suffix\":\"#\",\"trim\":true}}}}", input: " n0:0 n1: 1# ", output: "{\"n0\":\"0\",\"n1\":\"1\"}")

        // should extract with {"dictionary":{"n0":{"between":{"prefix":"n0:","suffix":" "}},"n1":{"required":false,"between":{"prefix":"n1:","suffix":"$"}}}} from " n0:0 n1: 1# " to {"n0":"0"}
        try test("{\"dictionary\":{\"n0\":{\"between\":{\"prefix\":\"n0:\",\"suffix\":\" \"}},\"n1\":{\"required\":false,\"between\":{\"prefix\":\"n1:\",\"suffix\":\"$\"}}}}", input: " n0:0 n1: 1# ", output: "{\"n0\":\"0\"}")

        // should extract with {"dictionary":{"n0":{"required":"g","between":{"prefix":"n0:","suffix":" "}},"n1":{"required":"g","between":{"prefix":"n1:","suffix":"$"}}}} from " n0:0 n1: 1# " to {"n0":"0"}
        try test("{\"dictionary\":{\"n0\":{\"required\":\"g\",\"between\":{\"prefix\":\"n0:\",\"suffix\":\" \"}},\"n1\":{\"required\":\"g\",\"between\":{\"prefix\":\"n1:\",\"suffix\":\"$\"}}}}", input: " n0:0 n1: 1# ", output: "{\"n0\":\"0\"}")

        // should fail with {"dictionary":{"name":{"has":"#"}}} from " 0 ", throw $unmatch
        try test("{\"dictionary\":{\"name\":{\"has\":\"#\"}}}", input: " 0 ", error: .unmatch, at: "dictionary.name.has")

        // should fail with {"dictionary":{"name":{"required":"g","has":"#"}}} from " 0 ", throw $unmatch
        try test("{\"dictionary\":{\"name\":{\"required\":\"g\",\"has\":\"#\"}}}", input: " 0 ", error: .unmatch, at: "dictionary.name(g).has")

        // should fail with {"dictionary":{"name":{"has":"#"}}} from " 0 ", throw $unmatch
        try test("{\"dictionary\":{\"name\":{\"has\":\"#\"}}}", input: " 0 ", error: .unmatch, at: "dictionary.name.has")
    }

    func testNested() throws {
        // should extract with {"array":{"separator":"|","slice":{"between":{"prefix":"#"}}}} from "#0|#1.X|#2" to ["0","1.X","2"]
        try test("{\"array\":{\"separator\":\"|\",\"slice\":{\"between\":{\"prefix\":\"#\"}}}}", input: "#0|#1.X|#2", output: "[\"0\",\"1.X\",\"2\"]")

        // should extract with {"array":{"separator":"|","array":{"separator":"."}}} from "#0|#1.X|#2" to [["#0"],["#1","X"],["#2"]]
        try test("{\"array\":{\"separator\":\"|\",\"array\":{\"separator\":\".\"}}}", input: "#0|#1.X|#2", output: "[[\"#0\"],[\"#1\",\"X\"],[\"#2\"]]")

        // should extract with {"array":{"separator":"|","dictionary":{"name":{"has":"n:"}}}} from "n:0|n:1|n:2" to [{"name":"n:0"},{"name":"n:1"},{"name":"n:2"}]
        try test("{\"array\":{\"separator\":\"|\",\"dictionary\":{\"name\":{\"has\":\"n:\"}}}}", input: "n:0|n:1|n:2", output: "[{\"name\":\"n:0\"},{\"name\":\"n:1\"},{\"name\":\"n:2\"}]")
    }
}
