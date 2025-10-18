const std = @import("std");
const utils = @import("utils");

const Direction = enum(u3) {
    North,
    East,
    South,
    West,

    fn rotate(direction: Direction, rotation: u8) Direction {
        const num: i8 = if (rotation == 'R') 1 else -1;
        return @enumFromInt(@mod(@intFromEnum(direction) + num, 4));
    }
};

fn partOne(input: []const u8) usize {
    var x: i64 = 0;
    var y: i64 = 0;
    var direction = Direction.North;

    var it = std.mem.splitSequence(u8, input, ", ");
    while (it.next()) |instruction| {
        direction = direction.rotate(instruction[0]);
        const steps = std.fmt.parseInt(u32, instruction[1..], 10) catch unreachable;
        switch (direction) {
            .North => y -= steps,
            .East => x += steps,
            .South => y += steps,
            .West => x -= steps,
        }
    }

    return @abs(y) + @abs(x);
}

fn partTwo(allocator: std.mem.Allocator, input: []const u8) usize {
    var x: i64 = 0;
    var y: i64 = 0;
    var direction = Direction.North;

    var it = std.mem.splitSequence(u8, input, ", ");
    var visited_locations = std.AutoHashMap([2]i64, void).init(allocator);
    defer visited_locations.deinit();

    while (it.next()) |instruction| {
        direction = direction.rotate(instruction[0]);
        const steps = std.fmt.parseInt(u32, instruction[1..], 10) catch unreachable;
        for (0..steps) |_| {
            switch (direction) {
                .North => y -= 1,
                .East => x += 1,
                .South => y += 1,
                .West => x -= 1,
            }
            if (visited_locations.contains(.{ x, y })) {
                return @abs(x) + @abs(y);
            }
            visited_locations.put(.{ x, y }, {}) catch unreachable;
        }
    }
    unreachable;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(input_lines[0])});
    std.debug.print("{d}\n", .{partTwo(gpa.allocator(), input_lines[0])});
}

const expectEqual = std.testing.expectEqual;
test "part one examples" {
    try expectEqual(0, partOne("R5, R5, R5, R5"));
    try expectEqual(5, partOne("R2, L3"));
    try expectEqual(2, partOne("R2, R2, R2"));
    try expectEqual(12, partOne("R5, L5, R5, R3"));
}

test "part two examples" {
    try expectEqual(4, partTwo(std.testing.allocator, "R8, R4, R4, R8"));
}
