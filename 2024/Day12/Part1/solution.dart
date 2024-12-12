// clear && dart run solution.dart
import "dart:collection";
import "dart:io";

import "../../../helpers/dart.dart";

class Region {
    String type;
    Set<Plot> plots = HashSet();

    Region(
        this.type
    );

    @override
    String toString() {
        return "Region{type:${this.type}, plots:${this.plots}}";
    }
}

class Plot {
    Pos pos;
    int fences;

    Plot(
        this.pos,
        this.fences
    );

    @override
    String toString() {
        return "Plot{pos:${this.pos}, fences:${this.fences}}";
    }
}

void main() {
    final Grid<String> grid = File("sample.txt").readAsStringSync().asGrid();

    final List<Region> regions = [];
    
    for (int y = 0; y < grid.length; y++) {
        final row = grid[y];
        cell_loop: for (int x = 0; x < row.length; x++) {
            final cell = row[x];
            final pos = (x, y);

            // Do not start region-searching if this slot is already
            // part of a region
            for (final region in regions) {
                if (region.type != cell) {
                    continue;
                }
                for (final plot in region.plots) {
                    if (plot.pos == pos) {
                        continue cell_loop;
                    }
                }
            }

            final region = Region(cell);
            final Set<Pos> visited = HashSet();
            expandSearch(grid, region.plots, visited, pos, cell);

            regions.add(region);
            print("Found region: ${region}");
        }
    }

    int result = 0;

    for (final region in regions) {
        final int area = region.plots.length;
        final int fences = region.plots.fold(0, (acc, ele) => acc + ele.fences);
        result += area * fences;
    }

    print("Result: ${result}");
}

void expandSearch(
    Grid<String> grid,
    Set<Plot> region,
    Set<Pos> visited,
    Pos pos,
    String type
) {
    final (x, y) = pos;

    if (!visited.add(pos)) {
        return;
    }

    final slot = grid[y][x];
    if (slot != type) {
        return;
    }

    int fences = 4;
    // North slot
    final north_pos = (x, y - 1);
    if (getGridSlot(grid, north_pos) == type) {
        fences -= 1;
        expandSearch(grid, region, visited, north_pos, type);
    }
    // East slot
    final east_pos = (x + 1, y);
    if (getGridSlot(grid, east_pos) == type) {
        fences -= 1;
        expandSearch(grid, region, visited, east_pos, type);
    }
    // South slot
    final south_pos = (x, y + 1);
    if (getGridSlot(grid, (x, y + 1)) == type) {
        fences -= 1;
        expandSearch(grid, region, visited, south_pos, type);
    }
    // West slot
    final west_pos = (x - 1, y);
    if (getGridSlot(grid, west_pos) == type) {
        fences -= 1;
        expandSearch(grid, region, visited, west_pos, type);
    }

    region.add(Plot(pos, fences));
}
