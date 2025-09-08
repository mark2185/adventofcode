const std = @import("std");
const utils = @import("utils");

fn isPasswordValid(password: []const u8) bool {
    // valid password:
    //   - must not contain the following: 'i', 'o', 'l'
    for (password) |c| {
        switch (c) {
            'i', 'o', 'l' => return false,
            else => {},
        }
    }

    // valid password:
    //   - must contain an increasing straight of at least 3 characters
    var increasing_straight: bool = false;
    for (0..password.len - 2) |i| {
        const a = password[i + 0];
        const b = password[i + 1];
        const c = password[i + 2];
        if (c == (b + 1) and b == (a + 1)) {
            increasing_straight = true;
            break;
        }
    }
    if (!increasing_straight) {
        return false;
    }

    // valid password:
    //   - must contain at least two different, non-overlapping pairs of characters
    var i: usize = 0;
    var pairs_count: u8 = 0;
    while (i < password.len - 1) : (i += 1) {
        const a = password[i];
        const b = password[i + 1];
        if (a == b) {
            pairs_count += 1;
            if (pairs_count == 2) {
                return true;
            }
            i += 1;
        }
    }
    return false;
}

fn nextPassword(password: []u8) void {
    var i: usize = password.len - 1;
    while (true) : (i -= 1) {
        password[i] = (((password[i] + 1) - 'a') % 26) + 'a';
        const carry = password[i] == 'a';
        if (!carry) {
            break;
        }
    }
}

fn partOne(allocator: std.mem.Allocator, input: []const u8) []const u8 {
    const password: []u8 = allocator.dupe(u8, input) catch unreachable;
    while (!isPasswordValid(password)) {
        nextPassword(password);
    }
    return password;
}

fn partTwo(allocator: std.mem.Allocator, input: []const u8) []const u8 {
    const password: []u8 = allocator.dupe(u8, input) catch unreachable;
    nextPassword(password);
    return partOne(allocator, password);
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    const part_one_solution = partOne(gpa.allocator(), input_lines[0]);
    const part_two_solution = partTwo(gpa.allocator(), part_one_solution);

    defer gpa.allocator().free(part_one_solution);
    defer gpa.allocator().free(part_two_solution);

    std.debug.print("{s}\n", .{part_one_solution});
    std.debug.print("{s}\n", .{part_two_solution});
}

const expectEqualStrings = std.testing.expectEqualStrings;
test "next password" {
    const test_cases = [_]struct {
        given: []const u8,
        expected: []const u8,
    }{
        .{ .given = "aaaaaaaa", .expected = "aaaaaaab" },
        .{ .given = "az", .expected = "ba" },
        .{ .given = "azz", .expected = "baa" },
    };

    for (test_cases) |test_case| {
        const input = std.testing.allocator.dupe(u8, test_case.given) catch unreachable;
        defer std.testing.allocator.free(input);

        nextPassword(input);
        try expectEqualStrings(test_case.expected, input);
    }
}

test "next valid password" {
    const test_cases = [_]struct {
        given: []const u8,
        expected: []const u8,
    }{
        .{ .given = "abcdefgh", .expected = "abcdffaa" },
        .{ .given = "ghijklmn", .expected = "ghjaabcc" },
    };

    for (test_cases) |test_case| {
        const result = partOne(std.testing.allocator, test_case.given);
        defer std.testing.allocator.free(result);

        try expectEqualStrings(test_case.expected, result);
    }
}

const expectEqual = std.testing.expectEqual;
test "validate password" {
    const test_cases = [_]struct {
        given: []const u8,
        expected: bool,
    }{
        .{ .given = "hijklmmn", .expected = false },
        .{ .given = "abbceffg", .expected = false },
        .{ .given = "abbcegjk", .expected = false },
        .{ .given = "abcdffaa", .expected = true },
    };

    for (test_cases) |test_case| {
        try expectEqual(test_case.expected, isPasswordValid(test_case.given));
    }
}
