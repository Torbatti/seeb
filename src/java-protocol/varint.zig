pub fn VarInt(comptime I: type) type {
    const info = @typeInfo(I).Int;

    return struct {
        pub const E = error{};

        pub fn read() !void {}
        pub fn write() !void {}
    };
}
