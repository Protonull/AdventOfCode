// bun run solution.js
const contents = await Bun.file("sample.txt").text();
const regex = /mul\((\d+),(\d+)\)/gm;

let result = 0;

for (const match of contents.matchAll(regex)) {
    const lhs = parseInt(match[1], 10);
    const rhs = parseInt(match[2], 10);
    result += lhs * rhs;
}

console.log(result);
