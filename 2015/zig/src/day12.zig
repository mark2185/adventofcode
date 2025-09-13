const std = @import("std");
const utils = @import("utils");

fn sumNumbers(input: std.json.Value, unwanted_string: ?[]const u8, sum: i64) i64 {
    switch (input) {
        .integer => return sum + input.integer,
        .array => {
            var new_sum = sum;
            for (input.array.items) |it| {
                new_sum = sumNumbers(it, unwanted_string, new_sum);
            }
            return new_sum;
        },
        .object => {
            if (unwanted_string != null) {
                for (input.object.keys()) |key| {
                    if (std.mem.eql(u8, key, unwanted_string.?)) {
                        return sum;
                    }
                }
                for (input.object.values()) |val| {
                    if (val == .string and std.mem.eql(u8, val.string, unwanted_string.?)) {
                        return sum;
                    }
                }
            }
            var new_sum = sum;
            for (input.object.values()) |val| {
                new_sum = sumNumbers(val, unwanted_string, new_sum);
            }
            return new_sum;
        },
        else => return sum,
    }
}

fn partOne(allocator: std.mem.Allocator, input: []const u8) i64 {
    const parsed_str = std.json.parseFromSlice(std.json.Value, allocator, input, .{}) catch unreachable;
    defer parsed_str.deinit();

    return sumNumbers(parsed_str.value, null, 0);
}

fn partTwo(allocator: std.mem.Allocator, input: []const u8) i64 {
    const parsed_str = std.json.parseFromSlice(std.json.Value, allocator, input, .{}) catch unreachable;
    defer parsed_str.deinit();

    return sumNumbers(parsed_str.value, "red", 0);
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));

    std.debug.print("{d}\n", .{partOne(gpa.allocator(), input_lines[0])});
    std.debug.print("{d}\n", .{partTwo(gpa.allocator(), input_lines[0])});
}

const expectEqual = std.testing.expectEqual;
test "part one examples" {
    try expectEqual(15, partOne(std.testing.allocator, "[{\"key\": 5, \"blah\": 10}]"));
}

test "part two examples" {
    try expectEqual(15, partTwo(std.testing.allocator, "[{\"key\": 5, \"blah\": 10}]"));
    try expectEqual(0, partTwo(std.testing.allocator, "[{\"key\": 5, \"red\": 10}]"));
    try expectEqual(4, partTwo(std.testing.allocator, "[1, 3, \"red\"]"));
    try expectEqual(4, partTwo(std.testing.allocator, "[1,{\"c\":\"red\",\"b\":2},3]"));
    try expectEqual(0, partTwo(std.testing.allocator, "{\"d\":\"red\",\"e\":[1,2,3,4],\"f\":5}"));
    try expectEqual(8, partTwo(std.testing.allocator, "[{\"a\": 5, \"b\": [1, 2, {\"c\": \"red\"}]}]"));
}
