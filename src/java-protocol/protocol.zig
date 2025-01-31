// 2^21 − 1 or 2097151 bytes
pub const MAX_PACKET_SIZE: i32 = 2097152;

pub const ConnectionState = enum {
    HandShake,
    Status,
    Login,
    Transfer,
    Config,
    Play,
};
