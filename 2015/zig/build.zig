const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const utils = b.addModule("utils", .{
        .root_source_file = b.path("utils.zig"),
    });

    var sources = std.ArrayList([]const u8).init(b.allocator);
    {
        var dir = try std.fs.cwd().openDir("src", .{ .iterate = true });
        defer dir.close();

        var walker = dir.iterate();

        while (try walker.next()) |entry| {
            try sources.append(entry.name);
        }
    }

    for (sources.items) |source| {
        const exe = b.addExecutable(.{
            .name = source,
            .root_source_file = b.path(b.pathJoin(&.{ "src", source })),
            .target = target,
            .optimize = optimize,
        });

        exe.root_module.addImport("utils", utils);
        b.installArtifact(exe);
    }
}
