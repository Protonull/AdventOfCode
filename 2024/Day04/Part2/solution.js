// bun run solution.js
const contents = await Bun.file("sample.txt").text();

let result = 0;

/** @type string[] */
const grid = contents.split("\n");

function getLetter(x, y) {
    return (grid[y] ?? [])[x];
}

for (let y = 0; y < grid.length; y++) {
    const line = grid[y];
    for (let x = 0; x < line.length; x++) {
        if (getLetter(x, y) === "A") {
            if (
                ((getLetter(x-1, y-1) === "M" && getLetter(x+1, y+1) === "S") || (getLetter(x-1, y-1) === "S" && getLetter(x+1, y+1) === "M")) &&
                ((getLetter(x-1, y+1) === "M" && getLetter(x+1, y-1) === "S") || (getLetter(x-1, y+1) === "S" && getLetter(x+1, y-1) === "M"))
            ) {
                result += 1;
            }
        }
    }
}

console.log(`Result: ${result}`);
