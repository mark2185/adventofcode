const std = @import("std");
var gpa = std.heap.DebugAllocator(.{}){};

pub fn readFile(path: []const u8) ![][]const u8 {
    const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    const file_contents = try file.readToEndAlloc(gpa.allocator(), std.math.maxInt(usize));

    var lines = std.ArrayList([]const u8).init(gpa.allocator());

    var line_iter = std.mem.splitScalar(u8, file_contents, '\n');
    while (line_iter.next()) |line| {
        try lines.append(line);
    }

    return lines.toOwnedSlice();
}
