// clear && dart run solution.dart

import "dart:collection";
import "dart:io";

typedef Pos = (int, int);

enum Direction {
    NORTH,
    EAST,
    SOUTH,
    WEST
}

void main() {
    final List<List<int>> grid = List.unmodifiable(
        File("sample.txt")
            .readAsStringSync()
            .split("\n")
            .map((ele) => ele.split("").map(int.parse).toList(growable: false))
            .toList(growable: false)
    );

    final List<Pos> startingPositions = List.empty(growable: true);
    for (int y = 0; y < grid.length; y++) {
        final row = grid[y];
        for (int x = 0; x < row.length; x++) {
            final slot = row[x];
            if (slot == 0) {
                startingPositions.add((x, y));
            }
        }
    }

    int result = 0;

    for (final startingPosition in startingPositions) {
        final Set<List<Pos>> visited = HashSet();
        final Queue<List<Pos>> queue = Queue();
        queue.add(List.of([startingPosition], growable: true));
        while (queue.isNotEmpty) {
            final currentTrail = queue.removeFirst();
            if (!visited.add(currentTrail)) {
                continue;
            }
            final currentPosition = currentTrail.last;
            final (currentX, currentY) = currentPosition;
            final currentValue = grid[currentY][currentX];
            for (final direction in Direction.values) {
                final neighbour = attemptGetNeighbour(grid, currentPosition, direction);
                if (neighbour == null) {
                    continue;
                }
                final (neighbourValue, neighbourPos) = neighbour;
                if (neighbourValue == (currentValue + 1)) {
                    final newTrail = List.of(currentTrail, growable: true);
                    newTrail.add(neighbourPos);
                    queue.add(newTrail);
                }
            }
        }

        visited.forEach((trail) {
            final (x, y) = trail.last;
            if (grid[y][x] == 9) {
                result += 1;
            }
        });
    }

    print("Result: $result");
}

(int, Pos)? attemptGetNeighbour(
    List<List<int>> grid,
    Pos pos,
    Direction direction
) {
    final (posX, posY) = pos;
    final Pos nextPos = (() {
        switch (direction) {
            case Direction.NORTH: return (posX, posY - 1);
            case Direction.EAST: return (posX + 1, posY);
            case Direction.SOUTH: return (posX, posY + 1);
            case Direction.WEST: return (posX - 1, posY);
        }
    })();
    final (nextX, nextY) = nextPos;
    if (nextX < 0 || nextY < 0 || nextY >= grid.length) {
        return null;
    }
    final row = grid[nextY];
    if (nextX >= row.length) {
        return null;
    }
    return (row[nextX], nextPos);
}
