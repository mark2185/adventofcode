const std = @import("std");
const utils = @import("utils");

const Finger = struct {
    x: usize,
    y: usize,
};

fn inputPasscode(input: []const []const u8, output: []u8, keypad: []const []const u8, start: struct { x: usize, y: usize }) void {
    var x: usize = start.x;
    var y: usize = start.y;
    for (input, 0..) |line, i| {
        for (line) |move| {
            switch (move) {
                'U' => if (keypad[y - 1][x] != 'x') {
                    y -= 1;
                },
                'D' => if (keypad[y + 1][x] != 'x') {
                    y += 1;
                },
                'L' => if (keypad[y][x - 1] != 'x') {
                    x -= 1;
                },
                'R' => if (keypad[y][x + 1] != 'x') {
                    x += 1;
                },
                else => unreachable,
            }
        }
        output[i] = keypad[y][x];
    }
}

fn partOne(input: []const []const u8, output: []u8) void {
    const keypad: []const []const u8 = &.{
        "xxxxx",
        "x123x",
        "x456x",
        "x789x",
        "xxxxx",
    };

    inputPasscode(input, output, keypad, .{ .x = 2, .y = 2 });
}

fn partTwo(input: []const []const u8, output: []u8) void {
    const keypad: []const []const u8 = &.{
        "xxxxxxx",
        "xxx1xxx",
        "xx234xx",
        "x56789x",
        "xxABCxx",
        "xxxDxxx",
        "xxxxxxx",
    };

    inputPasscode(input, output, keypad, .{ .x = 1, .y = 3 });
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    const input = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input);

    var passcode: [8]u8 = @splat(0);
    partOne(input, &passcode);
    std.debug.print("{s}\n", .{passcode[0..input.len]});

    partTwo(input, &passcode);
    std.debug.print("{s}\n", .{passcode[0..input.len]});
}

const expectEqualStrings = std.testing.expectEqualStrings;
test "part one examples" {
    const input = &.{
        "ULL",
        "RRDDD",
        "LURDL",
        "UUUUD",
    };

    var passcode: [8]u8 = @splat(0);
    partOne(input, &passcode);
    try expectEqualStrings("1985", passcode[0..input.len]);
}

test "part two examples" {
    const input = &.{
        "ULL",
        "RRDDD",
        "LURDL",
        "UUUUD",
    };

    var passcode: [8]u8 = @splat(0);
    partTwo(input, &passcode);
    try expectEqualStrings("5DB3", passcode[0..input.len]);
}
