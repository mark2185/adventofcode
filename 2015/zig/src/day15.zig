const std = @import("std");
const utils = @import("utils");

const Ingredient = struct {
    capacity: i64,
    durability: i64,
    flavor: i64,
    texture: i64,
    calories: i64,
};

fn parseLine(allocator: std.mem.Allocator, input: []const u8) Ingredient {
    var result = std.ArrayList([]const u8).initCapacity(allocator, 1) catch unreachable;
    defer result.deinit(allocator);

    var it = std.mem.splitScalar(u8, input, ' ');
    while (it.next()) |e| {
        result.append(allocator, std.mem.trimRight(u8, e, ",")) catch unreachable;
    }

    return .{
        .capacity = std.fmt.parseInt(i64, result.items[2], 10) catch unreachable,
        .durability = std.fmt.parseInt(i64, result.items[4], 10) catch unreachable,
        .flavor = std.fmt.parseInt(i64, result.items[6], 10) catch unreachable,
        .texture = std.fmt.parseInt(i64, result.items[8], 10) catch unreachable,
        .calories = std.fmt.parseInt(i64, result.items[10], 10) catch unreachable,
    };
}

const Recipe = struct {
    ingredients: []const Ingredient,
    amounts: []u8,

    const Generator = struct {
        recipe: *Recipe,

        pub fn next(self: *Generator) ?Recipe {
            for (self.recipe.amounts) |*amount| {
                amount.* += 1;
                const carry = amount.* == 100;
                if (!carry) {
                    break;
                }
            }

            var has_next: bool = false;
            for (self.recipe.amounts) |amount| {
                if (amount != 100) {
                    has_next = true;
                    break;
                }
            }
            if (!has_next) {
                return null;
            }
            return self.recipe.normalize();
        }
    };

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, ingredients: []const Ingredient) Self {
        var amounts = std.ArrayList(u8).initCapacity(allocator, ingredients.len) catch unreachable;
        amounts.appendNTimes(allocator, 1, ingredients.len) catch unreachable;

        return .{
            .ingredients = ingredients,
            .amounts = amounts.toOwnedSlice(allocator) catch unreachable,
        };
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        allocator.free(self.amounts);
    }

    pub fn generator(self: *Self) Generator {
        return .{
            .recipe = self,
        };
    }

    fn normalize(self: *Self) Self {
        for (self.amounts) |*amount| {
            amount.* %= 100;
        }
        return self.*;
    }

    pub fn isValid(self: Self) bool {
        var total: usize = 0;
        for (self.amounts) |amount| {
            total += amount;
        }
        return total == 100;
    }

    pub fn calorieCount(self: Self) i64 {
        var total_calories: i64 = 0;
        for (self.ingredients, self.amounts) |ingredient, amount| {
            total_calories += amount * ingredient.calories;
        }
        return total_calories;
    }

    pub fn evaluate(self: Self) usize {
        var total_capacity: i64 = 0;
        var total_durability: i64 = 0;
        var total_flavor: i64 = 0;
        var total_texture: i64 = 0;
        for (self.ingredients, self.amounts) |ingredient, amount| {
            total_capacity += amount * ingredient.capacity;
            total_durability += amount * ingredient.durability;
            total_flavor += amount * ingredient.flavor;
            total_texture += amount * ingredient.texture;
        }
        if (total_capacity <= 0 or total_durability <= 0 or total_flavor <= 0 or total_texture <= 0) {
            return 0;
        }
        return @intCast(total_capacity * total_durability * total_flavor * total_texture);
    }
};

fn partOne(allocator: std.mem.Allocator, input_lines: []const []const u8) usize {
    var ingredients = std.ArrayList(Ingredient).initCapacity(allocator, 4) catch unreachable;
    defer ingredients.deinit(allocator);

    for (input_lines) |line| {
        ingredients.append(allocator, parseLine(allocator, line)) catch unreachable;
    }

    var recipe = Recipe.init(allocator, ingredients.items);
    defer recipe.deinit(allocator);

    var gen = recipe.generator();
    var max_score: usize = 0;
    while (gen.next()) |r| {
        if (!r.isValid()) {
            continue;
        }
        max_score = @max(max_score, r.evaluate());
    }
    return max_score;
}

fn partTwo(allocator: std.mem.Allocator, input_lines: []const []const u8) usize {
    var ingredients = std.ArrayList(Ingredient).initCapacity(allocator, 4) catch unreachable;
    defer ingredients.deinit(allocator);

    for (input_lines) |line| {
        ingredients.append(allocator, parseLine(allocator, line)) catch unreachable;
    }

    var recipe = Recipe.init(allocator, ingredients.items);
    defer recipe.deinit(allocator);

    var gen = recipe.generator();
    var max_score: usize = 0;
    while (gen.next()) |r| {
        if (!r.isValid() or r.calorieCount() != 500) {
            continue;
        }
        max_score = @max(max_score, r.evaluate());
    }
    return max_score;
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
    const input_lines: []const []const u8 = &.{
        "Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8",
        "Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3",
    };

    try expectEqual(62842880, partOne(std.testing.allocator, input_lines));
}

test "part two examples" {
    const input_lines: []const []const u8 = &.{
        "Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8",
        "Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3",
    };

    try expectEqual(57600000, partTwo(std.testing.allocator, input_lines));
}

test "generator test" {
    const ingredients: []const Ingredient = &.{
        .{ .capacity = 0, .durability = 3, .flavor = 6, .texture = 9, .calories = 12 },
        .{ .capacity = 0, .durability = 2, .flavor = 4, .texture = 6, .calories = 8 },
    };
    var recipe = Recipe.init(std.testing.allocator, ingredients);
    defer recipe.deinit(std.testing.allocator);

    for (recipe.amounts) |ing| {
        std.debug.print("{any}\n", .{ing});
    }

    var gen = recipe.generator();

    const next_recipe = gen.next().?;

    try std.testing.expect(std.mem.eql(u8, &.{ 2, 1 }, next_recipe.amounts));
}
