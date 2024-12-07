// bun run solution.js
const contents = await Bun.file("sample.txt").text();

let result = 0n;

/** @type {[bigint, bigint[]][]} */
const sums = [];

for (const line of contents.split("\n")) {
    const [total_raw, parts_raw] = line.split(":");
    sums.push([
        BigInt(total_raw),
        parts_raw.split(" ").filter((part) => part !== "").map((part) => part.trim()).map((part) => BigInt(part)),
    ]);
}

for (const [total, parts] of sums) {
    let solution = attemptSolution(total, parts[0], parts.slice(1)) ?? 0n;
    if (solution !== total) {
        solution = 0n;
    }
    result += solution;
}

/** @return {bigint|null} */
function attemptSolution(
    /** @type {bigint} */
    total,
    /** @type {bigint} */
    sum,
    /** @type {bigint[]} */
    parts
) {
    const part = parts[0] ?? null;
    if (part === null) {
        if (sum === total) {
            return sum;
        }
        return null;
    }
    const mul_sum = sum * part;
    if (mul_sum <= total) {
        const mul_total = attemptSolution(total, mul_sum, parts.slice(1));
        if (mul_total !== null) {
            return mul_total;
        }
    }
    const add_sum = sum + part;
    if (add_sum <= total) {
        const add_total = attemptSolution(total, add_sum, parts.slice(1));
        if (add_total !== null) {
            return add_total;
        }
    }
    return null;
}

console.log(`Result: ${result}`);
