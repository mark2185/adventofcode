const std = @import("std");
const utils = @import("utils");

fn nextCode(code: usize) usize {
    return (code * 252533) % 33554393;
}

fn partOne(input: []const u8) usize {
    var it = std.mem.tokenizeAny(u8, input, "., abcdefghijklmnopqrstuvwxyzTE");
    const solution_row = std.fmt.parseInt(usize, it.next().?, 10) catch unreachable;
    const solution_col = std.fmt.parseInt(usize, it.next().?, 10) catch unreachable;

    var current_code: usize = 20151125;
    var x: usize = 0;
    var y: usize = 0;
    while (!(x + 1 == solution_col and y + 1 == solution_row)) {
        if (y == 0) {
            y = x + 1;
            x = 0;
        } else {
            y -= 1;
            x += 1;
        }
        current_code = nextCode(current_code);
    }
    return current_code;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    const input = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input);

    std.debug.print("{d}\n", .{partOne(input[0])});
}

const expectEqual = std.testing.expectEqual;
test "part one examples" {
    {
        const input = "To continue, please consult the code grid in the manual.  Enter the code at row 1, column 1.";
        try expectEqual(20151125, partOne(input));
    }
    {
        const input = "To continue, please consult the code grid in the manual.  Enter the code at row 2, column 1.";
        try expectEqual(31916031, partOne(input));
    }
    {
        const input = "To continue, please consult the code grid in the manual.  Enter the code at row 5, column 3.";
        try expectEqual(28094349, partOne(input));
    }
}
