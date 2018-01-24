/**
 * @license
 * Copyright (c) 2015 Ninh Pham <nfam.dev@gmail.com>
 *
 * Use of this source code is governed by The MIT license.
 */

// tslint:disable:no-single-line-block-comment

import { AtError, addMessageAt, messages } from "./AtError";
import { Processors } from "./Process";
import { Slice } from "./Subexpression";

/**
 * Represents an instance of expression from JSON.
 * @export
 * @class Expression
 */
/* export */ export class Expression {
    private readonly expression: Slice;

    /**
     * Creates an instance of Expression.
     * @param {*} json
     * @param {Processors} [processors]
     * @throws {ExpressionError} if the provided expression does not comply the syntax.
     * @memberof Expression
     */
    constructor(json: any, processors?: Processors) {
        if (typeof json !== "object" || json instanceof Array) {
            throw new AtError(messages.expression);
        }
        processors = processors || {};
        try {
            this.expression = new Slice(json, processors, "");
        } catch (error) {
            addMessageAt(error);
            throw error;
        }
    }

    /**
     * Extracts content in JSON of schema defined by the expression.
     * @param {string} input Input input to extract content from.
     * @returns {*} Result content in JSON format.
     * @throws {ExtractionError} if the input input does not match the expression.
     * @memberof Expression
     */
    public extract(input: string): any {
        try {
            const result = this.expression.extract(input);
            return avoidMemoryLeak(result);
        } catch (error) {
            addMessageAt(error);
            throw error;
        }
    }

    /**
     * Returns the original expression in JSON format.
     * @returns {*}
     * @memberof Expression
     */
    public toJSON(): any {
        return this.expression.toJSON();
    }
}

// substring creates a view on original string instead of generating new one.
// Force to generate to reduce memory if the original string is too huge.
function avoidMemoryLeak(item: any): any {
    if (typeof item === "string") {
        item = (" " + item).substring(1);
    }
    else if (typeof item === "object") {
        if (item instanceof Array) {
            for (let i = 0; i < item.length; i += 1) {
                item[i] = avoidMemoryLeak(item[i]);
            }
        }
        else {
            Object.keys(item).forEach((key) => {
                item[key] = avoidMemoryLeak(item[key]);
            });
        }
    }
    return item;
}
