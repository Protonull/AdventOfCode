// zig run solution.zig

const std = @import("std");

const logger = std.log.scoped(.default);

pub fn main() !void {
    const contents = @embedFile("sample.txt");

    var solution_area = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = solution_area.allocator();

    var safe_count: usize = 0;

    var line_iterator = std.mem.splitSequence(u8, contents, "\n");
    line_loop: while (line_iterator.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        const numbers: []const i32 = brk: {
            var found: std.ArrayListUnmanaged(i32) = .{};
            var report_iterator = std.mem.splitSequence(u8, line, " ");
            while (report_iterator.next()) |number_raw| {
                try found.append(allocator, std.fmt.parseInt(i32, number_raw, 10) catch |err| {
                    logger.warn("Could not parse number [{s}]", .{ number_raw });
                    return err;
                });
            }
            break :brk found.items;
        };

        if (numbers.len < 2) {
            continue;
        }

        const numbrs_incr: []i32 = try duplicateArray(i32, @constCast(numbers), allocator);
        std.mem.sort(i32, numbrs_incr, {}, std.sort.asc(i32));

        const numbrs_decr: []i32 = try duplicateArray(i32, @constCast(numbers), allocator);
        std.mem.sort(i32, numbrs_decr, {}, std.sort.desc(i32));

        if (!(std.mem.eql(i32, numbers, numbrs_incr) or std.mem.eql(i32, numbers, numbrs_decr))) {
            continue;
        }

        for (0..(numbers.len - 1)) |i| {
            const difference = @abs(numbrs_incr[i] - numbrs_incr[i + 1]);
            if (difference < 1 or difference > 3) {
                continue :line_loop;
            }
        }

        logger.debug("Safe line: {s}", .{ line });
        safe_count += 1;
    }

    logger.info("Result: {}", .{ safe_count });
}

fn duplicateArray(
    comptime T: type,
    array: []T,
    allocator: std.mem.Allocator
) ![]T {
    const copy: []i32 = try allocator.alloc(i32, array.len);
    @memcpy(copy, array);
    return copy;
}
