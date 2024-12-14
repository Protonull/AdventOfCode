// clear && dart run solution.dart
import "dart:collection";
import "dart:io";

import "../../../helpers/dart.dart";

class Robot {
    static int _name = 0;

    final int name = ++_name;
    final Pos velocity;
    int lastUpdatedOn = -1;

    Robot(
        this.velocity
    );

    @override
    String toString() {
        return "${this.name}";
    }
}

final ROBOT_REGEX = RegExp(r"p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)");
final ROBOT_INPUT = "input.txt";
final GRID_WIDTH = 101;
final GRID_HEIGHT = 103;
final NUM_SECONDS = 10_000;

final FILE_OUTPUT = File("output.txt");

void main() {
    final Grid<Set<Robot>> grid = UnmodifiableListView(
        List.generate(
            GRID_HEIGHT,
            (y) {
                return List.generate(
                    GRID_WIDTH,
                    (x) => HashSet(),
                    growable: false
                );
            },
            growable: false
        )
    );

    File(ROBOT_INPUT).readAsStringSync()
        .split("\n")
        .forEach((line) {
            final robot_match = ROBOT_REGEX.firstMatch(line);
            if (robot_match == null) {
                throw "Could not match robot input: [${line}]";
            }
            final Pos robot_pos = (
                int.parse(robot_match.group(1)!),
                int.parse(robot_match.group(2)!)
            );
            final slot = grid.getSlot(robot_pos);
            if (slot == null) {
                throw "Robot pos ${robot_pos} does not exist!";
            }
            final robot = Robot(
                (
                    int.parse(robot_match.group(3)!),
                    int.parse(robot_match.group(4)!)
                ),
            );
            slot.add(robot);
            print("Robot-${robot.name}{Pos: ${robot_pos}, Vel: ${robot.velocity}");
        });

    if (!FILE_OUTPUT.existsSync()) {
        FILE_OUTPUT.createSync();
    }

    second_loop: for (int second = 0; second < NUM_SECONDS; second++) {
        for (int y = 0; y < GRID_HEIGHT; y++) {
            for (int x = 0; x < GRID_WIDTH; x++) {
                final robots = grid[y][x];
                final robots_copy = HashSet.of(robots);
                robots.clear();
                for (final robot in robots_copy) {
                    if (second <= robot.lastUpdatedOn) {
                        robots.add(robot);
                        continue;
                    }
                  
                    final (vel_x, vel_y) = robot.velocity;

                    final next_x = wrappedModulus(x + vel_x, GRID_WIDTH);
                    final next_y = wrappedModulus(y + vel_y, GRID_HEIGHT);

                    final next_slot = grid.getSlot((next_x, next_y));
                    if (next_slot == null) {
                        throw "Next slot $next_slot does not exist!";
                    }

                    robot.lastUpdatedOn = second;
                    next_slot.add(robot);
                }
            }
        }

        for (int y = 0; y < GRID_HEIGHT; y++) {
            for (int x = 0; x < GRID_WIDTH; x++) {
                if (findBox(grid, (x, y))) {
                    FILE_OUTPUT.writeAsStringSync(
                        "After ${second + 1} second(s):\n" + grid.map((row) => row.map((cell) => cell.isEmpty ? "." : "${cell.length}").join("")).join("\n") + "\n",
                        mode: FileMode.append
                    );
                    continue second_loop;
                }
            }
        }
    }
}

bool findBox(
    Grid<Set<Robot>> grid,
    Pos origin
) {
    final (x, y) = origin;
    return grid[y][x].isNotEmpty
        && (grid.getSlot((x + 1, y))?.isNotEmpty ?? false)
        && (grid.getSlot((x + 2, y))?.isNotEmpty ?? false)
        && (grid.getSlot((x + 3, y))?.isNotEmpty ?? false)
        && (grid.getSlot((x + 4, y))?.isNotEmpty ?? false)
        && (grid.getSlot((x + 5, y))?.isNotEmpty ?? false)
        && (grid.getSlot((x + 6, y))?.isNotEmpty ?? false)
        && (grid.getSlot((x, y + 1))?.isNotEmpty ?? false)
        && (grid.getSlot((x, y + 2))?.isNotEmpty ?? false)
        && (grid.getSlot((x, y + 3))?.isNotEmpty ?? false)
        && (grid.getSlot((x, y + 4))?.isNotEmpty ?? false)
        && (grid.getSlot((x, y + 5))?.isNotEmpty ?? false)
        && (grid.getSlot((x, y + 6))?.isNotEmpty ?? false);
}
