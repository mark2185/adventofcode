const std = @import("std");
const utils = @import("utils");

const Group = struct {
    items: [32]usize = @splat(0),
    len: usize = 0,
    weight: usize = 0,

    const Self = @This();

    fn append(self: *Self, element: usize) void {
        self.items[self.len] = element;
        self.len += 1;
        self.weight += element;
    }

    fn calculateQuantumNumber(self: Self) usize {
        var product: usize = 1;
        for (0..self.len) |i| {
            product *= self.items[i];
        }
        return product;
    }
};

fn findConfiguration(input: []usize, items_num: usize, target_weight: usize) usize {
    var min_quantum_entanglement: usize = std.math.maxInt(usize);
    var i: usize = 0;
    while (i < (@as(usize, 1) << @intCast(input.len))) : (i += 1) {
        if (@popCount(i) != items_num) {
            continue;
        }

        var configuration = Group{};
        for (input, 0..input.len) |item, bitIndex| {
            if (i & (@as(usize, 1) << @intCast(bitIndex)) > 0) {
                configuration.append(item);
            }
        }
        if (configuration.weight == target_weight) {
            min_quantum_entanglement = @min(min_quantum_entanglement, configuration.calculateQuantumNumber());
        }
    }
    return min_quantum_entanglement;
}

fn packPresents(allocator: std.mem.Allocator, input: []const []const u8, number_of_compartments: usize) usize {
    var transformed_input = std.ArrayList(usize).initCapacity(allocator, input.len) catch unreachable;
    defer transformed_input.deinit(allocator);

    for (input) |item| {
        transformed_input.append(allocator, std.fmt.parseInt(u8, item, 10) catch unreachable) catch unreachable;
    }

    const total_weight: usize = blk: {
        var sum: usize = 0;
        for (transformed_input.items) |x| sum += x;
        break :blk sum;
    };

    var lowest_quantum_entanglement: usize = std.math.maxInt(usize);
    for (1..input.len - 1) |i| {
        lowest_quantum_entanglement = @min(lowest_quantum_entanglement, findConfiguration(transformed_input.items, i, total_weight / number_of_compartments));
        if (lowest_quantum_entanglement != std.math.maxInt(usize)) {
            return lowest_quantum_entanglement;
        }
    }
    unreachable;
}

fn partOne(allocator: std.mem.Allocator, input: []const []const u8) usize {
    return packPresents(allocator, input, 3);
}

fn partTwo(allocator: std.mem.Allocator, input: []const []const u8) usize {
    return packPresents(allocator, input, 4);
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
    const input: []const []const u8 = &.{
        "1", "2", "3", "4", "5", "7", "8", "9", "10", "11",
    };
    try expectEqual(99, partOne(std.testing.allocator, input));
}
