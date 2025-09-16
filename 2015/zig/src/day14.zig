const std = @import("std");
const utils = @import("utils");

const Reindeer = struct {
    name: []const u8,
    speed: usize,
    flight_duration: usize,
    rest_duration: usize,

    pub fn travel(self: *const Reindeer, total_time: usize) usize {
        var time = total_time;
        var distance: usize = 0;
        while (time > 0) {
            distance += self.speed * @min(self.flight_duration, time);

            time -|= self.flight_duration;
            time -|= self.rest_duration;
        }
        return distance;
    }
};

fn parseLine(allocator: std.mem.Allocator, input: []const u8) Reindeer {
    var result = std.ArrayList([]const u8).initCapacity(allocator, 10) catch unreachable;
    defer result.deinit(allocator);

    var it = std.mem.splitScalar(u8, input, ' ');
    while (it.next()) |s| {
        result.append(allocator, std.mem.trimRight(u8, s, ".")) catch unreachable;
    }

    return .{ .name = result.items[0], .speed = std.fmt.parseInt(u8, result.items[3], 10) catch unreachable, .flight_duration = std.fmt.parseInt(u8, result.items[6], 10) catch unreachable, .rest_duration = std.fmt.parseInt(u8, result.items[13], 10) catch unreachable };
}

fn partOne(allocator: std.mem.Allocator, input_lines: []const []const u8, time_limit: usize) usize {
    var max_distance: usize = 0;
    for (input_lines) |line| {
        max_distance = @max(max_distance, parseLine(allocator, line).travel(time_limit));
    }
    return max_distance;
}

fn partTwo(allocator: std.mem.Allocator, input_lines: []const []const u8, time_limit: usize) usize {
    var reindeers = std.ArrayList(Reindeer).initCapacity(allocator, input_lines.len) catch unreachable;
    defer reindeers.deinit(allocator);

    for (input_lines) |line| {
        reindeers.append(allocator, parseLine(allocator, line)) catch unreachable;
    }

    var scoreboard = std.StringHashMap(usize).init(allocator);
    defer scoreboard.deinit();

    for (reindeers.items) |reindeer| {
        scoreboard.put(reindeer.name, 0) catch unreachable;
    }

    var distances = std.StringHashMap(usize).init(allocator);
    defer distances.deinit();

    for (1..time_limit + 1) |i| {
        var max_distance: usize = 0;
        for (reindeers.items) |reindeer| {
            const distance_travelled = reindeer.travel(i);
            max_distance = @max(max_distance, distance_travelled);
            distances.put(reindeer.name, distance_travelled) catch unreachable;
        }

        var it = distances.iterator();
        while (it.next()) |entry| {
            if (entry.value_ptr.* == max_distance) {
                scoreboard.put(entry.key_ptr.*, scoreboard.get(entry.key_ptr.*).? + 1) catch unreachable;
            }
        }
    }

    var max_score: usize = 0;
    var it = scoreboard.valueIterator();
    while (it.next()) |score| {
        max_score = @max(max_score, score.*);
    }
    return max_score;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(gpa.allocator(), input_lines, 2503)});
    std.debug.print("{d}\n", .{partTwo(gpa.allocator(), input_lines, 2503)});
}

const expectEqual = std.testing.expectEqual;
test "part one examples" {
    const input = "Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.";
    const comet = parseLine(std.testing.allocator, input);

    try expectEqual(14, comet.travel(1));
    try expectEqual(140, comet.travel(10));
    try expectEqual(1120, comet.travel(1000));
}

test "part two examples" {
    const input_lines: []const []const u8 = &.{ "Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.", "Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds." };

    try expectEqual(1, partTwo(std.testing.allocator, input_lines, 1));
    try expectEqual(2, partTwo(std.testing.allocator, input_lines, 2));
    try expectEqual(139, partTwo(std.testing.allocator, input_lines, 140));
}

const expect = std.testing.expect;
test "distance calculation" {
    const comet_data = "Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.";
    const comet = parseLine(std.testing.allocator, comet_data);

    const dancer_data = "Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.";
    const dancer = parseLine(std.testing.allocator, dancer_data);

    try expect(comet.travel(140) > dancer.travel(140));
}
