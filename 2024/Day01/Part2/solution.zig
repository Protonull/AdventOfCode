// zig run solution.zig

const std = @import("std");

const logger = std.log.scoped(.default);

const Pairs = struct {
    lhs: std.ArrayListUnmanaged(i32) = .{},
    rhs: std.ArrayListUnmanaged(i32) = .{},
    count: usize = 0
};

pub fn main() !void {
    const contents = @embedFile("sample.txt");

    var solution_area = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = solution_area.allocator();

    var pairs: Pairs = .{};

    var line_iterator = std.mem.splitSequence(u8, contents, "\n");
    while (line_iterator.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        const lhs_raw: []const u8, const rhs_raw: []const u8 = brk: {
            // Doing this makes the code extremely brittle to incorrectly formatted inputs, but I couldn't find a regex
            // library to do this in a reasonable time. Better to have something that works.
            var pair_iterator = std.mem.splitSequence(u8, line, "   ");
            break :brk .{
                pair_iterator.next() orelse @panic("Could not find LHS"),
                pair_iterator.next() orelse @panic("Could not find RHS")
            };
        };

        try pairs.lhs.append(allocator, std.fmt.parseInt(i32, lhs_raw, 10) catch |err| {
            logger.warn("Could not parse lhs [{s}]", .{ lhs_raw });
            return err;
        });
        try pairs.rhs.append(allocator, std.fmt.parseInt(i32, rhs_raw, 10) catch |err| {
            logger.warn("Could not parse rhs [{s}]", .{ rhs_raw });
            return err;
        });

        pairs.count += 1;
    }

    logger.debug("lhs: {any}", .{ pairs.lhs.items });
    logger.debug("rhs: {any}", .{ pairs.lhs.items });

    var result: i32 = 0;

    for (pairs.lhs.items) |lhs| {
        var matches: usize = 0;
        for (pairs.rhs.items) |rhs| {
            if (lhs == rhs) {
                matches += 1;
            }
        }
        result += lhs * @as(i32, @as(u31, @truncate(matches))); // This is hilarious
    }

    logger.info("Result: {}", .{ result });
}
