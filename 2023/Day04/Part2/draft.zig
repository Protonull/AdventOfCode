// zig run solution.zig

const std = @import("std");
const stdout = std.io.getStdOut().writer();
const input = @embedFile("sample.txt");

const Card = struct {
    id: u8,
    matches: u8
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var finalResult: u32 = 0;

    var lineIterator = std.mem.splitSequence(u8, input, "\n");
    while (lineIterator.next()) |line| {
        try stdout.print("============================\n", .{});

        const colonIndex = std.mem.indexOfScalar(u8, line, ':').?;
        const pipeIndex = std.mem.indexOfScalar(u8, line, '|').?;

        const cardId: u8 = @truncate(parseStringifiedNumber(line["Card".len..colonIndex]).?);
        try stdout.print("Card id: {d}\n", .{cardId});

        var winningNumbers = std.ArrayList(u8).init(allocator); {
            var splitNumbersIterator = std.mem.splitSequence(u8, line[(colonIndex + 2)..(pipeIndex - 1)], " ");
            while (splitNumbersIterator.next()) |splitNumber| {
                try winningNumbers.append(@truncate(parseStringifiedNumber(splitNumber) orelse continue));
            }
        }
        try stdout.print("Winning numbers: {any}\n", .{winningNumbers.items});

        var cardNumbers = std.ArrayList(u8).init(allocator); {
            var splitNumbersIterator = std.mem.splitSequence(u8, line[(pipeIndex + 2)..], " ");
            while (splitNumbersIterator.next()) |splitNumber| {
                try cardNumbers.append(@truncate(parseStringifiedNumber(splitNumber) orelse continue));
            }
        }
        try stdout.print("Card numbers: {any}\n", .{cardNumbers.items});

        var numberOfMatchingNumbers: u8 = 0;
        for (cardNumbers.items) |cardNumber| {
            for (winningNumbers.items) |winningNumber| {
                if (cardNumber == winningNumber) {
                    numberOfMatchingNumbers += 1;
                    break;
                }
            }
        }
        try stdout.print("Matches: {d}\n", .{numberOfMatchingNumbers});




    }

    try stdout.print("============================\n", .{});
    try stdout.print("Result: {d}\n", .{finalResult});
}

fn isNumeric(
    char: u8
) bool {
    return char >= '0' and char <= '9';
}

fn parseStringifiedNumber(
    raw: []const u8
) ?u32 {
    var result: ?u32 = null;
    for (raw) |char| {
        if (isNumeric(char)) {
            if (result == null) {
                result = char - '0';
            }
            else {
                result.? *= 10;
                result.? += char - '0';
            }
        }
    }
    return result;
}
