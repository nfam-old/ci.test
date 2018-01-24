/**
 * @license
 * Copyright (c) 2015 Ninh Pham <nfam.dev@gmail.com>
 *
 * Use of this source code is governed by The MIT license.
 */

import { AtError, addPrefixAt, messages } from "./AtError";
import { Between } from "./Between";
import { Process, Processors } from "./Process";

export interface Subexpression  {
    extract(input: string): any;
    toJSON(): any;
}

export class Slice implements Subexpression {
    public readonly required?: boolean | string;
    public readonly has?: string;
    public readonly between?: Between;
    public readonly process?: Process;
    public readonly subexpression?: Subexpression;
    private readonly subtype: "slice" | "list" | "dictionary";
    private readonly label: string;

    constructor(json: any, processors: Processors, label: string) {
        this.label = label;
        try {
            if (typeof json !== "object" || json instanceof Array) {
                throw new AtError(messages.slice);
            }

            if (json.hasOwnProperty("required")) {
                if (typeof json.required !== "boolean" && (
                    typeof json.required !== "string" ||
                    json.required.length === 0
                )) {
                    throw new AtError(messages.required, "required");
                }
                this.required = json.required;
            }

            if (json.hasOwnProperty("has")) {
                if (typeof json.has !== "string") {
                    throw new AtError(messages.has, "has");
                }
                this.has = json.has;
            }

            if (json.hasOwnProperty("between")) {
                this.between = new Between(json.between);
            }

            if (json.hasOwnProperty("process")) {
                this.process = new Process(json.process, processors);
            }

            if (json.hasOwnProperty("slice")) {
                if (json.hasOwnProperty("list") || json.hasOwnProperty("dictionary")) {
                    throw new AtError(messages.subexpressions);
                }
                this.subexpression = new Slice(json.slice, processors, "slice");
                this.subtype = "slice";
            }
            else if (json.hasOwnProperty("list")) {
                if (json.hasOwnProperty("dictionary")) {
                    throw new AtError(messages.subexpressions);
                }
                this.subexpression = new List(json.list, processors);
                this.subtype = "list";
            }
            else if (json.hasOwnProperty("dictionary")) {
                this.subexpression = new Dictionary(json.dictionary, processors);
                this.subtype = "dictionary";
            }
        } catch (error) {
            addPrefixAt(error, this.label);
            throw error;
        }
    }

    public extract(input: string): any {
        let str = input;

        try {
            if (this.has && this.has.length > 0) {
                if (str.indexOf(this.has) < 0) {
                    throw new AtError(messages.unmatch, "has");
                }
            }

            if (this.between) {
                str = this.between.extract(str);
            }

            if (this.process) {
                str = this.process.extract(str);
            }

            if (this.subexpression) {
                str = this.subexpression.extract(str);
            }
        } catch (error) {
            addPrefixAt(error, this.label);
            throw error;
        }

        return str;
    }

    public toJSON() {
        const json: any = { };
        if (this.required !== undefined) {
            json.required = this.required;
        }
        if (this.has !== undefined) {
            json.has = this.has;
        }
        if (this.between !== undefined) {
            json.between = this.between.toJSON();
        }
        if (this.process !== undefined) {
            json.process = this.process.toJSON();
        }
        if (this.subexpression) {
            json[this.subtype] = this.subexpression.toJSON();
        }
        return json;
    }
}

class List implements Subexpression {

    public readonly separator: string | string[];
    public readonly slice?: Slice;

    constructor(json: any, processors: Processors) {
        try {
            if (typeof json !== "object" || json instanceof Array) {
                throw new AtError(messages.list);
            }

            if (json.hasOwnProperty("separator")) {
                switch (typeof json.separator) {
                case "string":
                    if (json.separator.length === 0) {
                        throw new AtError(messages.separator, "separator");
                    }
                    this.separator = json.separator;
                    break;
                case "object":
                    if (json.separator instanceof Array) {
                        json.separator.forEach((separator: any) => {
                            if (typeof(separator) !== "string" || separator.length === 0) {
                                throw new AtError(messages.separator, "separator");
                            }
                        });
                        this.separator = json.separator;
                    }
                }
                if (this.separator === undefined) {
                    throw new AtError(messages.separator, "separator");
                }
            }
            else {
                throw new AtError(messages.separatorMissing);
            }

            if (json.hasOwnProperty("slice")) {
                this.slice = new Slice(json.slice, processors, "slice");
            }
        } catch (error) {
            addPrefixAt(error, "list");
            throw error;
        }
    }

    public extract(input: string): any {
        const list = [];
        try {
            let parts = [input];
            const separators = (typeof this.separator === "string") ? [this.separator] : this.separator;
            for (let si = 0; si < separators.length; si += 1) {
                const groups = [];
                for (let ii = 0; ii < parts.length; ii += 1) {
                    groups[ii] = parts[ii].split(separators[si]);
                }
                parts = [].concat.apply([], groups);
            }
            for (let i = 0; i < parts.length; i += 1) {
                const item = parts[i];
                if (item.length === 0) {
                    continue;
                }
                if (this.slice) {
                    try {
                        const result = this.slice.extract(item);
                        if (typeof result === "string") {
                            if (result.length > 0) {
                                list.push(result);
                            }
                        } else {
                            list.push(result);
                        }
                    } catch (error) {
                        if (this.slice.required === undefined || this.slice.required) {
                            throw error;
                        }
                    }
                } else {
                    list.push(item);
                }
            }
        } catch (error) {
            addPrefixAt(error, "list");
            throw error;
        }
        return list;
    }

    public toJSON() {
        const json: any = { separator: this.separator };
        if (this.slice) {
            json.slice = this.slice.toJSON();
        }
        return json;
    }
}

class Dictionary implements Subexpression {
    private readonly members: { [name: string]: Slice };

    constructor(json: any, processors: Processors) {
        try {
            if (typeof json !== "object" || json instanceof Array) {
                throw new AtError(messages.dictionary);
            }

            this.members = {};
            Object.keys(json).forEach(name => {
                const value = json[name];
                if (typeof value !== "object" || value instanceof Array) {
                    throw new AtError(messages.dictionaryValue, name);
                }
                this.members[name] = new Slice(value, processors, "");
            });
        } catch (error) {
            addPrefixAt(error, "dictionary");
            throw error;
        }
    }

    public extract(input: string): any {
        const dictionary: { [name: string]: any } = {};
        const errors: { [name: string]: AtError } = {};

        const names = Object.keys(this.members);
        for (let i = 0; i < names.length; i += 1) {
            const name = names[i];
            const member = this.members[name];

            try {
                dictionary[name] = member.extract(input);
                if (typeof member.required === "string") {
                    errors[member.required] = undefined;
                }
            } catch (error) {
                if (member.required === undefined || member.required) {
                    if (typeof member.required !== "string") {
                        addPrefixAt(error, "dictionary." + name);
                        throw error;
                    } else if (!(member.required in errors)) {
                        addPrefixAt(error, "dictionary." + name + "(" + member.required + ")");
                        errors[member.required] = error;
                    }
                }
            }
        }

        const requireds = Object.keys(errors);
        for (let i = 0; i < requireds.length; i += 1) {
            const required = requireds[i];
            const error = errors[required];
            if (error !== undefined) {
                throw error;
            }
        }

        return dictionary;
    }

    public toJSON() {
        const json: any = {};
        Object.keys(this.members).forEach((name) => {
            json[name] = this.members[name].toJSON();
        });
        return json;
    }
}