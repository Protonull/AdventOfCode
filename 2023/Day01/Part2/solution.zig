// zig run solution.zig

const std = @import("std");
const stdout = std.io.getStdOut().writer();

const VALID_NUMBERS = std.ComptimeStringMap(u8, .{
    .{ "1", '1' },
    .{ "2", '2' },
    .{ "3", '3' },
    .{ "4", '4' },
    .{ "5", '5' },
    .{ "6", '6' },
    .{ "7", '7' },
    .{ "8", '8' },
    .{ "9", '9' },
    .{ "one", '1' },
    .{ "two", '2' },
    .{ "three", '3' },
    .{ "four", '4' },
    .{ "five", '5' },
    .{ "six", '6' },
    .{ "seven", '7' },
    .{ "eight", '8' },
    .{ "nine", '9' },
});

pub fn main() !void {
    const contents = @embedFile("sample.txt");

    var finalResult: u16 = 0;

    var iterator = std.mem.splitSequence(u8, contents, "\n");
    while (iterator.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var parts = [_]u8{ '0' } ** 2;

        for (0..line.len) |index| {
            for (VALID_NUMBERS.kvs) |entry| {
                // If the number is too long, ignore it
                if (entry.key.len + index > line.len) {
                    continue;
                }

                const lineSlice = line[index..(index + entry.key.len)];
                if (!std.mem.eql(u8, entry.key, lineSlice)) {
                    continue;
                }

                if (parts[0] == '0') {
                    parts[0] = entry.value;
                }
                parts[1] = entry.value;
            }
        }

        const result = try std.fmt.parseInt(u8, &parts, 10);

        try stdout.print("Line-result: {s} {d}\n", .{line, result});

        finalResult += result;
    }

    try stdout.print("Result: {d}\n", .{finalResult});
}
