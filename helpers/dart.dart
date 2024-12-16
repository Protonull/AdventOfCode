import "dart:collection";

typedef Grid<T> = UnmodifiableListView<List<T>>;

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
        R transformer(T slot)
    ) {
        return UnmodifiableListView(
            this.map((row) => row.map(transformer).toList(growable: false))
                .toList(growable: false)
        );
    }

    Grid<T> clone() {
        return transformSlots((slot) => slot);
    }

    Iterable<(Pos, T, void Function(T value))> iterateSlots() sync* {
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
    
    Pos? findFirst(
        bool tester(T slot)
    ) {
        for (int y = 0; y < this.length; y++) {
            final row = this[y];
            for (int x = 0; x < row.length; x++) {
                final cell = row[x];
                if (tester(cell)) {
                    return (x, y);
                }
            }
        }
        return null;
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

typedef Pos = (int, int);
extension PosHelpers on Pos {
    Pos add(
        Pos other
    ) {
        final (thisX, thisY) = this;
        final (otherX, otherY) = other;
        return (
            thisX + otherX,
            thisY + otherY
        );
    }

    Pos subtract(
        Pos other
    ) {
        final (thisX, thisY) = this;
        final (otherX, otherY) = other;
        return (
            thisX - otherX,
            thisY - otherY
        );
    }

    Pos multiply(
        int by
    ) {
        final (thisX, thisY) = this;
        return (
            thisX * by,
            thisY * by
        );
    }
}

extension ListHelpers<T> on List<T> {
    UnmodifiableListView<T> asUnmodifiableListView() {
        return UnmodifiableListView(this);
    }
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
