const std = @import("std");
const utils = @import("utils");

fn hashMD5(input: []const u8) [std.crypto.hash.Md5.digest_length * 2]u8 {
    var h: [std.crypto.hash.Md5.digest_length]u8 = undefined;
    std.crypto.hash.Md5.hash(input, &h, .{});

    return std.fmt.bytesToHex(&h, .lower);
}

fn partOne(input: []const u8) usize {
    var buffer: [64]u8 = undefined;

    for (0..std.math.maxInt(usize)) |i| {
        const b = std.fmt.bufPrint(&buffer, "{s}{d}", .{ input[0..], i }) catch unreachable;
        const hash = hashMD5(b);

        if (std.mem.startsWith(u8, &hash, "00000")) {
            return i;
        }
    }
    unreachable;
}

fn partTwo(input: []const u8, start: usize) usize {
    var buffer: [64]u8 = undefined;

    for (start..std.math.maxInt(usize)) |i| {
        const b = std.fmt.bufPrint(&buffer, "{s}{d}", .{ input[0..], i }) catch unreachable;
        const hash = hashMD5(b);

        if (std.mem.startsWith(u8, &hash, "000000")) {
            return i;
        }
    }
    unreachable;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;

    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    const part_one = partOne(input_lines[0]);
    std.debug.print("{d}\n", .{part_one});
    std.debug.print("{d}\n", .{partTwo(input_lines[0], part_one)});
}

const expectEqual = std.testing.expectEqual;
test "hashing a string" {
    const input = "1";

    var h: [std.crypto.hash.Md5.digest_length]u8 = undefined;
    std.crypto.hash.Md5.hash(input, &h, .{});

    const expected_hex = "c4ca4238a0b923820dcc509a6f75849b";

    var expected_bytes: [expected_hex.len / 2]u8 = undefined;
    for (&expected_bytes, 0..) |*r, i| {
        r.* = std.fmt.parseInt(u8, expected_hex[2 * i .. 2 * i + 2], 16) catch unreachable;
    }
    try std.testing.expectEqualSlices(u8, &expected_bytes, &h);
}

test "hashMD5 function" {
    const input = "1";
    const expected = "c4ca4238a0b923820dcc509a6f75849b";

    try std.testing.expectEqualSlices(u8, expected, &hashMD5(input));
}

test "examples part one" {
    const tests = [_]struct {
        given: []const u8,
        expected: usize,
    }{
        .{ .given = "abcdef", .expected = 609043 },
        .{ .given = "pqrstuv", .expected = 1048970 },
    };

    for (tests) |test_case| {
        try expectEqual(test_case.expected, partOne(test_case.given));
    }
}
