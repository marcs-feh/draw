const std = @import("std");
const geo = @import("geometry.zig");

pub const Color = u32;

pub fn rgb(r: u8, g: u8, b: u8) Color {
    const rr: Color = @intCast(r);
    const gg: Color = @intCast(g);
    const bb: Color = @intCast(b);
    const aa: Color = 0xff;

    return (rr << (8 * 3)) |
        (gg << (8 * 2)) |
        (bb << (8 * 1)) |
        (aa << (8 * 0));
}

pub fn rgba(r: u8, g: u8, b: u8, a: u8) Color {
    const rr: Color = @intCast(r);
    const gg: Color = @intCast(g);
    const bb: Color = @intCast(b);
    const aa: Color = @intCast(a);

    return (rr << (8 * 3)) |
        (gg << (8 * 2)) |
        (bb << (8 * 1)) |
        (aa << (8 * 0));
}

pub const Canvas = struct {
    const Self = @This();

    data: u32,
};
