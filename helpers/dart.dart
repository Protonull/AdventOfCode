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

extension GridHelpers<T> on Grid<T> {
    Grid<R> transformSlots<R>(
        R transformer(T)
    ) {
        return UnmodifiableListView(
            List.generate(
                this.length,
                (y) {
                    final row = this[y];
                    return List.generate(
                        row.length,
                        (x) => transformer(row[x]),
                        growable: false
                    );
                },
                growable: false
            )
        );
    }

    Grid<T> clone() {
        return transformSlots((slot) => slot);
    }

    Iterable<(Pos, T, void Function(T))> iterateSlots() sync* {
        for (int y = 0; y < this.length; y++) {
            final row = this[y];
            for (int x = 0; x < row.length; x++) {
                yield (
                    (x, y),
                    row[x],
                    (value) => row[x] = value
                );
            }
        }
    }
    
    T? getSlot(
        Pos slot
    ) {
        final (x, y) = slot;
        if (x < 0 || y < 0 || y >= this.length) {
            return null;
        }
        final row = this[y];
        if (x >= row.length) {
            return null;
        }
        return row[x];
    }
    
    void setSlot(
        Pos slot,
        T value
    ) {
        final (x, y) = slot;
        this[y][x] = value;
    }
}

@deprecated
T? getGridSlot<T>(
    Grid<T> grid,
    Pos slot
) {
    return grid.getSlot(slot);
}

@deprecated
void setGridSlot<T>(
    Grid<T> grid,
    Pos slot,
    T value
) {
    grid.setSlot(slot, value);
}

int wrappedModulus(
    int value,
    int max
) {
    if (max < 0) {
       throw "Negative maxes not allowed (for now)";
    }
    if (value >= 0) {
        return value % max;
    }
    while (value < 0) {
        value += max;
    }
    return value;
}
