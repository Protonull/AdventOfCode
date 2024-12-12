// clear && dart run solution.dart
import "dart:collection";
import "dart:io";

import "../../../helpers/dart.dart";

class Region {
    String type;
    Set<Pos> plots = HashSet();

    Region(
        this.type
    );

    @override
    String toString() {
        return "Region{type:${this.type}, plots:${this.plots}}";
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
                if (region.plots.contains(pos)) {
                    continue cell_loop;
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
        final int sides = countSides(region.plots.toList(growable: false));
        print("Side [${region.type}]: ${area} * ${sides}");

        result += area * sides;
    }

    print("Result: ${result}");
}

void expandSearch(
    Grid<String> grid,
    Set<Pos> region,
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

    // North slot
    final north_pos = (x, y - 1);
    if (getGridSlot(grid, north_pos) == type) {
        expandSearch(grid, region, visited, north_pos, type);
    }
    // East slot
    final east_pos = (x + 1, y);
    if (getGridSlot(grid, east_pos) == type) {
        expandSearch(grid, region, visited, east_pos, type);
    }
    // South slot
    final south_pos = (x, y + 1);
    if (getGridSlot(grid, (x, y + 1)) == type) {
        expandSearch(grid, region, visited, south_pos, type);
    }
    // West slot
    final west_pos = (x - 1, y);
    if (getGridSlot(grid, west_pos) == type) {
        expandSearch(grid, region, visited, west_pos, type);
    }

    region.add(pos);
}

int countSides(
    List<Pos> plots
) {
    int corners = 0;
    for (final plot in plots) {
        final (plotX, plotY) = plot;

        final bool is_u_empty = !plots.contains((plotX, plotY - 1));
        final bool is_ur_empty = !plots.contains((plotX + 1, plotY - 1));
        final bool is_r_empty = !plots.contains((plotX + 1, plotY));
        final bool is_rd_empty = !plots.contains((plotX + 1, plotY + 1));
        final bool is_d_empty = !plots.contains((plotX, plotY + 1));
        final bool is_dl_empty = !plots.contains((plotX - 1, plotY + 1));
        final bool is_l_empty = !plots.contains((plotX - 1, plotY));
        final bool is_lu_empty = !plots.contains((plotX - 1, plotY - 1));

        if (is_u_empty && is_r_empty) {
            corners += 1;
        }
        else if (!is_u_empty && !is_r_empty && is_ur_empty) {
            corners += 1;
        }

        if (is_r_empty && is_d_empty) {
            corners += 1;
        }
        else if (!is_r_empty && !is_d_empty && is_rd_empty) {
            corners += 1;
        }

        if (is_d_empty && is_l_empty) {
            corners += 1;
        }
        else if (!is_d_empty && !is_l_empty && is_dl_empty) {
            corners += 1;
        }

        if (is_l_empty && is_u_empty) {
            corners += 1;
        }
        else if (!is_l_empty && !is_u_empty && is_lu_empty) {
            corners += 1;
        }
    }
    return corners;
}
