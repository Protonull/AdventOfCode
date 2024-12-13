// clear && dart run solution.dart
import "dart:io";

import "../../../helpers/dart.dart";

class Machine {
    static int _name = 0;

    int name = ++_name;
    Pos buttonA;
    Pos buttonB;
    Pos prize;

    Machine(
        this.buttonA,
        this.buttonB,
        this.prize
    );

    @override
    String toString() {
        return "Machine-${this.name}{ButtonA: ${this.buttonA}, ButtonB: ${this.buttonB}, Prize: ${this.prize}}";
    }
}

final BUTTON_A_REGEX = RegExp(r"Button A: X([+-]\d+), Y([+-]\d+)");
final BUTTON_B_REGEX = RegExp(r"Button B: X([+-]\d+), Y([+-]\d+)");
final PRIZE_REGEX = RegExp(r"Prize: X=(\d+), Y=(\d+)");

final int BUTTON_A_COST = 3;
final int BUTTON_B_COST = 1;

void main() {
    final machines = File("sample.txt").readAsStringSync()
        .split("\n\n")
        .map((section) {
            final [line1, line2, line3] = section.split("\n");

            final button_a_match = BUTTON_A_REGEX.firstMatch(line1);
            if (button_a_match == null) {
                throw "Could not match Button A input: [${line1}]";
            }

            final button_b_match = BUTTON_B_REGEX.firstMatch(line2);
            if (button_b_match == null) {
                throw "Could not match Button B input: [${line2}]";
            }

            final prize_match = PRIZE_REGEX.firstMatch(line3);
            if (prize_match == null) {
                throw "Could not match Prize input: [${line3}]";
            }

            return Machine(
                (
                    int.parse(button_a_match.group(1)!),
                    int.parse(button_a_match.group(2)!),
                ),
                (
                    int.parse(button_b_match.group(1)!),
                    int.parse(button_b_match.group(2)!),
                ),
                (
                    int.parse(prize_match.group(1)!) + 10_000_000_000_000,
                    int.parse(prize_match.group(2)!) + 10_000_000_000_000,
                )
            );
        })
        .toList(growable: false);

    int result = 0;

    for (final machine in machines) {
        print("Testing machine: ${machine}");

        final cost = findPresses(machine);
        if (cost == null) {
            print(" - No valid answer");
            continue;
        }
        print(" - Costs: ${cost}");
        result += cost;
    }

    print("Result: ${result}");
}

int? findPresses(
    Machine machine
) {
    final (a_x, a_y) = machine.buttonA;
    final (b_x, b_y) = machine.buttonB;
    final (prize_x, prize_y) = machine.prize;

    // a_x * A_COUNT? + b_x * B_COUNT? = prize_x,
    // a_y * A_COUNT? + b_y * B_COUNT? = prize_y

    // Thank you specificlanguage and Gjum for the help here. I haven't done anything close
    // to this in 14 years.
    final int b_count = (prize_y * a_x - prize_x * a_y) ~/ (b_y * a_x - b_x * a_y);
    final int a_count = (prize_x - b_count * b_x) ~/ a_x;
    if (a_count * a_x + b_count * b_x == prize_x && a_count * a_y + b_count * b_y == prize_y) {
        return a_count * BUTTON_A_COST + b_count * BUTTON_B_COST;
    }

    return null;
}
