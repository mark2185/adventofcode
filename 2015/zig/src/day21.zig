const std = @import("std");
const utils = @import("utils");

const Item = struct {
    cost: u8 = 0,
    damage: u8 = 0,
    armor: u8 = 0,
};

const Shop = struct {
    weapons: []const Item = &.{
        .{ .cost = 8, .damage = 4, .armor = 0 },
        .{ .cost = 10, .damage = 5, .armor = 0 },
        .{ .cost = 25, .damage = 6, .armor = 0 },
        .{ .cost = 40, .damage = 7, .armor = 0 },
        .{ .cost = 74, .damage = 8, .armor = 0 },
    },
    armors: []const Item = &.{
        .{ .cost = 13, .damage = 0, .armor = 1 },
        .{ .cost = 31, .damage = 0, .armor = 2 },
        .{ .cost = 53, .damage = 0, .armor = 3 },
        .{ .cost = 75, .damage = 0, .armor = 4 },
        .{ .cost = 102, .damage = 0, .armor = 5 },
    },
    rings: []const Item = &.{
        .{ .cost = 25, .damage = 1, .armor = 0 },
        .{ .cost = 50, .damage = 2, .armor = 0 },
        .{ .cost = 100, .damage = 3, .armor = 0 },
        .{ .cost = 20, .damage = 0, .armor = 1 },
        .{ .cost = 40, .damage = 0, .armor = 2 },
        .{ .cost = 80, .damage = 0, .armor = 3 },
    },
}{};

const Player = struct {
    hitpoints: u8,
    weapon: Item = .{},
    armor: Item = .{},
    rings: []const Item = &.{},

    const Self = @This();

    fn isAlive(self: Self) bool {
        return self.hitpoints > 0;
    }

    fn attackDamage(self: Self) u8 {
        var buff: u8 = 0;
        for (self.rings) |ring| {
            buff += ring.damage;
        }
        return self.weapon.damage + self.armor.damage + buff;
    }

    fn totalArmor(self: Self) u8 {
        var buff: u8 = 0;
        for (self.rings) |ring| {
            buff += ring.armor;
        }
        return self.weapon.armor + self.armor.armor + buff;
    }

    fn equipmentCost(self: Self) usize {
        var rings_cost: usize = 0;
        for (self.rings) |ring| {
            rings_cost += ring.cost;
        }
        return self.weapon.cost + self.armor.cost + rings_cost;
    }
};

// returns the winner
fn fight(player: Player, opponent: Player) enum { p1, p2 } {
    var p1 = player;
    var p2 = opponent;
    while (p1.isAlive() and p2.isAlive()) {
        if (p1.isAlive()) {
            p2.hitpoints -|= @max(1, p1.attackDamage() -| p2.totalArmor());
        }
        if (p2.isAlive()) {
            p1.hitpoints -|= @max(1, p2.attackDamage() -| p1.totalArmor());
        }
    }

    return if (p1.isAlive()) .p1 else .p2;
}

fn parsePlayerStats(input: []const []const u8) Player {
    const hitpoints = std.fmt.parseInt(u8, input[0][12..], 10) catch unreachable;
    const damage = std.fmt.parseInt(u8, input[1][8..], 10) catch unreachable;
    const armor = std.fmt.parseInt(u8, input[2][7..], 10) catch unreachable;

    return .{
        .hitpoints = hitpoints,
        .weapon = .{ .damage = damage },
        .armor = .{ .armor = armor },
    };
}

fn partOne(input: []const []const u8) usize {
    const boss = parsePlayerStats(input);

    var min_cost: usize = std.math.maxInt(usize);
    for (Shop.weapons) |weapon| {
        for (Shop.armors) |armor| {

            // no rings
            {
                const player = Player{
                    .hitpoints = 100,
                    .weapon = weapon,
                    .armor = armor,
                };

                if (.p1 == fight(player, boss)) {
                    min_cost = @min(min_cost, player.equipmentCost());
                }
            }

            // 1 ring
            for (Shop.rings) |ring| {
                const player = Player{
                    .hitpoints = 100,
                    .weapon = weapon,
                    .armor = armor,
                    .rings = &.{ring},
                };

                if (.p1 == fight(player, boss)) {
                    min_cost = @min(min_cost, player.equipmentCost());
                }
            }

            // 2 rings
            for (0..Shop.rings.len - 1) |i| {
                const left_ring = Shop.rings[i];
                for (Shop.rings[i + 1 ..]) |right_ring| {
                    const player = Player{
                        .hitpoints = 100,
                        .weapon = weapon,
                        .armor = armor,
                        .rings = &.{ left_ring, right_ring },
                    };

                    if (.p1 == fight(player, boss)) {
                        min_cost = @min(min_cost, player.equipmentCost());
                    }
                }
            }
        }
    }

    return min_cost;
}

fn partTwo(input: []const []const u8) usize {
    const boss = parsePlayerStats(input);

    var max_cost: usize = 0;
    for (Shop.weapons) |weapon| {
        for (Shop.armors) |armor| {

            // no rings
            {
                const player = Player{
                    .hitpoints = 100,
                    .weapon = weapon,
                    .armor = armor,
                };

                if (.p2 == fight(player, boss)) {
                    max_cost = @max(max_cost, player.equipmentCost());
                }
            }

            // 1 ring
            for (Shop.rings) |ring| {
                const player = Player{
                    .hitpoints = 100,
                    .weapon = weapon,
                    .armor = armor,
                    .rings = &.{ring},
                };

                if (.p2 == fight(player, boss)) {
                    max_cost = @max(max_cost, player.equipmentCost());
                }
            }

            // 2 rings
            for (0..Shop.rings.len - 1) |i| {
                const left_ring = Shop.rings[i];
                for (Shop.rings[i + 1 ..]) |right_ring| {
                    const player = Player{
                        .hitpoints = 100,
                        .weapon = weapon,
                        .armor = armor,
                        .rings = &.{ left_ring, right_ring },
                    };

                    if (.p2 == fight(player, boss)) {
                        max_cost = @max(max_cost, player.equipmentCost());
                    }
                }
            }
        }
    }

    return max_cost;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(input_lines)});
    std.debug.print("{d}\n", .{partTwo(input_lines)});
}

test "fight example" {
    const boss = Player{ .hitpoints = 12, .weapon = .{ .damage = 7 }, .armor = .{ .armor = 2 } };
    const player = Player{ .hitpoints = 8, .weapon = .{ .damage = 5 }, .armor = .{ .armor = 5 } };

    try std.testing.expectEqual(.p1, fight(player, boss));
}
