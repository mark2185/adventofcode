const std = @import("std");
const utils = @import("utils");

fn countNeighbours(comptime size: usize, grid: [size][size]bool, x: i8, y: i8) u8 {
    const coords = [8]struct {
        x: i8,
        y: i8,
    }{
        .{ .x = -1, .y = -1 },
        .{ .x = 0, .y = -1 },
        .{ .x = 1, .y = -1 },
        .{ .x = -1, .y = 0 },
        .{ .x = 1, .y = 0 },
        .{ .x = -1, .y = 1 },
        .{ .x = 0, .y = 1 },
        .{ .x = 1, .y = 1 },
    };

    var count: u8 = 0;
    for (coords) |c| {
        const neighbour_x: i8 = x + c.x;
        if (neighbour_x < 0 or neighbour_x >= grid.len) {
            continue;
        }
        const neighbour_y: i8 = y + c.y;
        if (neighbour_y < 0 or neighbour_y >= grid.len) {
            continue;
        }
        // std.debug.print("Checking neighbour ({d}, {d})\n", .{ neighbour_x, neighbour_y });
        count += @intFromBool(grid[@intCast(neighbour_y)][@intCast(neighbour_x)]);
    }
    return count;
}

fn simulateCycle(comptime size: usize, current_grid: [size][size]bool, new_grid: *[size][size]bool) void {
    // A light which is on stays on when 2 or 3 neighbors are on, and turns off otherwise.
    // A light which is off turns on if exactly 3 neighbors are on, and stays off otherwise.

    var y: i8 = 0;
    while (y < size) : (y += 1) {
        var x: i8 = 0;
        while (x < size) : (x += 1) {
            const neighbours_on = countNeighbours(size, current_grid, x, y);
            if (current_grid[@intCast(y)][@intCast(x)]) {
                if (neighbours_on == 2 or neighbours_on == 3) {
                    new_grid[@intCast(y)][@intCast(x)] = true;
                    continue;
                } else {
                    new_grid[@intCast(y)][@intCast(x)] = false;
                }
            } else {
                if (neighbours_on == 3) {
                    new_grid[@intCast(y)][@intCast(x)] = true;
                } else {
                    new_grid[@intCast(y)][@intCast(x)] = false;
                }
            }
        }
    }
}

fn partOne(input_lines: []const []const u8, comptime grid_dimensions: usize, steps: usize) usize {
    var grid_a: [grid_dimensions][grid_dimensions]bool = undefined;
    var grid_b: [grid_dimensions][grid_dimensions]bool = undefined;

    for (input_lines, 0..) |row, y| {
        for (row, 0..) |col, x| {
            grid_a[y][x] = col == '#';
            grid_b[y][x] = false;
        }
    }

    for (0..steps) |_| {
        simulateCycle(grid_dimensions, grid_a, &grid_b);
        std.mem.swap(@TypeOf(grid_a), &grid_a, &grid_b);
    }

    var count: usize = 0;
    for (grid_a) |row| {
        for (row) |col| {
            if (col) {
                count += 1;
            }
        }
    }
    return count;
}

fn partTwo(input_lines: []const []const u8, comptime grid_dimensions: usize, steps: usize) usize {
    var grid_a: [grid_dimensions][grid_dimensions]bool = undefined;
    var grid_b: [grid_dimensions][grid_dimensions]bool = undefined;

    for (input_lines, 0..) |row, y| {
        for (row, 0..) |col, x| {
            grid_a[y][x] = col == '#';
            grid_b[y][x] = false;
        }
    }

    for (0..steps) |_| {
        grid_a[0][0] = true;
        grid_a[grid_dimensions - 1][0] = true;
        grid_a[0][grid_dimensions - 1] = true;
        grid_a[grid_dimensions - 1][grid_dimensions - 1] = true;

        simulateCycle(grid_dimensions, grid_a, &grid_b);
        std.mem.swap(@TypeOf(grid_a), &grid_a, &grid_b);
    }

    grid_a[0][0] = true;
    grid_a[grid_dimensions - 1][0] = true;
    grid_a[0][grid_dimensions - 1] = true;
    grid_a[grid_dimensions - 1][grid_dimensions - 1] = true;

    var count: usize = 0;
    for (grid_a) |row| {
        for (row) |col| {
            if (col) {
                count += 1;
            }
        }
    }
    return count;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(input_lines, 100, 100)});
    std.debug.print("{d}\n", .{partTwo(input_lines, 100, 100)});
}

const expectEqual = std.testing.expectEqual;
test "part one examples" {
    const input_lines: []const []const u8 = &.{
        ".#.#.#",
        "...##.",
        "#....#",
        "..#...",
        "#.#..#",
        "####..",
    };

    try expectEqual(4, partOne(input_lines, 6, 4));
}

test "part two examples" {
    const input_lines: []const []const u8 = &.{
        ".#.#.#",
        "...##.",
        "#....#",
        "..#...",
        "#.#..#",
        "####..",
    };

    try expectEqual(17, partTwo(input_lines, 6, 5));
}
