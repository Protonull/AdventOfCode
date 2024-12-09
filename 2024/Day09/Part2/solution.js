// clear && bun run solution.js
import { readInput } from "../../../helpers/bun";

const contents = await readInput("sample.txt");

/**
 * @abstract
 */
class Batch {
    /** @type {number} */
    ptr;
    /** @type {number} */
    len;
}

class Empty extends Batch {
    constructor(
        /** @type {number} */
        ptr,
        /** @type {number} */
        len
    ) {
        super();
        this.ptr = ptr;
        this.len = len;
    }

    toString() {
        return `{ptr: ${this.ptr}, len: ${this.len}}`;
    }
}

class File extends Batch {
    /** @type {string} */
    file_id;

    constructor(
        /** @type {string} */
        file_id,
        /** @type {number} */
        ptr,
        /** @type {number} */
        len
    ) {
        super();
        this.file_id = file_id;
        this.ptr = ptr;
        this.len = len;
    }

    toString() {
        return `{id: "${this.file_id}", ptr: ${this.ptr}, len: ${this.len}}`;
    }
}


/** @type {File[]} */
const files = [];
/** @type {Empty[]} */
const empties = [];

{
    let ptr = 0;
    let file_id = 0;
    let is_file = true;
    for (const letter of contents) {
        const length = Number(letter);
        if (is_file === true) {
            files.push(new File(String(file_id), ptr, length));
            file_id += 1;
            is_file = false;
        }
        else {
            empties.push(new Empty(ptr, length));
            is_file = true;
        }
        ptr += length;
    }
}

function combineEmptiesWherePossible() {
    if (empties.length < 2) {
        return;
    }
    empties.sort((lhs, rhs) => lhs.ptr - rhs.ptr);
    let i = 1;
    while (i < empties.length) {
        const lhs = empties[i - 1];
        const rhs = empties[i];
        if ((lhs.ptr + lhs.len) === rhs.ptr) {
            lhs.len += rhs.len;
            empties.splice(i, 1);
            continue;
        }
        i += 1;
    }
}

function printFs() {
    console.debug(
        [].concat(files, empties)
            .toSorted((lhs, rhs) => lhs.ptr - rhs.ptr)
            .map((batch) => {
                if (batch instanceof File) {
                    return (new Array(batch.len)).fill(batch.file_id).join(",");
                }
                if (batch instanceof Empty) {
                    return ".".repeat(batch.len);
                }
                throw `Invalid type "${batch.type}"`;
            })
            .join("|")
    );
}

file_loop: for (const file of files.toReversed()) {
    console.debug(`Defragging file [${file}]`);
    combineEmptiesWherePossible();
    printFs();
    for (let i = 0; i < empties.length; i++) {
        const empty = empties[i];
        if (file.ptr < empty.ptr) {
            continue;
        }
        if (empty.len < file.len) {
            console.debug(` Skipping empty [${empty}]: too small`);
            continue;
        }
        const previous_file_ptr = file.ptr;
        file.ptr = empty.ptr;
        if (empty.len === file.len) {
            console.debug(` Consumed [${empty}]!`);
            empty.ptr = previous_file_ptr;
            continue file_loop;
        }
        console.debug(` Consuming [${file.len}] memory of [${empty}]!`);
        empty.ptr += file.len;
        empty.len -= file.len;
        console.debug(` -Empty is now [${empty}]!`);
        empties.push(new Empty(previous_file_ptr, file.len));
        continue file_loop;
    }
}
combineEmptiesWherePossible();
printFs();


let checksum = 0n;
for (const [file_id, file] of files.entries()) {
    for (let i = 0; i < file.len; i++) {
        checksum += BigInt(file_id) * BigInt(file.ptr + i);
    }
}

console.log(`Result: ${checksum}`);
