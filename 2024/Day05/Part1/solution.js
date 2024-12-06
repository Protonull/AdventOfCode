// bun run solution.js
const contents = await Bun.file("sample.txt").text();

const [first_half, second_half] = contents.split("\n\n").map((half) => half.split("\n"));

/** @type {Map<bigint, Set<bigint>>} */
const pages = new Map();

for (const page_line of first_half) {
    const [page, before] = page_line.split("|").map((raw) => BigInt(raw));
    let befores = pages.get(page);
    if ((befores ?? null) === null) {
        pages.set(page, befores = new Set());
    }
    befores.add(before);
    if (!pages.has(before)) {
        pages.set(before, new Set());
    }
}

const result = second_half
    .map((test) => test.split(",").map((raw) => BigInt(raw)))
    .filter((test) => {
        for (let i = 0; i < test.length; i++) {
            const previous = test.slice(0, i);
            const befores = pages.get(test[i]);
            if ((befores ?? null) === null) {
                console.log("nothing found for", test[i]);
                return false;
            }
            for (const before of befores) {
                if (previous.includes(before)) {
                    return false;
                }
            }
        }
        return true;
    })
    .map((test) => test[Math.floor(test.length / 2)])
    .reduce((acc, curr) => acc + curr, 0n);

console.log(`Result: ${result}`);