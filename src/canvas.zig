const std = @import("std");
const geo = @import("geometry.zig");
const mem = std.mem;

pub const Canvas = struct {
    const Self = @This();

    data: []Color,
    width: usize,
    height: usize,
    allocator: mem.Allocator,

    pub fn putPixel(self: *Self, x: usize, y: usize, val: Color) void {
        const pos = x + (y * self.width);
        if (pos >= self.data.len) return;
        self.data[pos] = val;
    }

    pub fn init(width: usize, height: usize, allocator: mem.Allocator) !Self {
        var canvas = Self{
            .width = width,
            .height = height,
            .data = try allocator.alloc(Color, width * height),
            .allocator = allocator,
        };
        @memset(canvas.data, 0);
        return canvas;
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.data);
    }
};

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
