const std = @import("std");
const utils = @import("utils");

fn partOne(allocator: std.mem.Allocator, input_lines: []const []const u8, limit: usize) usize {
    var capacities = std.ArrayList(u8).initCapacity(allocator, 1) catch unreachable;
    defer capacities.deinit(allocator);

    for (input_lines) |line| {
        capacities.append(allocator, std.fmt.parseInt(u8, line, 10) catch unreachable) catch unreachable;
    }

    std.mem.sort(u8, capacities.items, {}, struct {
        pub fn inner(_: void, lhs: u8, rhs: u8) bool {
            return lhs < rhs;
        }
    }.inner);

    var count: usize = 0;
    for (0..(@as(usize, 1) << @intCast(capacities.items.len))) |i| {
        var volume: usize = 0;
        for (capacities.items, 0..) |c, bitIndex| {
            if (i & (@as(usize, 1) << @intCast(bitIndex)) > 0) {
                volume += c;
            }
        }
        if (volume == limit) {
            count += 1;
        }
    }
    return count;
}

fn partTwo(allocator: std.mem.Allocator, input_lines: []const []const u8, limit: usize) usize {
    var capacities = std.ArrayList(u8).initCapacity(allocator, 1) catch unreachable;
    defer capacities.deinit(allocator);

    for (input_lines) |line| {
        capacities.append(allocator, std.fmt.parseInt(u8, line, 10) catch unreachable) catch unreachable;
    }

    std.mem.sort(u8, capacities.items, {}, struct {
        pub fn inner(_: void, lhs: u8, rhs: u8) bool {
            return lhs < rhs;
        }
    }.inner);

    var min_container_amount: usize = capacities.items.len;
    for (0..(@as(usize, 1) << @intCast(capacities.items.len))) |i| {
        var volume: usize = 0;
        for (capacities.items, 0..) |c, bitIndex| {
            if (i & (@as(usize, 1) << @intCast(bitIndex)) > 0) {
                volume += c;
            }
        }
        if (volume == limit) {
            min_container_amount = @min(min_container_amount, @popCount(i));
        }
    }

    var count: usize = 0;
    for (0..(@as(usize, 1) << @intCast(capacities.items.len))) |i| {
        var volume: usize = 0;
        for (capacities.items, 0..) |c, bitIndex| {
            if (i & (@as(usize, 1) << @intCast(bitIndex)) > 0) {
                volume += c;
            }
        }
        if (volume == limit and @popCount(i) == min_container_amount) {
            count += 1;
        }
    }
    return count;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(gpa.allocator(), input_lines, 150)});
    std.debug.print("{d}\n", .{partTwo(gpa.allocator(), input_lines, 150)});
}

const expectEqual = std.testing.expectEqual;
test "part one examples" {
    const input_lines: []const []const u8 = &.{ "20", "15", "10", "5", "5" };
    try expectEqual(4, partOne(std.testing.allocator, input_lines, 25));
}
