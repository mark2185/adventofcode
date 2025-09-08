const std = @import("std");
const utils = @import("utils");

fn lookAndSee(allocator: std.mem.Allocator, input: []const u8) []u8 {
    var buffer = std.ArrayList(u8).initCapacity(allocator, input.len) catch unreachable;
    var writer = buffer.writer(allocator);
    var counter: u8 = 1;
    for (0..input.len - 1) |i| {
        if (input[i] == input[i + 1]) {
            counter += 1;
        } else {
            writer.print("{d}{c}", .{ counter, input[i] }) catch unreachable;
            counter = 1;
        }
    }
    writer.print("{d}{c}", .{ counter, input[input.len - 1] }) catch unreachable;
    return buffer.toOwnedSlice(allocator) catch unreachable;
}

fn getNextString(allocator: std.mem.Allocator, input: []const u8, iterations: u8) []const u8 {
    var buffer = std.ArrayList(u8).initCapacity(allocator, input.len) catch unreachable;

    buffer.appendSlice(allocator, input) catch unreachable;
    for (0..iterations) |_| {
        const next_buffer = lookAndSee(allocator, buffer.items);
        defer allocator.free(next_buffer);
        buffer.clearRetainingCapacity();
        buffer.appendSlice(allocator, next_buffer) catch unreachable;
    }

    return buffer.toOwnedSlice(allocator) catch unreachable;
}

fn partOne(allocator: std.mem.Allocator, input: []const u8) usize {
    const next_string = getNextString(allocator, input, 40);
    defer allocator.free(next_string);
    return next_string.len;
}

fn partTwo(allocator: std.mem.Allocator, input: []const u8) usize {
    const next_string = getNextString(allocator, input, 50);
    defer allocator.free(next_string);
    return next_string.len;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(gpa.allocator(), input_lines[0])});
    std.debug.print("{d}\n", .{partTwo(gpa.allocator(), input_lines[0])});
}

const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
test "get next string" {
    const input = "1";
    const nextString1 = getNextString(std.testing.allocator, input, 1);
    defer std.testing.allocator.free(nextString1);
    try expectEqual(2, nextString1.len);

    const nextString2 = getNextString(std.testing.allocator, input, 1);
    defer std.testing.allocator.free(nextString2);
    try expectEqual(2, nextString2.len);
}

test "look and see" {
    const test_cases = [_]struct {
        given: []const u8,
        expected: []const u8,
    }{
        .{ .given = "1", .expected = "11" },
        .{ .given = "11", .expected = "21" },
        .{ .given = "21", .expected = "1211" },
        .{ .given = "1211", .expected = "111221" },
        .{ .given = "111221", .expected = "312211" },
    };

    for (test_cases) |test_case| {
        const result = lookAndSee(std.testing.allocator, test_case.given);
        defer std.testing.allocator.free(result);
        try std.testing.expectEqualStrings(test_case.expected, result);
    }
}
