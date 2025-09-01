const std = @import("std");
const utils = @import("utils");

fn partOne(input_lines: []const []const u8) usize {
    var total_count: usize = 0;
    var memory_count: usize = 0;
    for (input_lines) |line| {
        total_count += line.len;
        var i: usize = 1;
        while (i < line.len - 1) : (i += 1) {
            const c = line[i];
            memory_count += 1;
            if (c != '\\') {
                continue;
            }
            const next_char = line[i + 1];
            switch (next_char) {
                '"', '\\' => i += 1,
                'x' => i += 3,
                else => unreachable,
            }
        }
    }
    return total_count - memory_count;
}

fn partTwo(input_lines: []const []const u8) usize {
    var total_count: usize = 0;
    var memory_count: usize = 0;
    for (input_lines) |line| {
        total_count += line.len;
        memory_count += 2;
        for (line) |c| {
            memory_count += 1;
            switch (c) {
                '"', '\\' => memory_count += 1,
                else => {},
            }
        }
    }
    return memory_count - total_count;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(input_lines)});
    std.debug.print("{d}\n", .{partTwo(input_lines)});
}
