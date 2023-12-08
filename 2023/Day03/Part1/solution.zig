// zig run solution.zig

const std = @import("std");
const stdout = std.io.getStdOut().writer();

const PartNumber = struct {
    lineY: i16,
    startX: i16,
    length: u8,
    value: u32,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const contents = @embedFile("input.txt");
    var finalResult: u32 = 0;

    var partNumbers = std.ArrayList(PartNumber).init(allocator);
    var currentPartNumber: ?PartNumber = null;
    var lineY: i16 = 0;

    var lineIterator = std.mem.splitSequence(u8, contents, "\n");

    // Iterate through to get all the numbers
    while (lineIterator.next()) |line| {
        lineY += 1;

        if (line.len == 0) {
            continue;
        }

        for (line, 0..) |char, charX| {
            if (isNumeric(char)) {
                if (currentPartNumber == null) {
                    currentPartNumber = .{
                        .lineY = lineY,
                        .startX = @intCast(charX),
                        .length = 0,
                        .value = char - '0'
                    };
                }
                else {
                    currentPartNumber.?.value *= 10;
                    currentPartNumber.?.value += char - '0';
                    currentPartNumber.?.length += 1;
                }
                continue;
            }
            // Character is not numeric, so end any number parsing
            if (currentPartNumber != null) {
                try partNumbers.append(currentPartNumber.?);
                currentPartNumber = null;
            }
        }
        // Just in case
        if (currentPartNumber != null) {
            try partNumbers.append(currentPartNumber.?);
            currentPartNumber = null;
        }
    }

    //try stdout.print("Part numbers: {}\n", .{partNumbers});

    lineIterator.reset();
    lineY = 0;

    // Now that we've got all the numbers
    while (lineIterator.next()) |line| {
        lineY += 1;

        if (line.len == 0) {
            continue;
        }

        for (line, 0..) |char, charX| {
            if (isNumeric(char) or char == '.') {
                continue;
            }

            for (partNumbers.items) |partNumber| {
                // Skip if number is higher than one line above
                if (partNumber.lineY < lineY - 1) {
                    continue;
                }
                // Skip if number is lower than one line below
                if (partNumber.lineY > lineY + 1) {
                    continue;
                }

                // Skip if number is too far to the right
                if (partNumber.startX >= charX) {
                    if (partNumber.startX > charX + 1) {
                        continue;
                    }
                }
                // Skip if number is too far to the left
                else {
                    if (partNumber.startX + partNumber.length < charX - 1) {
                        continue;
                    }
                }

                try stdout.print("Symbol \"{c}\" at {d},{d} is adding {d}\n", .{
                    char, charX, lineY, partNumber.value
                });

                finalResult += @intCast(partNumber.value);
            }
        }
    }

    try stdout.print("Result: {d}\n", .{finalResult});
}

fn isNumeric(
    char: u8
) bool {
    return char >= '0' and char <= '9';
}
