const std = @import("std");
const utils = @import("utils");

const Trip = struct {
    departure: []const u8,
    destination: []const u8,
    distance: usize,

    pub fn reverse(self: Trip) Trip {
        return .{ .departure = self.destination, .destination = self.departure, .distance = self.distance };
    }
};

fn contains(haystack: []const []const u8, needle: []const u8) bool {
    for (haystack) |straw| {
        if (std.mem.eql(u8, straw, needle)) {
            return true;
        }
    }
    return false;
}

fn findShortestPath(allocator: std.mem.Allocator, visited: *std.ArrayList([]const u8), graph: std.StringHashMap(std.ArrayList(Trip)), distance_travelled: usize) usize {
    if (visited.items.len == graph.count()) {
        return distance_travelled;
    }

    var min_distance: usize = std.math.maxInt(usize);
    const neighbours = graph.get(visited.getLast()).?.items;
    for (neighbours) |trip| {
        if (contains(visited.items, trip.destination)) {
            continue;
        }
        visited.append(allocator, trip.destination) catch unreachable;
        min_distance = @min(min_distance, findShortestPath(allocator, visited, graph, distance_travelled + trip.distance));
        _ = visited.swapRemove(visited.items.len - 1);
    }
    return min_distance;
}

fn findLongestPath(allocator: std.mem.Allocator, visited: *std.ArrayList([]const u8), graph: std.StringHashMap(std.ArrayList(Trip)), distance_travelled: usize) usize {
    if (visited.items.len == graph.count()) {
        return distance_travelled;
    }

    var max_distance: usize = 0;
    const neighbours = graph.get(visited.getLast()).?.items;
    for (neighbours) |trip| {
        if (contains(visited.items, trip.destination)) {
            continue;
        }
        visited.append(allocator, trip.destination) catch unreachable;
        max_distance = @max(max_distance, findLongestPath(allocator, visited, graph, distance_travelled + trip.distance));
        _ = visited.swapRemove(visited.items.len - 1);
    }
    return max_distance;
}

fn parseLine(input: []const u8) Trip {
    var it = std.mem.splitSequence(u8, input, " = ");
    const lhs = it.next().?;
    const distance = std.fmt.parseInt(usize, it.next().?, 10) catch unreachable;

    it = std.mem.splitSequence(u8, lhs, " to ");
    return .{
        .departure = it.next().?,
        .destination = it.next().?,
        .distance = distance,
    };
}

fn constructGraph(allocator: std.mem.Allocator, input_lines: []const []const u8) std.StringHashMap(std.ArrayList(Trip)) {
    var graph = std.StringHashMap(std.ArrayList(Trip)).init(allocator);

    for (input_lines) |line| {
        const trip = parseLine(line);
        if (!graph.contains(trip.departure)) {
            graph.put(trip.departure, std.ArrayList(Trip).initCapacity(allocator, 1) catch unreachable) catch unreachable;
        }
        if (!graph.contains(trip.destination)) {
            graph.put(trip.destination, std.ArrayList(Trip).initCapacity(allocator, 1) catch unreachable) catch unreachable;
        }

        graph.getPtr(trip.departure).?.append(allocator, trip) catch unreachable;
        graph.getPtr(trip.destination).?.append(allocator, trip.reverse()) catch unreachable;
    }

    return graph;
}

fn partOne(allocator: std.mem.Allocator, input_lines: []const []const u8) usize {
    var graph = constructGraph(allocator, input_lines);
    defer {
        var it = graph.valueIterator();
        while (it.next()) |val| {
            val.deinit(allocator);
        }
        graph.deinit();
    }

    var it = graph.keyIterator();
    var min_distance: usize = std.math.maxInt(usize);
    while (it.next()) |city| {
        var visited = std.ArrayList([]const u8).initCapacity(allocator, graph.count()) catch unreachable;
        defer visited.deinit(allocator);

        visited.append(allocator, city.*) catch unreachable;

        min_distance = @min(min_distance, findShortestPath(allocator, &visited, graph, 0));
    }
    return min_distance;
}

fn partTwo(allocator: std.mem.Allocator, input_lines: []const []const u8) usize {
    var graph = constructGraph(allocator, input_lines);
    defer {
        var it = graph.valueIterator();
        while (it.next()) |val| {
            val.deinit(allocator);
        }
        graph.deinit();
    }

    var it = graph.keyIterator();
    var max_distance: usize = 0;
    while (it.next()) |city| {
        var visited = std.ArrayList([]const u8).initCapacity(allocator, graph.count()) catch unreachable;
        defer visited.deinit(allocator);

        visited.append(allocator, city.*) catch unreachable;

        max_distance = @max(max_distance, findLongestPath(allocator, &visited, graph, 0));
    }
    return max_distance;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(gpa.allocator(), input_lines)});
    std.debug.print("{d}\n", .{partTwo(gpa.allocator(), input_lines)});
}

const expectEqual = std.testing.expectEqual;
test "part one examples" {
    const input: []const []const u8 = &.{
        "London to Dublin = 464",
        "London to Belfast = 518",
        "Dublin to Belfast = 141",
    };

    try expectEqual(605, partOne(std.testing.allocator, input));
}

test "part two examples" {
    const input: []const []const u8 = &.{
        "London to Dublin = 464",
        "London to Belfast = 518",
        "Dublin to Belfast = 141",
    };

    try expectEqual(982, partTwo(std.testing.allocator, input));
}

test "dfs" {
    const input: []const []const u8 = &.{
        "London to Dublin = 464",
        "London to Belfast = 518",
        "Dublin to Belfast = 141",
    };

    try expectEqual(605, partOne(std.testing.allocator, input));
}

test "dfs 2" {
    const input: []const []const u8 = &.{
        "A to B = 1",
        "A to C = 1",
        "A to D = 1",
        "A to Center = 50",
        "B to C = 1",
        "B to D = 1",
        "B to Center = 50",
        "C to D = 1",
        "C to Center = 50",
        "D to Center = 50",
    };

    try expectEqual(53, partOne(std.testing.allocator, input));
}
