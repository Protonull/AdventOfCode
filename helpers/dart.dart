import "dart:collection";

typedef Grid<T> = UnmodifiableListView<List<T>>;
typedef Pos = (int, int);

extension GridParsing on String {
    Grid<String> asGrid(
        [String separator = ""]
    ) {
        return UnmodifiableListView(
            this.split("\n")
                .map((ele) => ele.split(separator).toList(growable: false))
                .toList(growable: false)
        );
    }
}

extension GridUtils on Grid {
    Grid<R> transformSlots<T, R>(
        R transformer(T)
    ) {
        final grid = this as Grid<T>;
        return UnmodifiableListView(
            List.generate(this.length, (y) {
                final old_row = grid[y];
                return List.generate(old_row.length, (x) {
                    final old_slot = old_row[x];
                    return transformer(old_slot);
                }, growable: false);
            }, growable: false)
        );
    }

    Iterable<(Pos, T, void Function(T))> iterateSlots<T>() sync* {
        final grid = this as Grid<T>;
        for (int y = 0; y < grid.length; y++) {
            final row = grid[y];
            for (int x = 0; x < row.length; x++) {
                yield (
                    (x, y),
                    row[x],
                    (value) => row[x] = value
                );
            }
        }
    }
}

T? getGridSlot<T>(
    Grid<T> grid,
    Pos slot
) {
    final (x, y) = slot;
    if (x < 0 || y < 0 || y >= grid.length) {
        return null;
    }
    final row = grid[y];
    if (x >= row.length) {
        return null;
    }
    return row[x];
}

void setGridSlot<T>(
    Grid<T> grid,
    Pos slot,
    T value
) {
    final (x, y) = slot;
    grid[y][x] = value;
}
