// bun run solution.js
const contents = await Bun.file("sample.txt").text();

const [grid_width, grid] = (function(){
    /** @type {string[][]} */
    const lines = contents.split("\n").map((line) => line.split(""));
    /** @type {bigint | null} */
    let line_width = null;
    for (const line of lines) {
        const current_length = BigInt(line.length);
        if (line_width === null) {
            line_width = current_length;
            continue;
        }
        if (line_width !== current_length) {
            throw `Line length [${current_length}] does not match existing length [${line_width}]`;
        }
    }
    if (line_width === null) {
        throw `No line width set!`;
    }
    return [
        line_width,
        lines
    ];
})();

/** @type {Map<string, [bigint, bigint][]>} */
const antennas = new Map();

/**
 * @param {bigint} x
 * @param {bigint} y
 * @return {string | null}
 */
function getSlot(x, y) {
    return (grid[Number(y)] ?? [])[Number(x)] ?? null;
}

for (let y = 0n; y < BigInt(grid.length); y++) {
    for (let x = 0n; x < BigInt(grid_width); x++) {
        const slot = getSlot(x, y);
        if (slot === null) {
            throw `How is [${x}, ${y}] missing?!`;
        }
        if (slot === ".") {
            continue; // Slot is nothing
        }
        let antenna_locations = antennas.get(slot) ?? null;
        if (antenna_locations === null) {
            antenna_locations = [];
            antennas.set(slot, antenna_locations);
        }
        antenna_locations.push([x, y]);
    }
}

/** @type {[bigint, bigint][]} */
const antinodes = [];
/**
 * @param {bigint} x
 * @param {bigint} y
 */
function addAntinode(x, y) {
    if (x < 0n || x >= BigInt(grid_width) || y < 0n || y >= BigInt(grid.length)) {
        console.log(`Out of grid: [${x}, ${y}]`);
        return;
    }
    for (const [antinodeX, antinodeY] of antinodes) {
        if (x === antinodeX && y === antinodeY) {
            console.log(`Already exists: [${x}, ${y}]`);
            return;
        }
    }
    antinodes.push([x, y]);
}

for (const [type, locations] of antennas.entries()) {
    if (locations.length < 2) {
        continue; // Not enough to have pairs
    }
    console.log("type: " + type);
    for (const [i, [x, y]] of locations.entries()) {
        let internal_index = i;
        for (const [otherX, otherY] of locations.slice(i + 1)) {
            console.log(`Checking [${i}] versus [${++internal_index}]`);

            const antinodeX = x + (x - otherX);
            const antinodeY = y + (y - otherY);
            console.log([antinodeX, antinodeY]);
            addAntinode(antinodeX, antinodeY);

            const mirroredAntinodeX = otherX - (x - otherX);
            const mirroredAntinodeY = otherY - (y - otherY);
            console.log([mirroredAntinodeX, mirroredAntinodeY]);
            addAntinode(mirroredAntinodeX, mirroredAntinodeY);
        }
    }
}

console.log(`Result: ${antinodes.length}`);
