const std = @import("std");
const utils = @import("utils");

const Aunt = struct {
    children: ?usize = null,
    cats: ?usize = null,
    samoyeds: ?usize = null,
    pomeranians: ?usize = null,
    akitas: ?usize = null,
    vizslas: ?usize = null,
    goldfish: ?usize = null,
    trees: ?usize = null,
    cars: ?usize = null,
    perfumes: ?usize = null,
};

fn parseLine(line: []const u8) Aunt {
    var trimmed_line: []const u8 = undefined;
    for (line, 0..) |c, i| {
        if (c == ':') {
            trimmed_line = line[i + 2 .. line.len];
            break;
        }
    }

    var it = std.mem.splitSequence(u8, trimmed_line, ", ");
    var aunt: Aunt = .{};
    while (it.next()) |field| {
        var field_it = std.mem.splitSequence(u8, field, ": ");
        const key = field_it.next().?;
        const val = std.fmt.parseInt(u8, field_it.next().?, 10) catch unreachable;

        if (std.mem.eql(u8, "children", key)) {
            aunt.children = val;
        } else if (std.mem.eql(u8, "cats", key)) {
            aunt.cats = val;
        } else if (std.mem.eql(u8, "samoyeds", key)) {
            aunt.samoyeds = val;
        } else if (std.mem.eql(u8, "pomeranians", key)) {
            aunt.pomeranians = val;
        } else if (std.mem.eql(u8, "akitas", key)) {
            aunt.akitas = val;
        } else if (std.mem.eql(u8, "vizslas", key)) {
            aunt.vizslas = val;
        } else if (std.mem.eql(u8, "goldfish", key)) {
            aunt.goldfish = val;
        } else if (std.mem.eql(u8, "trees", key)) {
            aunt.trees = val;
        } else if (std.mem.eql(u8, "cars", key)) {
            aunt.cars = val;
        } else if (std.mem.eql(u8, "perfumes", key)) {
            aunt.perfumes = val;
        }
    }
    return aunt;
}

fn partOne(input_lines: []const []const u8) usize {
    const real_aunt: Aunt = .{
        .children = 3,
        .cats = 7,
        .samoyeds = 2,
        .pomeranians = 3,
        .akitas = 0,
        .vizslas = 0,
        .goldfish = 5,
        .trees = 3,
        .cars = 2,
        .perfumes = 1,
    };

    var potential_aunt: usize = 0;
    for (input_lines, 0..) |line, i| {
        const possible_aunt = parseLine(line);
        if (possible_aunt.children != null and possible_aunt.children.? != real_aunt.children) {
            continue;
        } else if (possible_aunt.cats != null and possible_aunt.cats.? != real_aunt.cats) {
            continue;
        } else if (possible_aunt.samoyeds != null and possible_aunt.samoyeds.? != real_aunt.samoyeds) {
            continue;
        } else if (possible_aunt.pomeranians != null and possible_aunt.pomeranians.? != real_aunt.pomeranians) {
            continue;
        } else if (possible_aunt.akitas != null and possible_aunt.akitas.? != real_aunt.akitas) {
            continue;
        } else if (possible_aunt.vizslas != null and possible_aunt.vizslas.? != real_aunt.vizslas) {
            continue;
        } else if (possible_aunt.goldfish != null and possible_aunt.goldfish.? != real_aunt.goldfish) {
            continue;
        } else if (possible_aunt.trees != null and possible_aunt.trees.? != real_aunt.trees) {
            continue;
        } else if (possible_aunt.cars != null and possible_aunt.cars.? != real_aunt.cars) {
            continue;
        } else if (possible_aunt.perfumes != null and possible_aunt.perfumes.? != real_aunt.perfumes) {
            continue;
        }
        potential_aunt = i + 1;
    }
    return potential_aunt;
}

fn partTwo(input_lines: []const []const u8) usize {
    const real_aunt: Aunt = .{
        .children = 3,
        .cats = 7,
        .samoyeds = 2,
        .pomeranians = 3,
        .akitas = 0,
        .vizslas = 0,
        .goldfish = 5,
        .trees = 3,
        .cars = 2,
        .perfumes = 1,
    };

    var potential_aunt: usize = 0;
    for (input_lines, 0..) |line, i| {
        const possible_aunt = parseLine(line);
        if (possible_aunt.children != null and possible_aunt.children.? != real_aunt.children) {
            continue;
        } else if (possible_aunt.cats != null and possible_aunt.cats.? <= real_aunt.cats.?) {
            continue;
        } else if (possible_aunt.samoyeds != null and possible_aunt.samoyeds.? != real_aunt.samoyeds) {
            continue;
        } else if (possible_aunt.pomeranians != null and possible_aunt.pomeranians.? >= real_aunt.pomeranians.?) {
            continue;
        } else if (possible_aunt.akitas != null and possible_aunt.akitas.? != real_aunt.akitas) {
            continue;
        } else if (possible_aunt.vizslas != null and possible_aunt.vizslas.? != real_aunt.vizslas) {
            continue;
        } else if (possible_aunt.goldfish != null and possible_aunt.goldfish.? >= real_aunt.goldfish.?) {
            continue;
        } else if (possible_aunt.trees != null and possible_aunt.trees.? <= real_aunt.trees.?) {
            continue;
        } else if (possible_aunt.cars != null and possible_aunt.cars.? != real_aunt.cars) {
            continue;
        } else if (possible_aunt.perfumes != null and possible_aunt.perfumes.? != real_aunt.perfumes) {
            continue;
        }
        potential_aunt = i + 1;
    }
    return potential_aunt;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(input_lines)});
    std.debug.print("{d}\n", .{partTwo(input_lines)});
}
