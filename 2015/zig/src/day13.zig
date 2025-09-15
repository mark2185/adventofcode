const std = @import("std");
const utils = @import("utils");

fn splitLine(allocator: std.mem.Allocator, input: []const u8) []const []const u8 {
    var result = std.ArrayList([]const u8).initCapacity(allocator, 10) catch unreachable;

    var it = std.mem.splitScalar(u8, input, ' ');
    while (it.next()) |s| {
        result.append(allocator, std.mem.trimRight(u8, s, ".")) catch unreachable;
    }
    return result.toOwnedSlice(allocator) catch unreachable;
}

fn contains(haystack: []const []const u8, needle: []const u8) bool {
    for (haystack) |straw| {
        if (std.mem.eql(u8, straw, needle)) {
            return true;
        }
    }
    return false;
}

fn evaluate(people: []const []const u8, score_map: std.StringHashMap(std.StringHashMap(i64))) i64 {
    var sum: i64 = 0;
    var i: i8 = 0;
    const people_number: i8 = @intCast(people.len);
    while (i < people.len) : (i += 1) {
        const person = people[@intCast(i)];
        const left_score = score_map.get(person).?.get(people[@intCast(@mod((i - 1), people_number))]).?;
        const right_score = score_map.get(person).?.get(people[@intCast(@mod((i + 1), people_number))]).?;
        sum += left_score + right_score;
    }
    return sum;
}

fn createScoreMap(allocator: std.mem.Allocator, input: []const []const u8) std.StringHashMap(std.StringHashMap(i64)) {
    var map = std.StringHashMap(std.StringHashMap(i64)).init(allocator);
    for (input) |line| {
        const data = splitLine(allocator, line);
        defer allocator.free(data);

        const person = data[0];
        const neighbour = data[10];
        var amount = std.fmt.parseInt(i64, data[3], 10) catch unreachable;
        const action = data[2];
        if (std.mem.eql(u8, "lose", action)) {
            amount *= -1;
        }
        if (!map.contains(person)) {
            map.put(person, std.StringHashMap(i64).init(allocator)) catch unreachable;
        }
        map.getPtr(person).?.*.put(neighbour, amount) catch unreachable;
    }
    return map;
}

fn calculateOptimalSeating(allocator: std.mem.Allocator, seating_order: *std.ArrayList([]const u8), score_map: std.StringHashMap(std.StringHashMap(i64))) i64 {
    if (seating_order.items.len == score_map.count()) {
        return evaluate(seating_order.items, score_map);
    }

    var max_score: i64 = 0;
    const last_seated = seating_order.getLast();
    var it = score_map.get(last_seated).?.keyIterator();
    while (it.next()) |neighbour| {
        if (contains(seating_order.items, neighbour.*)) {
            continue;
        }
        seating_order.append(allocator, neighbour.*) catch unreachable;
        max_score = @max(max_score, calculateOptimalSeating(allocator, seating_order, score_map));
        _ = seating_order.swapRemove(seating_order.items.len - 1);
    }

    return max_score;
}

fn partOne(allocator: std.mem.Allocator, input: []const []const u8) i64 {
    var score_map = createScoreMap(allocator, input);
    defer {
        var it = score_map.valueIterator();
        while (it.next()) |val| {
            val.deinit();
        }
        score_map.deinit();
    }

    var max_score: i64 = 0;

    var it = score_map.keyIterator();
    while (it.next()) |person| {
        var seating_order = std.ArrayList([]const u8).initCapacity(allocator, score_map.count()) catch unreachable;
        defer seating_order.deinit(allocator);

        seating_order.append(allocator, person.*) catch unreachable;
        max_score = @max(max_score, calculateOptimalSeating(allocator, &seating_order, score_map));
    }

    return max_score;
}

fn partTwo(allocator: std.mem.Allocator, input: []const []const u8) i64 {
    var score_map = createScoreMap(allocator, input);
    defer {
        var it = score_map.valueIterator();
        while (it.next()) |val| {
            val.deinit();
        }
        score_map.deinit();
    }

    score_map.put("Me", std.StringHashMap(i64).init(allocator)) catch unreachable;

    {
        var it = score_map.valueIterator();
        while (it.next()) |map| {
            map.put("Me", 0) catch unreachable;
        }
    }
    {
        var it = score_map.keyIterator();
        while (it.next()) |person| {
            score_map.getPtr("Me").?.*.put(person.*, 0) catch unreachable;
        }
    }

    var max_score: i64 = 0;

    var it = score_map.keyIterator();
    while (it.next()) |person| {
        var seating_order = std.ArrayList([]const u8).initCapacity(allocator, score_map.count()) catch unreachable;
        defer seating_order.deinit(allocator);

        seating_order.append(allocator, person.*) catch unreachable;
        max_score = @max(max_score, calculateOptimalSeating(allocator, &seating_order, score_map));
    }

    return max_score;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(gpa.allocator(), input_lines)});
    std.debug.print("{d}\n", .{partTwo(gpa.allocator(), input_lines)});
}

const expectEqual = std.testing.expectEqual;
test "part one examples" {
    const input_lines: []const []const u8 = &.{ "Alice would gain 54 happiness units by sitting next to Bob.", "Alice would lose 79 happiness units by sitting next to Carol.", "Alice would lose 2 happiness units by sitting next to David.", "Bob would gain 83 happiness units by sitting next to Alice.", "Bob would lose 7 happiness units by sitting next to Carol.", "Bob would lose 63 happiness units by sitting next to David.", "Carol would lose 62 happiness units by sitting next to Alice.", "Carol would gain 60 happiness units by sitting next to Bob.", "Carol would gain 55 happiness units by sitting next to David.", "David would gain 46 happiness units by sitting next to Alice.", "David would lose 7 happiness units by sitting next to Bob.", "David would gain 41 happiness units by sitting next to Carol." };

    try expectEqual(330, partOne(std.testing.allocator, input_lines));
}

test "createOptimalSeating" {
    const input_lines: []const []const u8 = &.{ "A would gain 5 happiness units by sitting next to B", "A would gain 0 happiness units by sitting next to C", "B would gain 5 happiness units by sitting next to A", "B would gain 0 happiness units by sitting next to C", "C would gain 0 happiness units by sitting next to A", "C would gain 0 happiness units by sitting next to B" };

    var score_map = createScoreMap(std.testing.allocator, input_lines);
    defer {
        var it = score_map.valueIterator();
        while (it.next()) |val| {
            val.deinit();
        }
        score_map.deinit();
    }

    try expectEqual(3, score_map.count());

    var seating_order = std.ArrayList([]const u8).initCapacity(std.testing.allocator, score_map.count()) catch unreachable;
    defer seating_order.deinit(std.testing.allocator);

    seating_order.append(std.testing.allocator, "A") catch unreachable;

    try expectEqual(10, calculateOptimalSeating(std.testing.allocator, &seating_order, score_map));
}
