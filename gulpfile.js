var gulp = require('gulp');
var change = require('gulp-change');
var concat = require('gulp-concat');
var strip = require('gulp-strip-comments');
var ts = require('gulp-typescript');

const licenseBeg =
`/**
 * @license
`;
const license =
`/**
 * @license
 * Copyright (c) 2015 Ninh Pham <nfam.dev@gmail.com>
 *
 * Use of this source code is governed by The MIT license.
 */
`;

gulp.task('build', function() {
    return gulp.src(['src/**/*.ts'])
    .pipe(change((content) => {
        if (content.indexOf(licenseBeg) == 0) {
            content = content.substring(content.indexOf('*/') + 2)
        }
        return content;
    }))
    .pipe(concat('simex.ts'))
    .pipe(change((content) => {
        return content.split('\n').map((line) => {
            if (line.startsWith('export default')) {
                return line.substring('export default'.length);
            }
            else if (line.startsWith('export')) {
                return line.substring('export'.length);
            }
            else if (line.startsWith('import')) {
                return '';
            }
            else if (line.startsWith('// tslint:')) {
                return '';
            }
            else {
                return line;
            }
        }).join('\n');
    }))
    .pipe(change(content => license + content))
    .pipe(ts({
        "target": "es5",
        "module": "umd",
        "declaration": true,
        "noImplicitAny": true
    }))
    .pipe(gulp.dest('dist/'));
})
