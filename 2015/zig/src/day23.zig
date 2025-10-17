const std = @import("std");
const utils = @import("utils");

const Computer = struct {
    const Register = enum { a, b };
    const Opcode = enum { hlf, tpl, inc, jmp, jie, jio };

    registers: std.EnumArray(Register, usize) = std.EnumArray(Register, usize).initFill(0),

    program_counter: i64 = 0,

    const Self = @This();

    pub fn decode_instruction(instruction: []const u8) struct { opcode: Opcode, args: [2][]const u8 } {
        var it = std.mem.splitScalar(u8, instruction, ' ');
        const op = it.next().?;
        if (std.mem.eql(u8, op, "hlf")) {
            return .{
                .opcode = .hlf,
                .args = .{ it.next().?, undefined },
            };
        } else if (std.mem.eql(u8, op, "tpl")) {
            return .{
                .opcode = .tpl,
                .args = .{ it.next().?, undefined },
            };
        } else if (std.mem.eql(u8, op, "inc")) {
            return .{
                .opcode = .inc,
                .args = .{ it.next().?, undefined },
            };
        } else if (std.mem.eql(u8, op, "jmp")) {
            return .{
                .opcode = .jmp,
                .args = .{ it.next().?, undefined },
            };
        } else if (std.mem.eql(u8, op, "jie")) {
            return .{
                .opcode = .jie,
                .args = .{ it.next().?, it.next().? },
            };
        } else if (std.mem.eql(u8, op, "jio")) {
            return .{
                .opcode = .jio,
                .args = .{ it.next().?, it.next().? },
            };
        }
        unreachable;
    }

    fn jmp(self: *Self, arg: []const u8) void {
        const offset = std.fmt.parseInt(i8, arg, 10) catch unreachable;
        self.program_counter += offset;
    }

    fn jie(self: *Self, arg1: []const u8, arg2: []const u8) void {
        const register = if (arg1[0] == 'a') Register.a else Register.b;
        const offset = if (self.registers.get(register) % 2 == 1) 1 else std.fmt.parseInt(i8, arg2, 10) catch unreachable;
        self.program_counter += offset;
    }

    fn jio(self: *Self, arg1: []const u8, arg2: []const u8) void {
        const register = if (arg1[0] == 'a') Register.a else Register.b;
        const offset = if (self.registers.get(register) != 1) 1 else std.fmt.parseInt(i8, arg2, 10) catch unreachable;
        self.program_counter += offset;
    }

    fn inc(self: *Self, arg: []const u8) void {
        const register = if (arg[0] == 'a') Register.a else Register.b;
        self.registers.getPtr(register).* += 1;
    }

    fn hlf(self: *Self, arg: []const u8) void {
        const register = if (arg[0] == 'a') Register.a else Register.b;
        self.registers.getPtr(register).* /= 2;
    }

    fn tpl(self: *Self, arg: []const u8) void {
        const register = if (arg[0] == 'a') Register.a else Register.b;
        self.registers.getPtr(register).* *= 3;
    }

    fn run_program(self: *Self, input: []const []const u8) void {
        self.program_counter = 0;
        while (self.program_counter < input.len) {
            const instruction = Computer.decode_instruction(input[@intCast(self.program_counter)]);
            switch (instruction.opcode) {
                .jmp => {
                    self.jmp(instruction.args[0]);
                    continue;
                },
                .jie => {
                    self.jie(instruction.args[0], instruction.args[1]);
                    continue;
                },
                .jio => {
                    self.jio(instruction.args[0], instruction.args[1]);
                    continue;
                },
                .inc => self.inc(instruction.args[0]),
                .hlf => self.hlf(instruction.args[0]),
                .tpl => self.tpl(instruction.args[0]),
            }
            self.program_counter += 1;
        }
    }
};

fn partOne(input: []const []const u8) usize {
    var comp = Computer{};

    comp.run_program(input);

    return comp.registers.get(.b);
}

fn partTwo(input: []const []const u8) usize {
    var comp = Computer{};

    comp.registers.getPtr(.a).* = 1;

    comp.run_program(input);

    return comp.registers.get(.b);
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
    const input_lines: []const []const u8 = &.{
        "inc a",
        "jio a, +2",
        "tpl a",
        "inc a",
    };

    var comp = Computer{};

    comp.run_program(input_lines);

    try expectEqual(2, comp.registers.get(.a));
    try expectEqual(0, comp.registers.get(.b));
}

test "inc" {
    var comp = Computer{
        .registers = std.EnumArray(Computer.Register, usize).initFill(5),
    };

    comp.run_program(&.{"inc a"});

    try expectEqual(6, comp.registers.get(.a));
    try expectEqual(5, comp.registers.get(.b));

    comp.run_program(&.{"inc b"});

    try expectEqual(6, comp.registers.get(.a));
    try expectEqual(6, comp.registers.get(.b));
}

test "tpl" {
    var comp = Computer{
        .registers = std.EnumArray(Computer.Register, usize).initFill(5),
    };

    comp.run_program(&.{"tpl a"});

    try expectEqual(15, comp.registers.get(.a));
    try expectEqual(5, comp.registers.get(.b));

    comp.run_program(&.{"tpl b"});

    try expectEqual(15, comp.registers.get(.a));
    try expectEqual(15, comp.registers.get(.b));
}

test "hlf" {
    var comp = Computer{
        .registers = std.EnumArray(Computer.Register, usize).initFill(6),
    };

    comp.run_program(&.{"hlf a"});

    try expectEqual(3, comp.registers.get(.a));
    try expectEqual(6, comp.registers.get(.b));
}

test "jmp" {
    var comp = Computer{
        .registers = std.EnumArray(Computer.Register, usize).initFill(7),
    };

    comp.run_program(&.{"jmp +6"});

    try expectEqual(6, comp.program_counter);
}

test "jio" {
    var comp = Computer{
        .registers = std.EnumArray(Computer.Register, usize).initFill(6),
    };

    comp.run_program(&.{"jio a +6"});

    try expectEqual(1, comp.program_counter);

    comp.registers.getPtr(.a).* = 1;

    comp.run_program(&.{"jio a +6"});

    try expectEqual(6, comp.program_counter);
}

test "jie" {
    var comp = Computer{
        .registers = std.EnumArray(Computer.Register, usize).initFill(1),
    };

    comp.run_program(&.{"jie a +6"});

    try expectEqual(1, comp.program_counter);

    comp.registers.getPtr(.a).* = 0;

    comp.run_program(&.{"jie a +6"});

    try expectEqual(6, comp.program_counter);
}
