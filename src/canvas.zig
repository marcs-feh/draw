const std = @import("std");
const geo = @import("geometry.zig");
const mem = std.mem;

pub const Canvas = struct {
    const Self = @This();

    data: []Color,
    width: usize,
    height: usize,
    allocator: mem.Allocator,

    fn realToCanvas(self: Canvas, p: geo.Vec2) [2]usize {
        const rw: geo.Real = @floatFromInt(self.width - 1);
        const rh: geo.Real = @floatFromInt(self.height - 1);

        const cx = p[0] * (rw / 2);
        const cy = p[1] * (rh / 2);

        var cv_coord = geo.Vec2{
            (rw / 2) + cx,
            (rh / 2) - cy,
        };

        // To account for float error, explictly clamp
        // rpos[0] = if (rpos[0] == 1) rw else if (rpos[0] == 0) 0 else rpos[0];
        //
        // rpos[1] = if (rpos[1] == 1) 0 else if (rpos[0] == 0) rh else rpos[1];

        const cpos = [2]usize{
            @intFromFloat(cv_coord[0]),
            @intFromFloat(cv_coord[1]),
        };
        std.debug.print("({d}, {d}) -> ({d}, {d})\n", .{ p[0], p[1], cpos[0], cpos[1] });

        return cpos;
    }

    pub fn drawPoint(self: *Self, p: geo.Vec2, val: Color) void {
        const where = self.realToCanvas(p);
        self.putPixel(where[0], where[1], val);
    }

    pub fn putPixel(self: *Self, x: usize, y: usize, val: Color) void {
        const pos = x + (y * self.width);
        const in_bounds = (x < self.width) and (y < self.height);
        if (!in_bounds) return;
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
