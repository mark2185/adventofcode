const std = @import("std");
const utils = @import("utils");

fn part_one(input: []const u8) i32 {
    var cnt: i32 = 0;
    for (input) |bracket| {
        cnt += if (bracket == '(') 1 else -1;
    }
    return cnt;
}

fn part_two(input: []const u8) usize {
    var cnt: i32 = 0;
    for (input, 1..) |bracket, i| {
        cnt += if (bracket == '(') 1 else -1;
        if (cnt == -1) {
            return i;
        }
    }
    unreachable;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{part_one(input_lines[0])});
    std.debug.print("{d}\n", .{part_two(input_lines[0])});
}

const expectEqual = std.testing.expectEqual;

test "examples part one" {
    const tests = [_]struct {
        given: []const u8,
        expected: i32,
    }{
        .{ .given = "(())", .expected = 0 },
        .{ .given = "()()", .expected = 0 },
        .{ .given = "(((", .expected = 3 },
        .{ .given = "(()(()(", .expected = 3 },
        .{ .given = "))(((((", .expected = 3 },
        .{ .given = "())", .expected = -1 },
        .{ .given = "))(", .expected = -1 },
        .{ .given = ")))", .expected = -3 },
        .{ .given = ")())())", .expected = -3 },
    };

    for (tests) |test_case| {
        try expectEqual(part_one(test_case.given), test_case.expected);
    }
}

test "examples part two" {
    const tests = [_]struct {
        given: []const u8,
        expected: usize,
    }{
        .{ .given = ")", .expected = 1 },
        .{ .given = "()())", .expected = 5 },
    };

    for (tests) |test_case| {
        try expectEqual(part_two(test_case.given), test_case.expected);
    }
}
