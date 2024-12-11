// clear && dart run solution.dart

import "dart:io";

void main() {
    final stones = File("sample.txt").readAsStringSync().split(" ").map(int.parse).toList(growable: true);

    for (int i = 0; i < 25; i++) {
        blink(stones);
    }

    print("Result: ${stones.length}");
}

void blink(
    List<int> stones
) {
    int i = 0;
    while (i < stones.length) {
        final stone = stones[i];
        if (stone == 0) {
            stones[i] = 1;
            i += 1;
            continue;
        }
        final stone_string = stone.toString();
        if (stone_string.length.isEven) {
            final lhs = stone_string.substring(0, (stone_string.length / 2).floor());
            final rhs = stone_string.substring((stone_string.length / 2).floor());
            stones[i] = int.parse(lhs);
            stones.insert(i + 1, int.parse(rhs));
            i += 2;
            continue;
        }
        stones[i] *= 2024;
        i += 1;
        continue;
    }
}

