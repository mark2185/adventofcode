const std = @import("std");

pub fn readFile(allocator: std.mem.Allocator, path: []const u8) ![][]const u8 {
    const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    const file_contents = try file.readToEndAlloc(allocator, std.math.maxInt(usize));

    var lines = try std.ArrayList([]const u8).initCapacity(allocator, 1);

    var line_iter = std.mem.splitScalar(u8, file_contents, '\n');
    while (line_iter.next()) |line| {
        if (line.len == 0) continue;
        try lines.append(allocator, line);
    }

    return lines.toOwnedSlice(allocator);
}

pub fn contains(comptime T: type, haystack: []const T, needle: T) bool {
    for (haystack) |straw| {
        if (std.mem.eql(T, straw, needle)) {
            return true;
        }
    }
    return false;
}
