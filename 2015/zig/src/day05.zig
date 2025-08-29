const std = @import("std");
const utils = @import("utils");

const Morality = enum {
    Naughty,
    Nice,
};

fn determineMoralityBasic(input: []const u8) Morality {
    // nice strings:
    //   - contain at least three vowels

    var vowel_counter: usize = 0;
    for (input) |c| {
        switch (c) {
            'a', 'e', 'i', 'o', 'u' => vowel_counter += 1,
            else => {},
        }
    }

    if (vowel_counter < 3) {
        return .Naughty;
    }

    // nice strings:
    //   - contain at least one letter that appears twice in a row

    var has_double_char: bool = false;
    for (1..input.len) |i| {
        if (input[i] == input[i - 1]) {
            has_double_char = true;
            break;
        }
    }

    if (!has_double_char) {
        return .Naughty;
    }

    // nice strings:
    //   - do not contain substrings "ab", "cd", "pq", "xy"
    const forbidden_substrings: []const []const u8 = &.{ "ab", "cd", "pq", "xy" };
    for (forbidden_substrings) |substring| {
        if (std.mem.containsAtLeast(u8, input, 1, substring)) {
            return .Naughty;
        }
    }
    return .Nice;
}

fn partOne(input: []const []const u8) usize {
    var count: usize = 0;
    for (input) |line| {
        if (line.len == 0) continue;
        if (determineMoralityBasic(line) == .Nice) {
            count += 1;
        }
    }
    return count;
}

fn determineMoralityAdvanced(input: []const u8) Morality {
    // nice strings:
    //   - contain a pair of any two letters that appears
    //     at least twice in the string without overlapping

    var has_double_pair: bool = false;
    for (1..input.len - 1) |i| {
        if (std.mem.containsAtLeast(u8, input[i + 1 ..], 1, input[i - 1 .. i + 1])) {
            has_double_pair = true;
        }
    }
    if (!has_double_pair) {
        return .Naughty;
    }

    // nice strings:
    //   - contain at least one letter which repeats with
    //     exactly one letter between them
    for (2..input.len) |i| {
        if (input[i - 2] == input[i]) {
            return .Nice;
        }
    }
    return .Naughty;
}

fn partTwo(input: []const []const u8) usize {
    var count: usize = 0;
    for (input) |line| {
        if (line.len == 0) continue;
        if (determineMoralityAdvanced(line) == .Nice) {
            count += 1;
        }
    }
    return count;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(input_lines)});
    std.debug.print("{d}\n", .{partTwo(input_lines)});
}

const expectEqual = std.testing.expectEqual;
test "part_one examples" {
    const test_cases = [_]struct {
        given: []const u8,
        expected: Morality,
    }{
        .{ .given = "ugknbfddgicrmopn", .expected = .Nice },
        .{ .given = "aaa", .expected = .Nice },
        .{ .given = "jchzalrnumimnmhp", .expected = .Naughty },
        .{ .given = "haegwjzuvuyypxyu", .expected = .Naughty },
        .{ .given = "dvszwmarrgswjxmb", .expected = .Naughty },
    };

    for (test_cases) |test_case| {
        try expectEqual(test_case.expected, determineMoralityBasic(test_case.given));
    }
}

test "part_two examples" {
    const test_cases = [_]struct {
        given: []const u8,
        expected: Morality,
    }{
        .{ .given = "qjhvhtzxzqqjkmpb", .expected = .Nice },
        .{ .given = "xxyxx", .expected = .Nice },
        .{ .given = "uurcxstgmygtbstg", .expected = .Naughty },
        .{ .given = "ieodomkazucvgmuy", .expected = .Naughty },
    };

    for (test_cases) |test_case| {
        try expectEqual(test_case.expected, determineMoralityAdvanced(test_case.given));
    }
}
