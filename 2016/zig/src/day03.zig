const std = @import("std");
const utils = @import("utils");

fn partOne(input: []const []const u8) usize {
    var possible: usize = 0;
    for (input) |line| {
        var it = std.mem.tokenizeScalar(u8, line, ' ');
        const a = std.fmt.parseInt(usize, it.next().?, 10) catch unreachable;
        const b = std.fmt.parseInt(usize, it.next().?, 10) catch unreachable;
        const c = std.fmt.parseInt(usize, it.next().?, 10) catch unreachable;

        if (a + b > c and a + c > b and b + c > a) {
            possible += 1;
        }
    }
    return possible;
}

fn partTwo(input: []const []const u8) usize {
    var possible: usize = 0;
    var i: usize = 0;
    while (i < input.len) : (i += 3) {
        const line1 = input[i + 0];
        const line2 = input[i + 1];
        const line3 = input[i + 2];

        var it1 = std.mem.tokenizeScalar(u8, line1, ' ');
        var it2 = std.mem.tokenizeScalar(u8, line2, ' ');
        var it3 = std.mem.tokenizeScalar(u8, line3, ' ');

        for (0..3) |_| {
            const a = std.fmt.parseInt(usize, it1.next().?, 10) catch unreachable;
            const b = std.fmt.parseInt(usize, it2.next().?, 10) catch unreachable;
            const c = std.fmt.parseInt(usize, it3.next().?, 10) catch unreachable;
            if (a + b > c and a + c > b and b + c > a) {
                possible += 1;
            }
        }
    }
    return possible;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    const input = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input);

    std.debug.print("{d}\n", .{partOne(input)});
    std.debug.print("{d}\n", .{partTwo(input)});
}

const expectEqual = std.testing.expectEqual;
test "part one examples" {
    const input = &.{
        "1 1 2",
        "3 4 5",
    };

    try expectEqual(1, partOne(input));
}
