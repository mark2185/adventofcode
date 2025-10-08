const std = @import("std");
const utils = @import("utils");

fn mutate(allocator: std.mem.Allocator, formula: []const u8, index: usize, original: []const u8, replacement: []const u8) []const u8 {
    var molecule = std.ArrayList(u8).empty;
    defer molecule.deinit(allocator);

    molecule.appendSlice(allocator, formula[0..index]) catch unreachable;
    molecule.appendSlice(allocator, replacement) catch unreachable;

    const replaced_text_length = original.len;
    if (index + replaced_text_length < formula.len) {
        molecule.appendSlice(allocator, formula[index + replaced_text_length ..]) catch unreachable;
    }
    return molecule.toOwnedSlice(allocator) catch unreachable;
}

fn partOne(allocator: std.mem.Allocator, input_lines: []const []const u8) usize {
    var replacements = std.StringHashMap(std.ArrayList([]const u8)).init(allocator);
    for (input_lines[0 .. input_lines.len - 1]) |line| {
        var it = std.mem.splitSequence(u8, line, " => ");
        const lhs = it.next().?;
        const rhs = it.next().?;

        var entry = replacements.getOrPutValue(lhs, std.ArrayList([]const u8).empty) catch unreachable;
        entry.value_ptr.append(allocator, rhs) catch unreachable;
    }
    defer {
        var it = replacements.valueIterator();
        while (it.next()) |value| {
            value.deinit(allocator);
        }
        replacements.deinit();
    }

    var molecules = std.StringHashMap(void).init(allocator);
    defer {
        var it = molecules.keyIterator();
        while (it.next()) |key| {
            allocator.free(key.*);
        }
        molecules.deinit();
    }

    const formula = input_lines[input_lines.len - 1];

    for (0..formula.len) |i| {
        var it = replacements.iterator();
        while (it.next()) |entry| {
            const original = entry.key_ptr.*;
            if (!std.mem.startsWith(u8, formula[i..], original)) {
                continue;
            }

            for (entry.value_ptr.items) |replacement| {
                const molecule = mutate(allocator, formula, i, original, replacement);
                if (!molecules.contains(molecule)) {
                    molecules.put(molecule, {}) catch unreachable;
                } else {
                    allocator.free(molecule);
                }
            }
        }
    }
    return molecules.count();
}

fn partTwo(allocator: std.mem.Allocator, input_lines: []const []const u8) usize {
    var replacements = std.StringHashMap([]const u8).init(allocator);
    defer replacements.deinit();

    // parse the replacements in the opposite direction,
    // e.g. "Ca => SiTh" will take 'SiTh' as the key and 'Ca' as the value
    // since every right hand side molecule can be created from only one other molecule,
    // the input is in the form of 1:N
    for (input_lines[0 .. input_lines.len - 1]) |line| {
        var it = std.mem.splitSequence(u8, line, " => ");
        const lhs = it.next().?;
        const rhs = it.next().?;

        replacements.put(rhs, lhs) catch unreachable;
    }

    var keys = std.ArrayList([]const u8).initCapacity(allocator, replacements.count()) catch unreachable;
    defer keys.deinit(allocator);

    var keys_it = replacements.keyIterator();
    while (keys_it.next()) |key| {
        keys.append(allocator, key.*) catch unreachable;
    }

    // put the longest possible match first
    std.mem.sort([]const u8, keys.items, {}, struct {
        pub fn inner(_: void, lhs: []const u8, rhs: []const u8) bool {
            return lhs.len > rhs.len;
        }
    }.inner);

    const initial_formula = input_lines[input_lines.len - 1];
    var working_formula = allocator.dupe(u8, initial_formula) catch unreachable;
    defer allocator.free(working_formula);

    // the plan:
    //   - go through all the keys, starting from the longest one
    //   - replace all occurences of it with its replacement molecule
    //   - go to the next key

    var prng = std.Random.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        std.posix.getrandom(std.mem.asBytes(&seed)) catch unreachable;
        break :blk seed;
    });
    const rand = prng.random();

    var count: u8 = 0;
    while (!std.mem.eql(u8, working_formula, "e")) {
        var mutations_count: usize = 0;
        for (keys.items) |original| {
            while (true) {
                var has_mutated = false;

                for (0..working_formula.len) |i| {
                    if (!std.mem.startsWith(u8, working_formula[i..], original)) {
                        continue;
                    }

                    has_mutated = true;
                    mutations_count += 1;

                    const r = replacements.get(original).?;
                    const tmp = mutate(allocator, working_formula, i, original, r);
                    allocator.free(working_formula);
                    working_formula = @constCast(tmp);
                    count += 1;
                    break;
                }

                if (!has_mutated) {
                    break;
                }
            }
        }

        if (mutations_count == 0) {
            allocator.free(working_formula);
            working_formula = @constCast(initial_formula);
            rand.shuffle([]const u8, keys.items);
        }
    }

    return count;
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
    const test_cases = [_]struct {
        given: []const []const u8,
        expected: usize,
    }{
        .{ .given = &.{ "H => HO", "H => OH", "O => HH", "HOH" }, .expected = 4 },
        .{ .given = &.{ "H => HO", "H => OH", "O => HH", "HOHOHO" }, .expected = 7 },
    };

    for (test_cases) |test_case| {
        try expectEqual(test_case.expected, partOne(std.testing.allocator, test_case.given));
    }
}

test "part two examples" {
    const test_cases = [_]struct {
        given: []const []const u8,
        expected: usize,
    }{
        .{ .given = &.{ "e => H", "e => O", "H => HO", "H => OH", "O => HH", "HOH" }, .expected = 3 },
        // .{ .given = &.{ "e => H", "e => O", "H => HO", "H => OH", "O => HH", "HOHOHO" }, .expected = 6 },
    };

    for (test_cases) |test_case| {
        try expectEqual(test_case.expected, partTwo(std.testing.allocator, test_case.given));
    }
}
