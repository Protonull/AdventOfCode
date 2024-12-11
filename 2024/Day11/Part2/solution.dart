// clear && dart run solution.dart

import "dart:collection";
import "dart:io";
import "dart:math";

void main() {
    final Map<int, int> stones = HashMap.fromEntries(File("sample.txt").readAsStringSync().split(" ").map((stone) => MapEntry(int.parse(stone), 1)));

    for (int i = 0; i < 75; i++) {
        print("Done: $i");
        blink(stones);
        stones.removeWhere((key, value) => value <= 0);
    }

    print("Result: ${stones.values.fold(0, (acc, val) => acc + val)}");
}

void blink(
    Map<int, int> stones
) {
    for (final entry in HashMap.of(stones).entries) {
        removeStone(stones, entry.key, entry.value);
        if (entry.key == 0) {
            touchStone(stones, 1, entry.value);
            continue;
        }
        final entry_string = entry.key.toString();
        if (entry_string.length.isEven) {
            final half_length = entry_string.length >> 1;
            touchStone(stones, int.parse(entry_string.substring(0, half_length)), entry.value);
            touchStone(stones, int.parse(entry_string.substring(half_length)), entry.value);
            continue;
        }
        touchStone(stones, entry.key * 2024, entry.value);
    }
}

void touchStone(
    Map<int, int> stones,
    int stone,
    int by
) {
    stones.update(stone, (val) => val + by, ifAbsent: () => by);
}

void removeStone(
    Map<int, int> stones,
    int stone,
    int by
) {
    stones.update(stone, (val) => max(val - by, 0));
}
