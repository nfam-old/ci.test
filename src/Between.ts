/**
 * @license
 * Copyright (c) 2015 Ninh Pham <nfam.dev@gmail.com>
 *
 * Use of this source code is governed by The MIT license.
 */

import { AtError, messages } from "./AtError";

export class Between {

    public readonly backward?: boolean;
    public readonly prefix?: string | string[];
    public readonly suffix?: string | string[];
    public readonly trim?: boolean;

    constructor(json: any) {
        if (typeof json !== "object" || json instanceof Array) {
            throw new AtError(messages.between);
        }

        if (json.hasOwnProperty("backward")) {
            if (typeof json.backward !== "boolean") {
                throw new AtError(messages.backward, "between.backward");
            }
            this.backward = json.backward;
        }

        if (json.hasOwnProperty("prefix")) {
            switch (typeof json.prefix) {
            case "string":
                this.prefix = json.prefix;
                break;
            case "object":
                if (json.prefix instanceof Array) {
                    json.prefix.forEach((prefix: any) => {
                        if (typeof(prefix) !== "string") {
                            throw new AtError(messages.prefix, "between.prefix");
                        }
                    });
                    this.prefix = json.prefix;
                }
            }
            if (this.prefix === undefined) {
                throw new AtError(messages.prefix, "between.prefix");
            }
        }

        if (json.hasOwnProperty("suffix")) {
            switch (typeof json.suffix) {
            case "string":
                this.suffix = json.suffix;
                break;
            case "object":
                if (json.suffix instanceof Array) {
                    json.suffix.forEach((suffix: any) => {
                        if (typeof(suffix) !== "string") {
                            throw new AtError(messages.suffix, "between.suffix");
                        }
                    });
                    this.suffix = json.suffix;
                }
            }
            if (this.suffix === undefined) {
                throw new AtError(messages.suffix, "between.suffix");
            }
        }

        if (json.hasOwnProperty("trim")) {
            if (typeof json.trim !== "boolean") {
                throw new AtError(messages.trim, "between.suffix");
            }
            this.trim = json.trim;
        }
    }

    public extract(input: string): any {
        let str = input;

        // prefix
        const prefixes = this.prefix === undefined ? []
            : ((typeof this.prefix === "string") ? [this.prefix]
            : this.prefix);
        for (let i = 0; i < prefixes.length; i += 1) {
            const prefix = prefixes[i];
            if (prefix.length > 0) {
                if (this.backward) {
                    const end = str.lastIndexOf(prefix);
                    if (end >= 0) {
                        str = str.substring(0, end);
                    }
                    else {
                        if (typeof this.prefix === "string") {
                            throw new AtError(messages.unmatch, "between.prefix");
                        }
                        else {
                            throw new AtError(messages.unmatch, "between.prefix." + prefix + "(" + i + ")");
                        }
                    }
                }
                else {
                    const start = str.indexOf(prefix);
                    if (start >= 0) {
                        str = str.substring(start + prefix.length);
                    }
                    else {
                        if (typeof this.prefix === "string") {
                            throw new AtError(messages.unmatch, "between.prefix");
                        }
                        else {
                            throw new AtError(messages.unmatch, "between.prefix." + prefix + "(" + i + ")");
                        }
                    }
                }
            }
        }

        // suffix
        const suffixes = this.suffix === undefined ? []
            : ((typeof this.suffix === "string") ? [this.suffix]
            : this.suffix);
        let suffixed = false;
        let suffixesCount = 0;
        for (let i = 0; i < suffixes.length; i += 1) {
            const suffix = suffixes[i];
            if (suffix.length > 0) {
                suffixesCount += 1;
                if (this.backward) {
                    const start = str.lastIndexOf(suffix);
                    if (start >= 0) {
                        str = str.substring(start + suffix.length);
                        suffixed = true;
                        break;
                    }
                }
                else {
                    const end = str.indexOf(suffix);
                    if (end >= 0) {
                        str = str.substring(0, end);
                        suffixed = true;
                        break;
                    }
                }
            }
        }
        if (!suffixed && suffixesCount > 0) {
            throw new AtError(messages.unmatch, "between.suffix");
        }

        // trim
        if (this.trim) {
            str = str.trim();
        }

        return str;
    }

    public toJSON() {
        const json: any = { };
        if (this.backward !== undefined) {
            json.backward = this.backward;
        }
        if (this.prefix !== undefined) {
            json.prefix = this.prefix;
        }
        if (this.suffix !== undefined) {
            json.suffix = this.suffix;
        }
        if (this.trim !== undefined) {
            json.trim = this.trim;
        }
        return json;
    }
}
