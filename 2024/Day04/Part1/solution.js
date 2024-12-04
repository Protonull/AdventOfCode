// bun run solution.js
const contents = await Bun.file("sample.txt").text();

let result = 0;

/** @type string[] */
const grid = contents.split("\n");

console.log(grid);

const offsets = [
    [-1, -1], [ 0, -1], [ 1, -1],
    [-1,  0],           [ 1,  0],
    [-1,  1], [ 0,  1], [ 1,  1],
];

function getLetter(x, y) {
    return (grid[y] ?? [])[x];
}

for (let y = 0; y < grid.length; y++) {
    const line = grid[y];
    for (let x = 0; x < line.length; x++) {
        if (line[x] === "X") {
            for (const [offsetX, offsetY] of offsets) {
                if (getLetter(x + offsetX, y + offsetY) !== "M") {
                    continue;
                }
                if (getLetter(x + offsetX * 2, y + offsetY * 2) !== "A") {
                    continue;
                }
                if (getLetter(x + offsetX * 3, y + offsetY * 3) !== "S") {
                    continue;
                }
                result += 1;
            }
        }
    }
}

console.log(`Result: ${result}`);
