/**
 * @license
 * Copyright (c) 2015 Ninh Pham <nfam.dev@gmail.com>
 *
 * Use of this source code is governed by the MIT license.
 */

// import { Expression, Processors } from "../dist/simex";
import { Expression } from "../src/Expression";
import { Processors } from "../src/Process";

import { expect } from "chai";

// tslint:disable:mocha-no-side-effect-code

const processors: Processors = {
    int: (text: string, radix?: string): string => {
        const v = parseInt(text, parseInt(radix || "10"));
        if (isNaN(v)) {
            throw new Error("invalid number");
        } else {
            return v.toString();
        }
    },
    float: (text: string, fixed?: string): string => {
        const v = parseFloat(text);
        if (isNaN(v)) {
            throw "Error";
        } else if (fixed !== undefined) {
            return v.toFixed(parseInt(fixed || "0"));
        } else {
            return v.toString();
        }
    },
    notfuncion: ("notfunction" as any)
};

const messages = {
    list: "Property \"list\" must be an object.",
    has: "Property \"has\" must be a string.",
    dictionary: "Property \"dictionary\" must be an object.",
    dictionaryValue: "Member value of dictionary must be an object.",
    slice: "Property \"slice\" must be an object.",
    expression: "Expression must be an object.",
    prefix: "Property \"prefix\" must be either a string or an array of strings.",
    process: "Property \"process\" must be a string in format \"function[:args]\", args is optional.",
    processUndefined: "Function is not found in processors.",
    required: "Property \"required\" must be boolean or a non-empty string.",
    backward: "Property \"backward\" must be boolean.",
    separatorMissing: "Property \"separator\" is missing.",
    separator: "Property \"separator\" must be either a non-empty string or an array of non-empty strings.",
    subexpressions: "Only one of slice, array, and dictionary shall be defined.",
    suffix: "Property \"suffix\" must be either a string or an array of strings.",
    trim: "Property \"trim\" must be boolean.",
    between: "Property \"between\" must be an object.",
    unmatch: "Provided input does not match the expression."
};

describe("Expression", () => {
    describe("fromJSON", () => {
        function helpLoad(json: any, p?: Processors) {
            it("should load " + JSON.stringify(json), () => {
                const _ = new Expression(json, p);
            });
        }
        function helpFail(json: any, message: string, p?: Processors) {
            it("should fail " + JSON.stringify(json) + ", and throw `" + message + "`", () => {
                expect(() => new Expression(json, p)).to.throw(message);
            });
        }

        describe("expression", () => {
            helpLoad({});
            helpFail("string", messages.expression);
            helpFail([], messages.expression);
        });
        describe("expression.has", () => {
            helpLoad({ has: "string" });
            helpLoad({ has: "" });
            helpFail({ has: 1 }, messages.has);
        });
        describe("expression.between", () => {
            helpLoad({ between: {} });
            helpFail({ between: 1 }, messages.between);
            helpFail({ between: [] }, messages.between);
        });
        describe("expression.slice", () => {
            helpLoad({ slice: {} });
            helpFail({ slice: "string" }, messages.slice);
            helpFail({ slice: [] }, messages.slice);
            helpFail({ slice: [], list: 1 }, messages.subexpressions);
            helpFail({ slice: [], dictionary: 1 }, messages.subexpressions);
        });
        describe("expression.list", () => {
            helpLoad({ list: { separator: "|" } });
            helpFail({ list: "string" }, messages.list);
            helpFail({ list: [] }, messages.list);
            helpFail({ list: 1, dictionary: 1 }, messages.subexpressions);
        });
        describe("expression.dictionary", () => {
            helpLoad({ dictionary: {} });
            helpFail({ dictionary: "string" }, messages.dictionary);
            helpFail({ dictionary: [] }, messages.dictionary);
        });
        describe("expression.process", () => {
            helpLoad({ process: "int" }, processors);
            helpFail({ process: 1 }, messages.process, processors);
            helpFail({ process: "int1" }, messages.processUndefined, processors);
        });
        describe("betweent.backward", () => {
            helpLoad({ between: { backward: true } });
            helpLoad({ between: { backward: false } });
            helpFail({ between: { backward: 1 } }, messages.backward);
        });
        describe("betweent.prefix", () => {
            helpLoad({ between: { prefix: "string" } });
            helpLoad({ between: { prefix: "" } });
            helpFail({ between: { prefix: 1 } }, messages.prefix);
            helpFail({ between: { prefix: {} } }, messages.prefix);
            helpLoad({ between: { prefix: ["string1", "string2"] } });
            helpLoad({ between: { prefix: ["string1", ""] } });
            helpFail({ between: { prefix: ["string1", 1] } }, messages.prefix);
        });
        describe("betweent.suffix", () => {
            helpLoad({ between: { suffix: "string" } });
            helpLoad({ between: { suffix: "" } });
            helpFail({ between: { suffix: 1 } }, messages.suffix);
            helpFail({ between: { suffix: {} } }, messages.suffix);
            helpLoad({ between: { suffix: ["string1", "string2"] } });
            helpLoad({ between: { suffix: ["string1", ""] } });
            helpFail({ between: { suffix: ["string1", 1] } }, messages.suffix);
        });
        describe("betweent.trim", () => {
            helpLoad({ between: { trim: true } });
            helpLoad({ between: { trim: false } });
            helpFail({ between: { trim: 1 } }, messages.trim);
        });
        describe("slice.required", () => {
            helpLoad({ slice: { required: true } });
            helpLoad({ slice: { required: false } });
            helpLoad({ slice: { required: "label" } });
            helpFail({ slice: { required: 1 } }, messages.required);
            helpFail({ slice: { required: "" } }, messages.required);
        });
        describe("slice.has", () => {
            helpLoad({ slice: { has: "content" } });
            helpLoad({ slice: { has: "" } });
            helpFail({ slice: { has: 1 } }, messages.has);
        });
        describe("slice.between", () => {
            helpLoad({ slice: { between: {} } });
            helpFail({ slice: { between: 1 } }, messages.between);
            helpFail({ slice: { between: [] } }, messages.between);
        });
        describe("slice.process", () => {
            helpLoad({ slice: { process: "int" } }, processors);
            helpLoad({ slice: { process: "int:8" } }, processors);
            helpFail({ slice: { process: 1 } }, messages.process, processors);
            helpFail({ slice: { process: ":int" } }, messages.process, processors);
            helpFail({ slice: { process: "int1" } }, messages.processUndefined, processors);
        });
        describe("list.separator", () => {
            helpFail({ list: { } }, messages.separatorMissing);
            helpLoad({ list: { separator: "string" } });
            helpFail({ list: { separator: "" } }, messages.separator);
            helpFail({ list: { separator: 1 } }, messages.separator);
            helpFail({ list: { separator: {} } }, messages.separator);
            helpLoad({ list: { separator: ["string1", "string2"] } });
            helpFail({ list: { separator: ["string1", ""] } }, messages.separator);
            helpFail({ list: { separator: ["string1", 1] } }, messages.separator);
        });
        describe("list.slice", () => {
            helpLoad({ list: { separator: "|", slice: {} } });
            helpFail({ list: { separator: "|", slice: "string" } }, messages.slice);
            helpFail({ list: { separator: "|", slice: [] } }, messages.slice);
        });
        describe("dictionary.slice", () => {
            helpLoad({ dictionary: { name: {} } });
            helpFail({ dictionary: { name: "string" } }, messages.dictionaryValue);
            helpFail({ dictionary: { name: [] } }, messages.dictionaryValue);
        });
    });

    describe("toJON", () => {
        function helpIt(json: any, p?: Processors) {
            it("should toJSON() equal to " + JSON.stringify(json), () => {
                expect(JSON.parse(JSON.stringify(new Expression(json, p)))).deep.equal(json);
            });
        }
        [
            {},
            { required: true },
            { required: false },
            { required: " " },
            { has: "valid" },
            { has: "" },
            { between: {}},
            { between: { backward: true }},
            { between: { prefix: "1" }},
            { between: { prefix: "" }},
            { between: { prefix: ["1", "2"] }},
            { between: { prefix: ["1", ""] }},
            { between: { suffix: "1" }},
            { between: { suffix: "" }},
            { between: { suffix: ["1", "2"] }},
            { between: { suffix: ["1", ""] }},
            { between: { trim: true }},
            { between: { trim: false }},
            { slice: {}},
            { slice: { dictionary: { name: { has: "valid" }}}},
            { list: { separator: "|" }},
            { list: { separator: ["|"] }},
            { list: { separator: "|", slice: { }}},
            { dictionary: { name: { has: "valid" }}},
            { process: "int" },
            { process: "int:1" }
        ]
        .forEach(json => helpIt(json, processors));
    });

    describe("extract", () => {
        function helpMatch(json: any, input: string, output: any, p?: Processors) {
            it("should extract with " + JSON.stringify(json) + " from \"" + input + "\" to " + JSON.stringify(output), () => {
                expect(new Expression(json, p).extract(input)).deep.equal(output);
            });
        }
        function helpFail(json: any, input: string, message: string, p?: Processors) {
            it("should fail with " + JSON.stringify(json) + " from \"" + input + "\", throw `" + message + "`", () => {
                expect(() => new Expression(json, p).extract(input)).throw(message);
            });
        }
        describe("has", () => {
            helpMatch({ has: "#" }, " #0 ", " #0 ");
            helpFail({ has: " ) " }, " # ", messages.unmatch);
        });
        describe("between", () => {
            [
                {
                    text: " 0 1 2 3 ",
                    json: { between: { prefix: "" }},
                    result: " 0 1 2 3 "
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { prefix: "0" }},
                    result: " 1 2 3 "
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { prefix: "0", trim: true }},
                    result: "1 2 3"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { prefix: "3", trim: true }},
                    result: ""
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { prefix: ["0", "1"], trim: true }},
                    result: "2 3"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { suffix: "1", trim: true }},
                    result: "0"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { suffix: ["", "0"], trim: true }},
                    result: ""
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { suffix: ["4", "2"], trim: true }},
                    result: "0 1"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { prefix: ["0", "1"], suffix: "3", trim: true }},
                    result: "2"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { backward: true, prefix: "1" }},
                    result: " 0 "
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { backward: true, prefix: "1", trim: true }},
                    result: "0"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { backward: true, prefix: "3", trim: true }},
                    result: "0 1 2"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { backward: true, prefix: ["3", "2"], trim: true }},
                    result: "0 1"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { backward: true, suffix: "1", trim: true }},
                    result: "2 3"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { backward: true, suffix: "0", trim: true }},
                    result: "1 2 3"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { backward: true, prefix: ["3", "2"], suffix: "0", trim: true }},
                    result: "1"
                }
            ]
            .forEach(sample => helpMatch(sample.json, sample.text, sample.result, processors));

            [
                {
                    text: " 0 1 2 3 ",
                    json: { between: { prefix: "#" }},
                    at: "between.prefix"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { prefix: ["0", "#"] }},
                    at: "between.prefix.#(1)"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { suffix: "4" }},
                    at: "between.suffix"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { backward: true, prefix: "#" }},
                    at: "between.prefix"
                }, {
                    text: " 0 1 2 4 ",
                    json: { between: { backward: true, prefix: ["0", "#"] }},
                    at: "between.prefix.#(1)"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { backward: true, suffix: "4" }},
                    at: "between.suffix"
                }
            ]
            .forEach(sample => helpFail(sample.json, sample.text, messages.unmatch + " @ " + sample.at, processors));
        });
        describe("slice", () => {
            [
                {
                    text: " 0 1 2 3 ",
                    json: { slice: { between: { prefix: "0" }}},
                    result: " 1 2 3 "
                }
            ]
            .forEach(sample => helpMatch(sample.json, sample.text, sample.result, processors));

            [
                {
                    text: " 0 1 2 3 ",
                    json: { between: { prefix: "0" },  slice: { between: { prefix: "0" }}},
                    at: "slice.between.prefix"
                }, {
                    text: " 0 1 2 3 ",
                    json: { between: { prefix: "0" },  slice: { between: { prefix: "0" }}},
                    at: "slice.between.prefix"
                }
            ]
            .forEach(sample => helpFail(sample.json, sample.text, messages.unmatch + " @ " + sample.at, processors));
        });
        describe("list", () => {
            [
                {
                    text: " 0 ",
                    json: { list: { separator: " " }},
                    result: ["0"]
                }, {
                    text: " 0 1 2 3 ",
                    json: { list: { separator: " " }},
                    result: ["0", "1", "2", "3"]
                }, {
                    text: " 0  1  2  3 ",
                    json: { list: { separator: " " }},
                    result: ["0", "1", "2", "3"]
                }, {
                    text: " 0|1|2|3 ",
                    json: { list: { separator: [" ", "|"] }},
                    result: ["0", "1", "2", "3"]
                }, {
                    text: " #0|#1|#2|3 ",
                    json: { list: { separator: [" ", "|"], slice: { required: false, has: "#" }}},
                    result: ["#0", "#1", "#2"]
                }, {
                    text: " #0|#1|#2|#|3 ",
                    json: { list: { separator: [" ", "|"], slice: { required: false, between: { prefix: "#" }}}},
                    result: ["0", "1", "2"]
                }, {
                    text: " n1:v1, n2:v2",
                    json: { list: {
                        separator: "|",
                        slice: { dictionary: {
                            n1: { between: { prefix: "n1:", suffix: "," }},
                            n2: { between: { prefix: "n2:" }}
                        }}}},
                    result: [{ n1: "v1", n2: "v2" }]
                }
            ]
            .forEach(sample => helpMatch(sample.json, sample.text, sample.result, processors));

            [
                {
                    text: "#0|#1|#2|3",
                    json: { list: { separator: "|", slice: { between: { prefix: "#" }}}},
                    at: "list.slice.between.prefix"
                }, {
                    text: "#0|#1|#2|3",
                    json: { list: { separator: "|", slice: { between: { prefix: "#" }}}},
                    at: "list.slice.between.prefix"
                }
            ]
            .forEach(sample => helpFail(sample.json, sample.text, messages.unmatch + " @ " + sample.at, processors));
        });
        describe("dictonary", () => {
            [
                {
                    text: " 0 ",
                    json: { dictionary: { name: {}}},
                    result: { name: " 0 "}
                }, {
                    text: " 0 ",
                    json: { dictionary: { name: { between: { trim: true }}}},
                    result: { name: "0"}
                }, {
                    text: " n0:0 n1: 1# ",
                    json: { dictionary: {
                        n0: { between: { prefix: "n0:", suffix: " " }},
                        n1: { between: { prefix: "n1:", suffix: "#", trim: true }
                    }}},
                    result: { n0: "0", n1: "1" }
                }, {
                    text: " n0:0 n1: 1# ",
                    json: { dictionary: {
                        n0: { between: { prefix: "n0:", suffix: " " }},
                        n1: { required: false, between: { prefix: "n1:", suffix: "$" }
                    }}},
                    result: { n0: "0" }
                }, {
                    text: " n0:0 n1: 1# ",
                    json: { dictionary: {
                        n0: { required: "g", between: { prefix: "n0:", suffix: " " }},
                        n1: { required: "g", between: { prefix: "n1:", suffix: "$" }
                    }}},
                    result: { n0: "0" }
                }
            ]
            .forEach(sample => helpMatch(sample.json, sample.text, sample.result, processors));
            [
                {
                    text: " 0 ",
                    json: { dictionary: { name: { has: "#" }}},
                    at: "dictionary.name.has"
                }, {
                    text: " 0 ",
                    json: { dictionary: { name: { required: "g", has: "#" }}},
                    at: "dictionary.name(g).has"
                }, {
                    text: " 0 ",
                    json: { dictionary: { name: { has: "#" }}},
                    at: "dictionary.name.has"
                }
            ]
            .forEach(sample => helpFail(sample.json, sample.text, messages.unmatch + " @ " + sample.at, processors));
        });
        describe("process", () => {
            [
                {
                    text: " 0 1th 2 3 ",
                    json: { slice: { between: { prefix: "0", trim: true }, process: "int" }},
                    result: "1"
                }
            ]
            .forEach(sample => helpMatch(sample.json, sample.text, sample.result, processors));
            [
                {
                    text: " 0 th 2 3 ",
                    json: { between: { prefix: "0", trim: true }, process: "int" },
                    at: "process"
                },
                {
                    text: " 0 th 2 3 ",
                    json: { between: { prefix: "0", trim: true }, process: "float" },
                    at: "process"
                },
                {
                    text: " 0 th 2 3 ",
                    json: { slice: { between: { prefix: "0", trim: true }, process: "int" }},
                    at: "slice.process"
                }
            ]
            .forEach(sample => helpFail(sample.json, sample.text, messages.unmatch + " @ " + sample.at, processors));
        });
    });
});