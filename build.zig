const std = @import("std");

pub fn build(b: *std.Build) void {
    // build args
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    // add tomlz as a dependency
    const tomlz = b.dependency("tomlz", .{
        .target = target,
        .optimize = optimize,
    });
    // configure EXE
    const exe = b.addExecutable(.{
        .name = "fridgeFriend",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("tomlz", tomlz.module("tomlz"));
    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
