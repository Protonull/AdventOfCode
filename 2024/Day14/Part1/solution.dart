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
final ROBOT_INPUT = "sample.txt";
// final ROBOT_INPUT = "input.txt";
final GRID_WIDTH = 11;
// final GRID_WIDTH = 101;
final GRID_HEIGHT = 7;
// final GRID_HEIGHT = 103;
final NUM_SECONDS = 100;

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

    for (int second = 0; second < NUM_SECONDS; second++) {
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
    }

    final int half_width = GRID_WIDTH >> 1;
    final int half_height = GRID_HEIGHT >> 1;

    print("Half-width: ${half_width}");
    print("Half-height: ${half_height}");

    final quadrants = List.generate(4, (i) => 0, growable: false);
    for (int y = 0; y < GRID_HEIGHT; y++) {
        for (int x = 0; x < GRID_WIDTH; x++) {
              if (x == half_width || y == half_height) {
                  continue;
              }

              int quadrant = 0;
              if (x > half_width) quadrant += 1;
              if (y > half_height) quadrant += 2;

              final robots = grid[y][x];
              quadrants[quadrant] += robots.length;
        }
    }

    print("After ${NUM_SECONDS} second(s):");
    print(
        grid
            .map((row) => row.map((cell) {
                if (cell.isEmpty) {
                    return ".";
                }
                return "${cell.length}";
            }).join(" "))
            .join("\n")
    );

    print(quadrants);

    final result = quadrants.fold(1, (acc, val) => acc * val);

    print("Result: ${result}");
}
