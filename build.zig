const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "seeb",
        .root_source_file = b.path("src/seeb.zig"),
        .target = target,
        .optimize = optimize,
    });

    const tardy = b.dependency("tardy", .{
        .target = target,
        .optimize = optimize,
    }).module("tardy");
    lib.root_module.addImport("tardy", tardy);
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "seeb",
        .root_source_file = b.path("src/seeb/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("seeb", &lib.root_module);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
