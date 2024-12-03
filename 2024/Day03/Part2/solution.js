// bun run solution.js
const contents = await Bun.file("sample.txt").text();
const regex = /mul\((\d+),(\d+)\)|do\(\)|don't\(\)/gm;

let result = 0;
let enabled = true;

for (const match of contents.matchAll(regex)) {
    switch (match[0]) {
        case "do()":
            enabled = true;
            break;
        case "don't()":
            enabled = false;
            break;
        default: {
            if (enabled) {
                const lhs = parseInt(match[1], 10);
                const rhs = parseInt(match[2], 10);
                result += lhs * rhs;
            }
        }
    }
}

console.log(result);
