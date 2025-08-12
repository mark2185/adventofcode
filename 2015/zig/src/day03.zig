const std = @import("std");
const utils = @import("utils");

const Point = struct { x: i32, y: i32 };
const Direction = enum { left, right, up, down };

fn move(p: Point, d: Direction) Point {
    return switch (d) {
        Direction.left => Point{ .x = p.x - 1, .y = p.y },
        Direction.right => Point{ .x = p.x + 1, .y = p.y },
        Direction.up => Point{ .x = p.x, .y = p.y + 1 },
        Direction.down => Point{ .x = p.x, .y = p.y - 1 },
    };
}

fn part_one(allocator: std.mem.Allocator, input: []const u8) u32 {
    var location = Point{ .x = 0, .y = 0 };

    var visited_houses = std.AutoHashMap(Point, void).init(allocator);
    defer visited_houses.deinit();

    visited_houses.put(location, {}) catch unreachable;

    for (input) |direction| {
        location = move(location, switch (direction) {
            '<' => Direction.left,
            '>' => Direction.right,
            '^' => Direction.up,
            'v' => Direction.down,
            else => unreachable,
        });
        visited_houses.put(location, {}) catch unreachable;
    }
    return visited_houses.count();
}

fn part_two(allocator: std.mem.Allocator, input: []const u8) u32 {
    var santa_location = Point{ .x = 0, .y = 0 };
    var robosanta_location = Point{ .x = 0, .y = 0 };

    var visited_houses = std.AutoHashMap(Point, void).init(allocator);
    defer visited_houses.deinit();

    visited_houses.put(santa_location, {}) catch unreachable;

    var move_indicator = true;
    for (input) |instruction| {
        const direction = switch (instruction) {
            '<' => Direction.left,
            '>' => Direction.right,
            '^' => Direction.up,
            'v' => Direction.down,
            else => unreachable,
        };
        if (move_indicator) {
            santa_location = move(santa_location, direction);
        } else {
            robosanta_location = move(robosanta_location, direction);
        }
        visited_houses.put(santa_location, {}) catch unreachable;
        visited_houses.put(robosanta_location, {}) catch unreachable;

        move_indicator = !move_indicator;
    }
    return visited_houses.count();
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{part_one(gpa.allocator(), input_lines[0])});
    std.debug.print("{d}\n", .{part_two(gpa.allocator(), input_lines[0])});
}

const expectEqual = std.testing.expectEqual;
test "examples part one" {
    const tests = [_]struct {
        given: []const u8,
        expected: u32,
    }{
        .{ .given = ">", .expected = 2 },
        .{ .given = "^>v<", .expected = 4 },
        .{ .given = "^v^v^v^v^v", .expected = 2 },
    };

    for (tests) |test_case| {
        try expectEqual(test_case.expected, part_one(std.testing.allocator, test_case.given));
    }
}

test "examples part two" {
    const tests = [_]struct {
        given: []const u8,
        expected: u32,
    }{
        .{ .given = "^v", .expected = 3 },
        .{ .given = "^>v<", .expected = 3 },
        .{ .given = "^v^v^v^v^v", .expected = 11 },
    };

    for (tests) |test_case| {
        try expectEqual(test_case.expected, part_two(std.testing.allocator, test_case.given));
    }
}
