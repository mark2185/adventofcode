const std = @import("std");
const utils = @import("utils");

fn countPresents(house_index: usize, presents_per_house: usize, max_deliveries: ?usize) usize {
    var count: usize = if (house_index == 1) 1 else 1 + house_index;
    var i: usize = 2;
    const sentinel: usize = std.math.sqrt(house_index);
    while (i <= sentinel) : (i += 1) {
        if (house_index % i != 0) {
            continue;
        }

        if (max_deliveries) |limit| {
            if (i <= limit) {
                count += house_index / i;
            }
            if (house_index / i <= limit) {
                count += i;
            }
        } else {
            count += i;
            if (i * i != house_index) {
                count += house_index / i;
            }
        }
    }
    return count * presents_per_house;
}

fn partOne(input: usize) usize {
    for (10..std.math.maxInt(usize)) |i| {
        const count = countPresents(i, 10, undefined);
        if (count > input) {
            return i;
        }
    }
    unreachable;
}

fn partTwo(input: usize) usize {
    for (10..std.math.maxInt(usize)) |i| {
        const count = countPresents(i, 11, 50);
        if (count > input) {
            return i;
        }
    }
    unreachable;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    const input = try std.fmt.parseInt(usize, input_lines[0], 10);

    std.debug.print("{d}\n", .{partOne(input)});
    std.debug.print("{d}\n", .{partTwo(input)});
}

const expectEqual = std.testing.expectEqual;
test "count presents" {
    const test_cases = [_]struct {
        given: usize,
        expected: usize,
    }{
        .{ .given = 1, .expected = 10 },
        .{ .given = 2, .expected = 30 },
        .{ .given = 3, .expected = 40 },
        .{ .given = 4, .expected = 70 },
        .{ .given = 5, .expected = 60 },
        .{ .given = 6, .expected = 120 },
        .{ .given = 7, .expected = 80 },
        .{ .given = 8, .expected = 150 },
        .{ .given = 9, .expected = 130 },
    };

    for (test_cases) |test_case| {
        try expectEqual(test_case.expected, countPresents(test_case.given, 10, null));
    }
}

test "part one input" {
    try expectEqual(665280, partOne(29000000));
}
