const std = @import("std");
const utils = @import("utils");

fn part_one(input: []const []const u8) u32 {
    var result: u32 = 0;
    for (input) |line| {
        if (line.len == 0) {
            continue;
        }

        var it = std.mem.splitScalar(u8, line, 'x');
        const a = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable;
        const b = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable;
        const c = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable;

        const sideA = a * b;
        const sideB = b * c;
        const sideC = c * a;
        result += 2 * (sideA + sideB + sideC) + @min(sideA, sideB, sideC);
    }
    return result;
}

fn part_two(input: []const []const u8) u32 {
    var result: u32 = 0;
    for (input) |line| {
        if (line.len == 0) {
            continue;
        }

        var it = std.mem.splitScalar(u8, line, 'x');
        const a = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable;
        const b = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable;
        const c = std.fmt.parseInt(u32, it.next().?, 10) catch unreachable;

        const sideA = a * b;
        const sideB = b * c;
        const sideC = c * a;
        const smallestSide = @min(sideA, sideB, sideC);
        if (smallestSide == sideA) {
            result += 2 * a + 2 * b;
        } else if (smallestSide == sideB) {
            result += 2 * b + 2 * c;
        } else if (smallestSide == sideC) {
            result += 2 * c + 2 * a;
        }

        result += a * b * c;
    }
    return result;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{}\n", .{part_one(input_lines)});
    std.debug.print("{}\n", .{part_two(input_lines)});
}

const expectEqual = std.testing.expectEqual;
test "examples part one" {
    const tests = [_]struct {
        given: []const []const u8,
        expected: u32,
    }{
        .{ .given = &.{"2x3x4"}, .expected = 58 },
        .{ .given = &.{"1x1x10"}, .expected = 43 },
        .{ .given = &.{ "2x3x4", "1x1x10" }, .expected = 101 },
    };

    for (tests) |test_case| {
        try expectEqual(test_case.expected, part_one(test_case.given));
    }
}

test "examples part two" {
    const tests = [_]struct {
        given: []const []const u8,
        expected: u32,
    }{
        .{ .given = &.{"2x3x4"}, .expected = 34 },
        .{ .given = &.{"1x1x10"}, .expected = 14 },
        .{ .given = &.{ "2x3x4", "1x1x10" }, .expected = 48 },
    };

    for (tests) |test_case| {
        try expectEqual(test_case.expected, part_two(test_case.given));
    }
}
