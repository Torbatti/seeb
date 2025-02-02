const std = @import("std");

pub fn isString(comptime T: type) bool {
    return switch (T) {
        []const u8, []u8 => true,
        else => false,
    };
}

pub const Tag = enum(u8) {
    end = 0,
    byte = 1,
    short = 2,
    int = 3,
    long = 4,
    float = 5,
    double = 6,
    byte_array = 7,
    string = 8,
    list = 9,
    compound = 10,
    int_array = 11,
    long_array = 12,

    pub const E = error{InvalidTag};

    // TODO: which one is better? maybe none and @typeInfo
    // pub fn fromInt(val: anytype) E!Tag {
    pub fn fromInt(val: u8) E!Tag {
        // const val_convert = @as(u8, @intCast(val)); // make sure val is u8 type
        if (val >= 0 and val <= 12)
            return @enumFromInt(val)
        else
            return error.InvalidTag;
    }

    pub fn toString(tag: Tag) [:0]const u8 {
        return switch (tag) {
            .end => "TAG_End",
            .byte => "TAG_Byte",
            .short => "TAG_Short",
            .int => "TAG_Int",
            .long => "TAG_Long",
            .float => "TAG_Float",
            .double => "TAG_Double",
            .byte_array => "TAG_ByteArray",
            .string => "TAG_String",
            .list => "TAG_List",
            .compound => "TAG_Compound",
            .int_array => "TAG_IntArray",
            .long_array => "TAG_LongArray",
        };
    }
};

pub const NamedTag = struct {
    tag: Tag,
    name: []const u8,

    pub const E = error{};
};

pub fn tagFromType(comptime T: type) Tag {
    switch (@typeInfo(T)) {}
}

pub fn typeFromTag(comptime tag: Tag) type {
    return switch (tag) {
        .end => void,
        .byte => void,
        .short => void,
        .int => void,
        .long => void,
        .float => void,
        .double => void,
        .byte_array => void,
        .string => void,
        .list => void,
        .compound => void,
        .int_array => void,
        .long_array => void,
    };
}
