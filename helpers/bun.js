// Just getting really bored of writing the same code over and over

/**
 * @param {string} filename
 * @return {Promise<string>}
 */
export async function readInput(
    filename,
) {
    return await Bun.file(filename).text();
}

/**
 * Parses the input/sample file and provides a [grid_width, grid_height, grid] result.
 *
 * @param {string} contents
 * @return {[bigint, bigint, string[][]]}
 */
export function parseGrid(
    contents
) {
    const lines = contents.split("\n")
        .filter((line) => line !== "")
        .map((line) => line.split(""));
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
        BigInt(lines.length),
        lines
    ];
}

/**
 * @template T
 * @param {T[][]} grid
 * @param {(slot: T) => T} slot_cloner
 * @return {T[][]}
 */
export function cloneGrid(
    grid,
    slot_cloner = (slot) => slot,
) {
    return grid.map((row) => row.map((ele) => slot_cloner(ele)));
}

/**
 * @template T
 * @param {T[][]} grid
 * @param {bigint} x
 * @param {bigint} y
 * @return {T | null}
 */
export function getSlot(
    grid,
    x,
    y
) {
    return grid[Number(y)]?.[Number(x)] ?? null;
}

/**
 * @template T
 * @param {T[][]} grid
 * @param {bigint} x
 * @param {bigint} y
 * @param {T} value
 * @return {boolean}
 */
export function setSlot(
    grid,
    x,
    y,
    value
) {
    const row = grid[Number(y)] ?? null;
    if (row === null) {
        return false;
    }
    const x_num = Number(x);
    if (!(x_num in row)) {
        return false;
    }
    row[x_num] = value;
    return true;
}

/**
 * Returns an iterable of [x, y, slot]
 *
 * @template T
 * @param {bigint} grid_width
 * @param {bigint} grid_height
 * @param {T[][]} grid
 * @return {IterableIterator<[bigint, bigint, T]>}
 */
export function* iterateGridSlots(
    grid_width,
    grid_height,
    grid,
) {
    for (let y = 0n; y < grid_height; y++) {
        const row = grid[Number(y)];
        for (let x = 0n; x < grid_width; x++) {
            yield [x, y, row[Number(x)]];
        }
    }
}

/**
 * @param {[bigint, bigint]} lhs
 * @param {[bigint, bigint]} rhs
 * @return {boolean}
 */
export function arePositionsEqual(
    [lhsX, lhsY],
    [rhsX, rhsY]
) {
    return lhsX === rhsX && lhsY === rhsY;
}

export class PositionSet {
    /** @type {[bigint, bigint][]} */
    vectors = [];

    /**
     * @param {[bigint, bigint]} pos
     * @return {boolean}
     */
    add(
        pos
    ) {
        for (const other of this.vectors) {
            if (arePositionsEqual(pos, other)) {
                return false;
            }
        }
        this.vectors.push(pos);
    }
}

/**
 * @template K
 * @template V
 * @param {Map<K, V>} map
 * @param {K} key
 * @param {() => V} fallback
 * @return {V}
 */
export function getOrCreateMapEntry(
    map,
    key,
    fallback
) {
    let value = map.get(key) ?? null;
    if (value === null) {
        value = fallback();
        map.set(key, value);
    }
    return value;
}

/**
 * @param {string} char
 * @return {boolean}
 */
export function isDigit(
    char
) {
    return char.length === 1 && char >= '0' && char <= '9';
}
