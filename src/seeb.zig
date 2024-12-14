const std = @import("std");

const Allocator = std.mem.Allocator;

pub const sqlite = @import("sqlite");

const seeb_version = std.SemanticVersion{
    .major = 0,
    .minor = 1,
    .patch = 0,
};
