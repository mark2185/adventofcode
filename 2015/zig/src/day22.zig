const std = @import("std");
const utils = @import("utils");

const Spell = struct {
    damage: usize = 0,
    armor: usize = 0,
    mana_cost: usize = 0,
    mana_gain: usize = 0,
    effect_duration: usize = 0,
};

const SpellTag = enum {
    Magic_Missile,
    Drain,
    Shield,
    Poison,
    Recharge,
};

const Spells = std.EnumMap(SpellTag, Spell).init(.{
    .Magic_Missile = .{
        .damage = 4,
        .mana_cost = 53,
    },
    .Drain = .{
        .damage = 2,
        .mana_cost = 73,
    },
    .Shield = .{
        .mana_cost = 113,
        .effect_duration = 6,
        .armor = 7,
    },
    .Poison = .{
        .mana_cost = 173,
        .effect_duration = 6,
        .damage = 3,
    },
    .Recharge = .{
        .mana_cost = 229,
        .effect_duration = 5,
        .mana_gain = 101,
    },
});

const Player = struct {
    hitpoints: usize,
    damage: usize = 0,
    armor: usize = 0,
    mana: usize = 0,
    // Effect -> remaining duration
    effects: std.EnumMap(SpellTag, usize) = std.EnumMap(SpellTag, usize).init(.{
        .Shield = 0,
        .Poison = 0,
        .Recharge = 0,
    }),
    hard_mode: bool = false,

    const Self = @This();

    fn isAlive(self: Self) bool {
        return self.hitpoints > 0;
    }

    fn applyEffects(self: *Self) void {
        if (self.hard_mode) {
            self.hitpoints -|= 1;
        }
        var it = self.effects.iterator();
        while (it.next()) |*entry| {
            if (entry.value.* == 0) {
                if (entry.key == .Shield) {
                    self.armor = 0;
                }
                continue;
            }

            switch (entry.key) {
                .Poison => self.hitpoints -|= Spells.get(.Poison).?.damage,
                .Shield => self.armor = Spells.get(.Shield).?.armor,
                .Recharge => self.mana += Spells.get(.Recharge).?.mana_gain,
                else => unreachable,
            }
            entry.value.* -= 1;
        }
    }

    fn addEffect(self: *Self, effect: SpellTag) void {
        if (self.effects.get(effect) == 0) {
            self.effects.getPtr(effect).?.* = Spells.get(effect).?.effect_duration;
        }
    }

    pub fn parseStats(input: []const []const u8) Player {
        const hitpoints = std.fmt.parseInt(u8, input[0][12..], 10) catch unreachable;
        const damage = std.fmt.parseInt(u8, input[1][8..], 10) catch unreachable;

        return .{
            .hitpoints = hitpoints,
            .damage = damage,
        };
    }
};

const Turn = enum { p1, p2 };

fn simulateAllDuels(p1: Player, p2: Player, turn: Turn, min_mana_spent: *usize, mana_spent: usize) void {
    // apply all effects
    // if player's turn:
    //  - go through all spells
    //      - cast the spell
    //      - recurse
    // if boss' turn:
    //  - attack

    if (mana_spent > min_mana_spent.*) {
        return;
    }

    var affected_p1 = p1;
    var affected_p2 = p2;
    affected_p1.applyEffects();
    affected_p2.applyEffects();

    if (!affected_p1.isAlive()) {
        return;
    }
    if (!affected_p2.isAlive()) {
        min_mana_spent.* = @min(min_mana_spent.*, mana_spent);
        return;
    }

    switch (turn) {
        .p1 => {
            // TODO: fix once EnumMap has const iterators
            var it = @constCast(&Spells).iterator();
            while (it.next()) |entry| {
                if (affected_p1.mana < Spells.get(entry.key).?.mana_cost) {
                    continue;
                }

                var p1_copy = affected_p1;
                var p2_copy = affected_p2;
                switch (entry.key) {
                    .Magic_Missile => p2_copy.hitpoints -|= Spells.get(.Magic_Missile).?.damage,
                    .Drain => {
                        p2_copy.hitpoints -|= Spells.get(.Drain).?.damage;
                        p1_copy.hitpoints += Spells.get(.Drain).?.damage;
                    },
                    .Shield => p1_copy.addEffect(.Shield),
                    .Recharge => p1_copy.addEffect(.Recharge),
                    .Poison => p2_copy.addEffect(.Poison),
                }
                p1_copy.mana -|= Spells.get(entry.key).?.mana_cost;
                simulateAllDuels(p1_copy, p2_copy, .p2, min_mana_spent, mana_spent + Spells.get(entry.key).?.mana_cost);
            }
        },
        .p2 => {
            affected_p1.hitpoints -|= @max(1, affected_p2.damage -| affected_p1.armor);
            simulateAllDuels(affected_p1, affected_p2, .p1, min_mana_spent, mana_spent);
        },
    }
}

fn partOne(input: []const []const u8) usize {
    const player: Player = .{ .hitpoints = 50, .mana = 500 };
    const boss = Player.parseStats(input);
    var mana_spent: usize = std.math.maxInt(usize);
    simulateAllDuels(player, boss, .p1, &mana_spent, 0);
    return mana_spent;
}

fn partTwo(input: []const []const u8) usize {
    const player: Player = .{ .hitpoints = 50, .mana = 500, .hard_mode = true };
    const boss = Player.parseStats(input);
    var mana_spent: usize = std.math.maxInt(usize);
    simulateAllDuels(player, boss, .p1, &mana_spent, 0);
    return mana_spent;
}

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    const input_lines = try utils.readFile(gpa.allocator(), std.mem.span(std.os.argv[1]));
    defer gpa.allocator().free(input_lines);

    std.debug.print("{d}\n", .{partOne(input_lines)});
    std.debug.print("{d}\n", .{partTwo(input_lines)});
}

const expectEqual = std.testing.expectEqual;
test "part one examples" {
    var player = Player{ .hitpoints = 10, .mana = 250 };
    {
        const boss = Player{ .hitpoints = 13, .damage = 8 };

        var mana_spent: usize = std.math.maxInt(usize);
        simulateAllDuels(player, boss, .p1, &mana_spent, 0);
        try expectEqual(226, mana_spent);
    }
    {
        var boss = Player{ .hitpoints = 14, .damage = 8 };

        // player turn
        player.addEffect(.Recharge);
        player.mana -= Spells.get(.Recharge).?.mana_cost;

        // boss turn
        try expectEqual(10, player.hitpoints);
        try expectEqual(21, player.mana);
        try expectEqual(14, boss.hitpoints);

        player.applyEffects();
        boss.applyEffects();

        try expectEqual(10, player.hitpoints);
        try expectEqual(122, player.mana);
        try expectEqual(4, player.effects.get(.Recharge).?);
        try expectEqual(14, boss.hitpoints);

        player.hitpoints -|= @max(1, boss.damage -| player.armor);

        // player turn
        try expectEqual(2, player.hitpoints);
        try expectEqual(122, player.mana);
        try expectEqual(4, player.effects.get(.Recharge).?);
        try expectEqual(14, boss.hitpoints);

        player.applyEffects();
        boss.applyEffects();

        try expectEqual(2, player.hitpoints);
        try expectEqual(223, player.mana);
        try expectEqual(3, player.effects.get(.Recharge).?);
        try expectEqual(14, boss.hitpoints);

        player.addEffect(.Shield);
        player.mana -= Spells.get(.Shield).?.mana_cost;

        // boss turn
        try expectEqual(2, player.hitpoints);
        try expectEqual(110, player.mana);
        try expectEqual(0, player.armor);
        try expectEqual(3, player.effects.get(.Recharge).?);
        try expectEqual(6, player.effects.get(.Shield).?);
        try expectEqual(14, boss.hitpoints);

        player.applyEffects();
        boss.applyEffects();

        try expectEqual(2, player.hitpoints);
        try expectEqual(211, player.mana);
        try expectEqual(7, player.armor);
        try expectEqual(2, player.effects.get(.Recharge).?);
        try expectEqual(5, player.effects.get(.Shield).?);
        try expectEqual(14, boss.hitpoints);

        player.hitpoints -|= @max(1, boss.damage -| player.armor);

        // player turn
        try expectEqual(1, player.hitpoints);
        try expectEqual(211, player.mana);
        try expectEqual(7, player.armor);
        try expectEqual(2, player.effects.get(.Recharge).?);
        try expectEqual(5, player.effects.get(.Shield).?);
        try expectEqual(14, boss.hitpoints);

        player.applyEffects();
        boss.applyEffects();

        try expectEqual(1, player.hitpoints);
        try expectEqual(312, player.mana);
        try expectEqual(7, player.armor);
        try expectEqual(1, player.effects.get(.Recharge).?);
        try expectEqual(4, player.effects.get(.Shield).?);
        try expectEqual(14, boss.hitpoints);

        boss.hitpoints -|= Spells.get(.Drain).?.damage;
        player.hitpoints += Spells.get(.Drain).?.damage;
        player.mana -= Spells.get(.Drain).?.mana_cost;

        // boss turn
        try expectEqual(3, player.hitpoints);
        try expectEqual(239, player.mana);
        try expectEqual(7, player.armor);
        try expectEqual(1, player.effects.get(.Recharge).?);
        try expectEqual(4, player.effects.get(.Shield).?);
        try expectEqual(12, boss.hitpoints);

        player.applyEffects();
        boss.applyEffects();

        try expectEqual(3, player.hitpoints);
        try expectEqual(340, player.mana);
        try expectEqual(7, player.armor);
        try expectEqual(0, player.effects.get(.Recharge).?);
        try expectEqual(3, player.effects.get(.Shield).?);
        try expectEqual(12, boss.hitpoints);

        player.hitpoints -|= @max(1, boss.damage -| player.armor);

        // player turn
        try expectEqual(2, player.hitpoints);
        try expectEqual(340, player.mana);
        try expectEqual(7, player.armor);
        try expectEqual(0, player.effects.get(.Recharge));
        try expectEqual(3, player.effects.get(.Shield));
        try expectEqual(12, boss.hitpoints);

        player.applyEffects();
        boss.applyEffects();

        try expectEqual(2, player.hitpoints);
        try expectEqual(340, player.mana);
        try expectEqual(7, player.armor);
        try expectEqual(0, player.effects.get(.Recharge).?);
        try expectEqual(2, player.effects.get(.Shield).?);
        try expectEqual(12, boss.hitpoints);

        boss.addEffect(.Poison);
        player.mana -= Spells.get(.Poison).?.mana_cost;

        // boss turn
        try expectEqual(2, player.hitpoints);
        try expectEqual(167, player.mana);
        try expectEqual(7, player.armor);
        try expectEqual(2, player.effects.get(.Shield).?);
        try expectEqual(6, boss.effects.get(.Poison).?);
        try expectEqual(12, boss.hitpoints);

        player.applyEffects();
        boss.applyEffects();

        try expectEqual(2, player.hitpoints);
        try expectEqual(167, player.mana);
        try expectEqual(7, player.armor);
        try expectEqual(1, player.effects.get(.Shield).?);
        try expectEqual(5, boss.effects.get(.Poison).?);
        try expectEqual(9, boss.hitpoints);

        player.hitpoints -|= @max(1, boss.damage -| player.armor);

        // player turn
        try expectEqual(1, player.hitpoints);
        try expectEqual(167, player.mana);
        try expectEqual(7, player.armor);
        try expectEqual(1, player.effects.get(.Shield).?);
        try expectEqual(5, boss.effects.get(.Poison).?);
        try expectEqual(9, boss.hitpoints);

        player.applyEffects();
        boss.applyEffects();

        try expectEqual(1, player.hitpoints);
        try expectEqual(167, player.mana);
        try expectEqual(7, player.armor);
        try expectEqual(0, player.effects.get(.Shield).?);
        try expectEqual(4, boss.effects.get(.Poison).?);
        try expectEqual(6, boss.hitpoints);

        boss.hitpoints -|= Spells.get(.Magic_Missile).?.damage;
        player.mana -|= Spells.get(.Magic_Missile).?.mana_cost;

        // boss turn
        try expectEqual(1, player.hitpoints);
        try expectEqual(114, player.mana);
        try expectEqual(7, player.armor);
        try expectEqual(0, player.effects.get(.Shield).?);
        try expectEqual(4, boss.effects.get(.Poison).?);
        try expectEqual(2, boss.hitpoints);

        player.applyEffects();
        boss.applyEffects();

        try expectEqual(1, player.hitpoints);
        try expectEqual(114, player.mana);
        try expectEqual(0, player.armor);
        try expectEqual(0, player.effects.get(.Shield).?);
        try expectEqual(3, boss.effects.get(.Poison).?);
        try expectEqual(0, boss.hitpoints);
        try expectEqual(false, boss.isAlive());
    }
}
