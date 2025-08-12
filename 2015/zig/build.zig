const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const utils = b.addModule("utils", .{
        .root_source_file = b.path("utils.zig"),
    });

    const exe01 = b.addExecutable(.{
        .name = "01",
        .root_source_file = b.path("01/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe01.root_module.addImport("utils", utils);
    b.installArtifact(exe01);

    const exe02 = b.addExecutable(.{
        .name = "02",
        .root_source_file = b.path("02/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe02.root_module.addImport("utils", utils);
    b.installArtifact(exe02);

    const exe03 = b.addExecutable(.{
        .name = "03",
        .root_source_file = b.path("03/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe03.root_module.addImport("utils", utils);
    b.installArtifact(exe03);
}
