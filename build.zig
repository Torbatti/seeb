const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const zig_version = std.SemanticVersion{
    .major = 0,
    .minor = 13,
    .patch = 0,
};
comptime {
    const zig_version_eq = zig_version.major == builtin.zig_version.major and
        zig_version.minor == builtin.zig_version.minor and
        zig_version.patch == builtin.zig_version.patch;
    if (!zig_version_eq) {
        @compileError(std.fmt.comptimePrint(
            "unsupported zig version: expected {}, found {}",
            .{ zig_version, builtin.zig_version },
        ));
    }
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    // Top-level steps you can invoke on the command line.
    const build_steps = .{
        .check = b.step("check", "Check if Seeb compiles"),
        .run = b.step("run", "Run Seeb"),
        .fuzz = b.step("fuzz", "Run fuzzers"),
        .@"test" = b.step("test", "Run all tests"),
    };

    // TODO:
    // Build options passed with `-D` flags.
    // const build_options = .{};

    const seeb_options, const seeb_module = build_seeb_module(b);

    // build seeb staticly , run seeb
    build_seeb(b, .{
        .run = build_steps.run,
        .install = b.getInstallStep(),
    }, .{
        .seeb_module = seeb_module,
        .seeb_options = seeb_options,
        .target = target,
        .mode = mode,
    });
}

fn build_seeb_module(
    b: *std.Build,
) struct { *std.Build.Step.Options, *std.Build.Module } {
    // TODO:
    const seeb_options = b.addOptions();

    const seeb_module = b.addModule("seeb", .{
        .root_source_file = b.path("src/seeb.zig"),
    });

    return .{ seeb_options, seeb_module };
}

fn build_seeb(
    b: *std.Build,
    steps: struct {
        run: *std.Build.Step,
        install: *std.Build.Step,
    },
    options: struct {
        seeb_module: *std.Build.Module,
        seeb_options: *std.Build.Step.Options,
        target: std.Build.ResolvedTarget,
        mode: std.builtin.OptimizeMode,
    },
) void {
    const seeb_exe = build_seeb_executable(b, .{
        .seeb_module = options.seeb_module,
        .seeb_options = options.seeb_options,
        .target = options.target,
        .mode = options.mode,
    });

    seeb_exe.addCSourceFile(.{
        .file = b.path("include/sqlite3.c"),
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
    seeb_exe.installHeader(b.path("include/sqlite3.h"), "sqlite3.h");

    b.installArtifact(seeb_exe);

    const run_cmd = b.addRunArtifact(seeb_exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    steps.run.dependOn(&run_cmd.step);
}

fn build_seeb_executable(b: *std.Build, options: struct {
    seeb_module: *std.Build.Module,
    seeb_options: *std.Build.Step.Options,
    target: std.Build.ResolvedTarget,
    mode: std.builtin.OptimizeMode,
}) *std.Build.Step.Compile {
    const seeb = b.addExecutable(.{
        .name = "seeb",
        .root_source_file = b.path("src/seeb/main.zig"),
        .target = options.target,
        .optimize = options.mode,
        .link_libc = true,
    });
    seeb.root_module.addImport("seeb", options.seeb_module);
    seeb.root_module.addOptions("seeb_options", options.seeb_options);

    return seeb;
}
