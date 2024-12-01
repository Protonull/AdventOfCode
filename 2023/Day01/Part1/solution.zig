// zig run solution.zig

const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    const contents = @embedFile("sample.txt");

    var finalResult: u16 = 0;

    var iterator = std.mem.splitSequence(u8, contents, "\n");
    while (iterator.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var parts = [_]u8{ '0' } ** 2;

        for (line) |char| {
            if (char > '0' and char <= '9') {
                if (parts[0] == '0') {
                    parts[0] = char;
                }
                parts[1] = char;
            }
        }

        const result = try std.fmt.parseInt(u8, &parts, 10);

        finalResult += result;
    }

    try stdout.print("Result: {d}\n", .{finalResult});
}
