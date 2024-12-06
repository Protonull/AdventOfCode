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

const PLAYER_DIRECTION_N = 0n;
const PLAYER_DIRECTION_E = 1n;
const PLAYER_DIRECTION_S = 2n;
const PLAYER_DIRECTION_W = 3n;

/** @type {bigint[]} */
let [playerX, playerY, playerDirection] = (function(){
    for (let y = 0; y < grid.length; y++) {
        const line = grid[y];
        for (let x = 0; x < grid_width; x++) {
            switch (line[x]) {
                case "^":
                    return [x, y, PLAYER_DIRECTION_N];
                case ">":
                    return [x, y, PLAYER_DIRECTION_E];
                case "v":
                    return [x, y, PLAYER_DIRECTION_S];
                case "<":
                    return [x, y, PLAYER_DIRECTION_W];
            }
        }
    }
    throw "Could not find player position!";
})();

const [originalX, originalY, originalDirection] = [playerX, playerY, playerDirection];

function getSlot(x, y) {
    return (grid[y] ?? [])[x] ?? null;
}

function setSlot(x, y, value) {
    (grid[y] ?? [])[x] = value;
}

function printPlayer(x, y) {
    switch (playerDirection) {
        case PLAYER_DIRECTION_N:
            setSlot(x, y, "^");
            break;
        case PLAYER_DIRECTION_E:
            setSlot(x, y, ">");
            break;
        case PLAYER_DIRECTION_S:
            setSlot(x, y, "v");
            break;
        case PLAYER_DIRECTION_W:
            setSlot(x, y, "<");
            break;
        default:
            throw `INVALID DIRECTION [${playerDirection}]`;
    }
}

const GAME_RESULT_VOID = 0n;
const GAME_RESULT_LOOP = 1n;

function resetGame() {
    for (const row of grid) {
        row.forEach((v, i, a) => {
            switch (v) {
                case "X":
                case "O":
                case "^":
                case ">":
                case "v":
                case "<":
                    a[i] = ".";
                    break;
            }
        });
    }
}

function playGame(obstacleX, obstacleY) {
    playerX = originalX;
    playerY = originalY;
    playerDirection = originalDirection;
    printPlayer(playerX, playerY);

    setSlot(obstacleX, obstacleY, "O");

    /** @type {bigint[][]} */
    const corner_history = [];
    function rememberCorner(x, y, direction) {
        for (const [existingX, existingY, existingDirection] of corner_history) {
            if (x === existingX && y === existingY && direction === existingDirection) {
                return true;
            }
        }
        corner_history.push([x, y, direction]);
        return false;
    }

    do {
        const [nextX, nextY] = (function(){
            switch (playerDirection) {
                case PLAYER_DIRECTION_N:
                    return [playerX, playerY - 1];
                case PLAYER_DIRECTION_E:
                    return [playerX + 1, playerY];
                case PLAYER_DIRECTION_S:
                    return [playerX, playerY + 1];
                case PLAYER_DIRECTION_W:
                    return [playerX - 1, playerY];
            }
            throw `INVALID DIRECTION [${playerDirection}]`;
        })();
        const slot = getSlot(nextX, nextY);
        if (slot === "#" || slot === "O") {
            switch (playerDirection) {
                case PLAYER_DIRECTION_N:
                    playerDirection = PLAYER_DIRECTION_E;
                    break;
                case PLAYER_DIRECTION_E:
                    playerDirection = PLAYER_DIRECTION_S;
                    break;
                case PLAYER_DIRECTION_S:
                    playerDirection = PLAYER_DIRECTION_W;
                    break;
                case PLAYER_DIRECTION_W:
                    playerDirection = PLAYER_DIRECTION_N;
                    break;
                default:
                    throw `INVALID DIRECTION [${playerDirection}]`;
            }
            if (rememberCorner(nextX, nextY, playerDirection) === true) {
                return GAME_RESULT_LOOP;
            }
            continue;
        }
        setSlot(playerX, playerY, "X");
        playerX = nextX;
        playerY = nextY;
        printPlayer(playerX, playerY);

        // console.log("=".repeat(Number(grid_width)));
        // console.log(grid.map((line) => line.join("")).join("\n"));
    }
    while(playerY >= 0 && playerY < grid.length && playerX >= 0 && playerX < grid_width);
    return GAME_RESULT_VOID;
}

let result = 0n;

for (let y = 0; y < grid.length; y++) {
    for (let x = 0; x < grid_width; x++) {
        resetGame();
        const slot = getSlot(x, y);
        if (slot === ".") {
            if (playGame(x, y) === GAME_RESULT_LOOP) {
                result += 1n;
            }
        }
    }
}

console.log(`Result: ${result}`);
