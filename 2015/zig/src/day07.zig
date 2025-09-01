const std = @import("std");
const utils = @import("utils");

fn AND(input: []const u8, output: []const u8, wires: *std.StringHashMap(u16)) bool {
    var vars = std.mem.splitSequence(u8, input, " AND ");
    const fst = vars.next().?;
    const snd = vars.next().?;

    const a = wires.get(fst) orelse std.fmt.parseInt(u16, fst, 10) catch return false;
    const b = wires.get(snd) orelse std.fmt.parseInt(u16, snd, 10) catch return false;

    wires.put(output, a & b) catch unreachable;
    return true;
}

fn OR(input: []const u8, output: []const u8, wires: *std.StringHashMap(u16)) bool {
    var vars = std.mem.splitSequence(u8, input, " OR ");
    const fst = vars.next().?;
    const snd = vars.next().?;

    const a = wires.get(fst) orelse std.fmt.parseInt(u16, fst, 10) catch return false;
    const b = wires.get(snd) orelse std.fmt.parseInt(u16, snd, 10) catch return false;

    wires.put(output, a | b) catch unreachable;
    return true;
}

fn LSHIFT(input: []const u8, output: []const u8, wires: *std.StringHashMap(u16)) bool {
    var vars = std.mem.splitSequence(u8, input, " LSHIFT ");
    const fst = vars.next().?;
    const snd = vars.next().?;

    const a = wires.get(fst);
    const b = std.fmt.parseInt(u16, snd, 10) catch unreachable;
    if (a == null) return false;

    wires.put(output, a.? << @intCast(b)) catch unreachable;
    return true;
}

fn RSHIFT(input: []const u8, output: []const u8, wires: *std.StringHashMap(u16)) bool {
    var vars = std.mem.splitSequence(u8, input, " RSHIFT ");
    const fst = vars.next().?;
    const snd = vars.next().?;

    const a = wires.get(fst);
    const b = std.fmt.parseInt(u16, snd, 10) catch unreachable;
    if (a == null) return false;

    wires.put(output, a.? >> @intCast(b)) catch unreachable;
    return true;
}

fn NOT(input: []const u8, output: []const u8, wires: *std.StringHashMap(u16)) bool {
    const a = wires.get(input[4..]);
    if (a == null) return false;

    wires.put(output, ~a.?) catch unreachable;
    return true;
}

fn LOAD(input: []const u8, output: []const u8, wires: *std.StringHashMap(u16)) bool {
    const value = std.fmt.parseInt(u16, input, 10) catch {
        // not a constant
        const reg = wires.get(input);
        if (reg == null) return false;

        wires.put(output, reg.?) catch unreachable;
        return true;
    };

    wires.put(output, value) catch unreachable;
    return true;
}

fn partOne(allocator: std.mem.Allocator, input_lines: []const []const u8) u16 {
    var wires = std.StringHashMap(u16).init(allocator);
    defer wires.deinit();

    var instructions = std.ArrayList([]const u8).initCapacity(allocator, 1) catch unreachable;
    defer instructions.deinit(allocator);

    instructions.appendSlice(allocator, input_lines) catch unreachable;

    while (true) {
        var new_instructions = std.ArrayList([]const u8).initCapacity(allocator, 1) catch unreachable;
        defer new_instructions.deinit(allocator);

        for (instructions.items) |line| {
            var it = std.mem.splitSequence(u8, line, " -> ");
            const lhs = it.next().?;
            const destination = it.next().?;

            if (std.mem.containsAtLeast(u8, lhs, 1, "AND")) {
                if (!AND(lhs, destination, &wires)) {
                    new_instructions.append(allocator, line) catch unreachable;
                    continue;
                }
            } else if (std.mem.containsAtLeast(u8, lhs, 1, "OR")) {
                if (!OR(lhs, destination, &wires)) {
                    new_instructions.append(allocator, line) catch unreachable;
                    continue;
                }
            } else if (std.mem.containsAtLeast(u8, lhs, 1, "LSHIFT")) {
                if (!LSHIFT(lhs, destination, &wires)) {
                    new_instructions.append(allocator, line) catch unreachable;
                    continue;
                }
            } else if (std.mem.containsAtLeast(u8, lhs, 1, "RSHIFT")) {
                if (!RSHIFT(lhs, destination, &wires)) {
                    new_instructions.append(allocator, line) catch unreachable;
                    continue;
                }
            } else if (std.mem.containsAtLeast(u8, lhs, 1, "NOT")) {
                if (!NOT(lhs, destination, &wires)) {
                    new_instructions.append(allocator, line) catch unreachable;
                    continue;
                }
            } else if (!LOAD(lhs, destination, &wires)) {
                new_instructions.append(allocator, line) catch unreachable;
                continue;
            }
        }

        if (instructions.items.len == new_instructions.items.len) unreachable;

        instructions.clearRetainingCapacity();
        instructions.insertSlice(allocator, 0, new_instructions.items) catch unreachable;

        if (new_instructions.items.len == 0) {
            break;
        }
    }
    return wires.get("a") orelse 123;
}

fn partTwo(allocator: std.mem.Allocator, input_lines: []const []const u8, b_value: u16) u16 {
    var instructions = std.ArrayList([]const u8).initCapacity(allocator, 1) catch unreachable;
    defer instructions.deinit(allocator);

    instructions.appendSlice(allocator, input_lines) catch unreachable;

    var buf: [10]u8 = undefined;
    for (0..instructions.items.len) |i| {
        if (std.mem.endsWith(u8, instructions.items[i], "-> b")) {
            instructions.items[i] = std.fmt.bufPrint(&buf, "{d} -> b", .{
                b_value,
            }) catch unreachable;
            break;
        }
    }

    return partOne(allocator, instructions.items);
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    const part_one = partOne(gpa.allocator(), input_lines);

    std.debug.print("{d}\n", .{part_one});
    std.debug.print("{d}\n", .{partTwo(gpa.allocator(), input_lines, part_one)});
}

const expectEqual = std.testing.expectEqual;
test "part one examples" {
    const input_lines: []const []const u8 = &.{
        "a AND y -> d",
        "a OR y -> e",
        "a LSHIFT 2 -> f",
        "y RSHIFT 2 -> g",
        "NOT a -> h",
        "NOT y -> i",
        "123 -> a",
        "456 -> y",
    };

    try expectEqual(123, partOne(std.testing.allocator, input_lines));
}

test "part two examples" {
    const input_lines: []const []const u8 = &.{
        "a AND y -> d",
        "a OR y -> e",
        "a LSHIFT 2 -> f",
        "y RSHIFT 2 -> g",
        "NOT a -> h",
        "NOT y -> i",
        "666 -> b",
        "b AND b -> a",
        "456 -> y",
    };

    try expectEqual(123, partTwo(std.testing.allocator, input_lines, 123));
}
