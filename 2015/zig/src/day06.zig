const std = @import("std");
const utils = @import("utils");

fn parseCoords(input: []const u8) [2]struct { x: usize, y: usize } {
    var it = std.mem.tokenizeSequence(u8, input, " through ");
    const first = it.next().?;
    const second = it.next().?;

    var it2 = std.mem.tokenizeScalar(u8, first, ',');
    const x1 = it2.next().?;
    const y1 = it2.next().?;

    var it3 = std.mem.tokenizeScalar(u8, second, ',');
    const x2 = it3.next().?;
    const y2 = it3.next().?;

    return .{
        .{
            .x = std.fmt.parseInt(usize, x1, 10) catch unreachable,
            .y = std.fmt.parseInt(usize, y1, 10) catch unreachable,
        },
        .{
            .x = std.fmt.parseInt(usize, x2, 10) catch unreachable,
            .y = std.fmt.parseInt(usize, y2, 10) catch unreachable,
        },
    };
}

fn partOne(input: []const []const u8) usize {
    var grid: [1000][1000]bool = std.mem.zeroes([1000][1000]bool);
    for (input) |line| {
        if (std.mem.startsWith(u8, line, "turn on")) {
            const p1, const p2 = parseCoords(line[8..]);
            for (p1.y..p2.y + 1) |y| {
                for (p1.x..p2.x + 1) |x| {
                    grid[y][x] = true;
                }
            }
        } else if (std.mem.startsWith(u8, line, "turn off")) {
            const p1, const p2 = parseCoords(line[9..]);
            for (p1.y..p2.y + 1) |y| {
                for (p1.x..p2.x + 1) |x| {
                    grid[y][x] = false;
                }
            }
        } else if (std.mem.startsWith(u8, line, "toggle")) {
            const p1, const p2 = parseCoords(line[7..]);
            for (p1.y..p2.y + 1) |y| {
                for (p1.x..p2.x + 1) |x| {
                    grid[y][x] ^= true;
                }
            }
        } else unreachable;
    }

    var counter: usize = 0;
    for (grid) |row| {
        for (row) |col| {
            if (col) {
                counter += 1;
            }
        }
    }
    return counter;
}

fn partTwo(input: []const []const u8) usize {
    var grid: [1000][1000]u8 = std.mem.zeroes([1000][1000]u8);
    for (input) |line| {
        if (std.mem.startsWith(u8, line, "turn on")) {
            const p1, const p2 = parseCoords(line[8..]);
            for (p1.y..p2.y + 1) |y| {
                for (p1.x..p2.x + 1) |x| {
                    grid[y][x] += 1;
                }
            }
        } else if (std.mem.startsWith(u8, line, "turn off")) {
            const p1, const p2 = parseCoords(line[9..]);
            for (p1.y..p2.y + 1) |y| {
                for (p1.x..p2.x + 1) |x| {
                    grid[y][x] -|= 1;
                }
            }
        } else if (std.mem.startsWith(u8, line, "toggle")) {
            const p1, const p2 = parseCoords(line[7..]);
            for (p1.y..p2.y + 1) |y| {
                for (p1.x..p2.x + 1) |x| {
                    grid[y][x] += 2;
                }
            }
        } else unreachable;
    }

    var counter: usize = 0;
    for (grid) |row| {
        for (row) |col| {
            counter += col;
        }
    }
    return counter;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(input_lines)});
    std.debug.print("{d}\n", .{partTwo(input_lines)});
}

const expectEqual = std.testing.expectEqual;
test "part one examples" {
    const test_cases = [_]struct {
        given: []const []const u8,
        expected: usize,
    }{
        .{ .given = &.{"turn on 0,0 through 999,999"}, .expected = 1_000_000 },
        .{ .given = &.{"toggle 0,0 through 999,0"}, .expected = 1_000 },
        .{ .given = &.{"turn off 499,499 through 500,500"}, .expected = 0 },
    };

    for (test_cases) |test_case| {
        expectEqual(test_case.expected, partOne(test_case.given)) catch |err| {
            return err;
        };
    }
}

test "part two examples" {
    const test_cases = [_]struct {
        given: []const []const u8,
        expected: usize,
    }{
        .{ .given = &.{"turn on 0,0 through 0,0"}, .expected = 1 },
        .{ .given = &.{"toggle 0,0 through 999,999"}, .expected = 2000000 },
    };

    for (test_cases) |test_case| {
        expectEqual(test_case.expected, partTwo(test_case.given)) catch |err| {
            return err;
        };
    }
}
