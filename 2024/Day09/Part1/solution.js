// clear && bun run solution.js
import { readInput } from "../../../helpers/bun";

const contents = await readInput("sample.txt");

/** @type {(bigint | ".")[]} */
let memory = []; {
    let file_id = 0n;
    let is_file = true;
    for (const letter of contents) {
        const letter_num = Number(letter);
        if (is_file === true) {
            for (let i = 0; i < letter_num; i++) {
                memory.push(file_id);
            }
            file_id += 1n;
            is_file = false;
        }
        else {
            for (let i = 0; i < letter_num; i++) {
                memory.push(".");
            }
            is_file = true;
        }
    }
}

/**
 * @param {string[]} memory
 * @return {number | null}
 */
function stillHasLeftwardMemory(memory) {
    /** @type {number | null} */
    let empty_index = null;
    for (let i = 0; i < memory.length; i++) {
        const block = memory[i];
        if (block === "." && empty_index === null) {
            empty_index = i;
            continue;
        }
        if (typeof block === "bigint" && empty_index !== null) {
            return empty_index;
        }
    }
    return null;
}

/**
 * @param {string[]} memory
 * @return {[number, string] | null}
 */
function findLastFileBlockIndex(
    memory
) {
    for (let i = memory.length - 1; i >= 0; i--) {
        const block = memory[i];
        if (typeof block === "bigint") {
            return [i, block];
        }
    }
    return null;
}

console.log(memory.join(""));

console.log("Running defragmenter!");

/** @type {number | null} */
let leftward_most_memory = null;
while ((leftward_most_memory = stillHasLeftwardMemory(memory)) !== null) {
    const last_file_block = findLastFileBlockIndex(memory);
    if (last_file_block === null) {
        break;
    }
    const [last_file_block_index, block] = last_file_block;
    memory[leftward_most_memory] = block;
    memory[last_file_block_index] = ".";
    //console.log(memory.join(""));
}

console.log(memory.join(""));

console.log("Running checksum!");

let checksum = 0n;
for (let i = 0; i < memory.length; i++) {
    const block = memory[i];
    if (typeof block === "bigint") {
        checksum += BigInt(i) * block;
    }
}

console.log(`Result: ${checksum}`);
