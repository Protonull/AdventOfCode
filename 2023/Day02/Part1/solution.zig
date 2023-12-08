// zig run solution.zig

const std = @import("std");
const stdout = std.io.getStdOut().writer();

const MAXIMUM_AMOUNTS = std.ComptimeStringMap(u8, .{
    .{ "red", 12 },
    .{ "green", 13 },
    .{ "blue", 14 }
});

const GAME_PREFIX = "Game ";

const Retrieved = struct {
    colour: []const u8,
    amount: u8
};

pub fn main() !void {
    const contents = @embedFile("input.txt");
    var finalResult: u16 = 0;

    var iterator = std.mem.splitSequence(u8, contents, "\n");
    gameIterator: while (iterator.next()) |line| {
        const boilerplate: [2][]const u8 = brk: {
            var gameSplit = std.mem.splitSequence(u8, line, ": ");
            break :brk .{
                gameSplit.next().?,
                gameSplit.next().?
            };
        };

        const gameNumber: u8 = try std.fmt.parseInt(u8, boilerplate[0][GAME_PREFIX.len..], 10);
        try stdout.print("Game number: {d}\n", .{gameNumber});

        var pullIterator = std.mem.splitSequence(u8, boilerplate[1], "; ");
        while (pullIterator.next()) |pullSegment| {

            var retrievedIterator = std.mem.splitSequence(u8, pullSegment, ", ");
            while (retrievedIterator.next()) |retrieved| {

                const colour: Retrieved = brk: {
                    var retrievedSplit = std.mem.splitSequence(u8, retrieved, " ");
                    break :brk .{
                        .amount = try std.fmt.parseInt(u8, retrievedSplit.next().?, 10),
                        .colour = retrievedSplit.next().?
                    };
                };

                const maxAllowed = MAXIMUM_AMOUNTS.get(colour.colour).?;
                if (colour.amount > maxAllowed) {
                    continue :gameIterator;
                }
            }
        }

        finalResult += gameNumber;
    }

    try stdout.print("Result: {d}\n", .{finalResult});
}
