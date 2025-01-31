const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "seeb",
        .root_source_file = b.path("src/seeb.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    // tardy
    const tardy = b.dependency("tardy", .{
        .target = target,
        .optimize = optimize,
    }).module("tardy");
    lib.root_module.addImport("tardy", tardy);

    // sqlite
    lib.addCSourceFile(.{
        .file = b.path("lib/sqlite3.c"),
        .flags = &[_][]const u8{
            // default c flags:
            "-Wall",
            "-Wextra",
            "-pedantic",
            "-std=c99",
            // "-std=c2x",

            // Recommended Compile-time Options:
            // https://www.sqlite.org/compile.html
            "-DSQLITE_DQS=0",
            "-DSQLITE_DEFAULT_WAL_SYNCHRONOUS=1",
            "-DSQLITE_USE_ALLOCA=1",
            "-DSQLITE_THREADSAFE=1",
            "-DSQLITE_TEMP_STORE=3",
            "-DSQLITE_ENABLE_API_ARMOR=1",
            "-DSQLITE_ENABLE_UNLOCK_NOTIFY",
            "-DSQLITE_ENABLE_UPDATE_DELETE_LIMIT=1",
            "-DSQLITE_DEFAULT_FILE_PERMISSIONS=0600",
            "-DSQLITE_OMIT_DECLTYPE=1",
            "-DSQLITE_OMIT_DEPRECATED=1",
            "-DSQLITE_OMIT_LOAD_EXTENSION=1",
            "-DSQLITE_OMIT_PROGRESS_CALLBACK=1",
            "-DSQLITE_OMIT_SHARED_CACHE",
            "-DSQLITE_OMIT_TRACE=1",
            "-DSQLITE_OMIT_UTF16=1",
            "-DHAVE_USLEEP=0",
        },
    });
    lib.installHeader(b.path("lib/sqlite3.h"), "sqlite3.h");

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
