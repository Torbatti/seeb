pub const minecraft_edition = enum(u8) {
    none = 0,
    java = 1,
    bedrock = 2,
    pocket = 3, // It was replaced by Minecraft Bedrock on November 18, 2016
    classic = 4,
};

pub const java_protocol_version = enum(u32) {
    v5 = 5, // 1.7.6 - 1.7.10
    v47 = 47, // 1.8 - 1.8.9
    v340 = 340, //1.12.2
    v498 = 498, // 1.14.4
};
