// zig run solution.zig

const std = @import("std");
const stdout = std.io.getStdOut().writer();

const Retrieved = struct {
    colour: []const u8,
    amount: u8
};

pub fn main() !void {
    const contents = @embedFile("input.txt");
    var finalResult: u32 = 0;

    var iterator = std.mem.splitSequence(u8, contents, "\n");
    while (iterator.next()) |line| {
        const colonIndex = std.mem.indexOfScalar(u8, line, ':').?;

        const gameNumber: u8 = try std.fmt.parseInt(u8, line["Game ".len..colonIndex], 10);
        try stdout.print("Game number: {d}\n", .{gameNumber});

        var maxRed: u32 = 0;
        var maxGreen: u32 = 0;
        var maxBlue: u32 = 0;

        var pullIterator = std.mem.splitSequence(u8, line[(colonIndex+2)..], "; ");
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

                if (std.mem.eql(u8, colour.colour, "red")) {
                    maxRed = @max(maxRed, colour.amount);
                }
                else if (std.mem.eql(u8, colour.colour, "green")) {
                    maxGreen = @max(maxGreen, colour.amount);
                }
                else if (std.mem.eql(u8, colour.colour, "blue")) {
                    maxBlue = @max(maxBlue, colour.amount);
                }
            }
        }

        finalResult += maxRed * maxGreen * maxBlue;
    }

    try stdout.print("Result: {d}\n", .{finalResult});
}
