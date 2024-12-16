// clear && dart run solution.dart
// @formatter:off
import "dart:io";

import "../../../helpers/dart.dart";

enum Cell {
    WALL,
    EMPTY,
    ROBOT,
    BOX
}

enum Move {
    NORTH((0, -1)),
    EAST((1, 0)),
    SOUTH((0, 1)),
    WEST((-1, 0));

    const Move(
        this.vector
    );

    final Pos vector;
}

void main() {
    final (grid, moves) = (){
        final [grid_section, moves_section] = File("sample.txt").readAsStringSync().split("\n\n");
        return (
            grid_section.asGrid().transformSlots((slot) => switch (slot) {
                "#" => Cell.WALL,
                "." => Cell.EMPTY,
                "@" => Cell.ROBOT,
                "O" => Cell.BOX,
                _ => throw "Unknown cell type [${slot}]!"
            }),
            moves_section.replaceAll("\n", "").split("").map((move) => switch (move) {
                "^" => Move.NORTH,
                ">" => Move.EAST,
                "v" => Move.SOUTH,
                "<" => Move.WEST,
                _ => throw "Unknown cell type [${move}]!"
            }).toList(growable: false)
        );
    }();

    Pos robotPos = grid.findFirst((cell) => cell == Cell.ROBOT) ?? (){
        throw "Could not find robot!";
    }();

    printGrid(grid);

    for (final move in moves) {
        if (attemptMove(grid, robotPos, move) case Pos nextPos) {
            robotPos = nextPos;
        }
        //printGrid(grid);
    }

    int result = 0;
    
    for (int y = 0; y < grid.length; y++) {
        final row = grid[y];
        for (int x = 0; x < row.length; x++) {
            final cell = row[x];

            if (cell == Cell.BOX) {
                result += 100 * y + x;
            }
        }
    }
    
    print("Result: ${result}");
}

Pos? attemptMove(
    Grid<Cell> grid,
    Pos currentPos,
    Move move
) {
    Pos nextPos = currentPos.add(move.vector);

    Cell nextCell = grid.getSlot(nextPos)!;

    if (nextCell == Cell.WALL) {
        return null; // Do not move
    }

    if (nextCell == Cell.ROBOT) {
        throw "There's another robot?! [${currentPos}, ${nextPos}]";
    }

    if (nextCell == Cell.EMPTY) {
        grid.setSlot(currentPos, Cell.EMPTY);
        grid.setSlot(nextPos, Cell.ROBOT);
        return nextPos; // Move
    }

    int boxCount = 1;
    while (true) {
        nextPos = nextPos.add(move.vector);
        nextCell = grid.getSlot(nextPos)!;

        if (nextCell == Cell.WALL) {
            return null; // Do not move
        }

        if (nextCell == Cell.ROBOT) {
            throw "There's another robot?! [${currentPos}, ${nextPos}]";
        }

        if (nextCell == Cell.EMPTY) {
            break;
        }

        boxCount += 1;
    }

    grid.setSlot(currentPos, Cell.EMPTY);
    nextPos = currentPos.add(move.vector);
    grid.setSlot(nextPos, Cell.ROBOT);

    for (int i = 0; i < boxCount; i++) {
        nextPos = nextPos.add(move.vector);
        grid.setSlot(nextPos, Cell.BOX);
    }

    return currentPos.add(move.vector);
}

void printGrid(
    Grid<Cell> grid,
) {
    print(
        grid.map((row) => row.map((cell) => switch (cell) {
            Cell.WALL => "#",
            Cell.EMPTY => ".",
            Cell.ROBOT => "@",
            Cell.BOX => "O"
        }).join("")).join("\n")
    );
    print(" ");
}
