// zig run solution.zig

const std = @import("std");

const logger = std.log.scoped(.default);

pub fn main() !void {
    var solution_area = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = solution_area.allocator();

    const reports: []Report = try generateReports(allocator, @embedFile("sample.txt"));

    var safe_count: usize = 0;

    for (reports) |report| {
        if (try isReportSafe(allocator, &report)) {
            logger.debug("Safe line: {any}", .{ report.items });
            safe_count += 1;
        }
    }

    logger.info("Result: {}", .{ safe_count });
}

const Report = std.ArrayListUnmanaged(i32);
fn generateReports(
    allocator: std.mem.Allocator,
    contents: []const u8
) ![]Report {
    var reports: std.ArrayListUnmanaged(Report) = .{};
    errdefer reports.deinit(allocator);

    var content_iter = std.mem.splitSequence(u8, contents, "\n");
    while (content_iter.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var numbers: Report = .{};
        {
            var line_iter = std.mem.splitSequence(u8, line, " ");
            while (line_iter.next()) |level_raw| {
                try numbers.append(allocator, std.fmt.parseInt(i32, level_raw, 10) catch |err| {
                    logger.warn("Could not parse number [{s}]", .{ level_raw });
                    return err;
                });
            }
        }
        try reports.append(allocator, numbers);
    }
    return reports.items;
}

fn isReportSafe(
    allocator: std.mem.Allocator,
    report: *const Report
) !bool {
    if (try checkReport(allocator, report)) {
        return true;
    }

    for (0..report.items.len) |i| {
        var clone: Report = try report.clone(allocator);
        defer clone.deinit(allocator);
        _ = clone.orderedRemove(i);
        if (try checkReport(allocator, &clone)) {
            return true;
        }
    }
    return false;
}

fn checkReport(
    allocator: std.mem.Allocator,
    report: *const Report
) !bool {
    if (report.items.len < 2) {
        return error.Error;
    }

    var clone_incr = try report.clone(allocator);
    std.mem.sort(i32, clone_incr.items, {}, std.sort.asc(i32));
    defer clone_incr.deinit(allocator);

    var clone_decr = try report.clone(allocator);
    std.mem.sort(i32, clone_decr.items, {}, std.sort.desc(i32));
    defer clone_decr.deinit(allocator);

    if (!(std.mem.eql(i32, report.items, clone_incr.items) or std.mem.eql(i32, report.items, clone_decr.items))) {
        return false;
    }

    for (0..(report.items.len - 1)) |i| {
        const distance = clone_incr.items[i + 1] - clone_incr.items[i];
        if (distance < 1 or distance > 3) {
            return false;
        }
    }

    return true;
}
