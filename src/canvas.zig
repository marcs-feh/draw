const std = @import("std");
const geo = @import("geometry.zig");
const math = std.math;
const mem = std.mem;

fn asInt(comptime To: type, x: anytype) To {
    return @as(To, @intCast(x));
}

pub const Canvas = struct {
    const Self = @This();

    data: []Color,
    width: usize,
    height: usize,
    allocator: mem.Allocator,

    pub fn aspectRatio(self: Canvas) geo.Real {
        const W: geo.Real = @floatFromInt(self.width);
        const H: geo.Real = @floatFromInt(self.height);

        return W / H;
    }

    fn realToCanvas(self: Canvas, p: geo.Vec2) [2]isize {
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

        const cpos = [2]isize{
            @intFromFloat(cv_coord[0]),
            @intFromFloat(cv_coord[1]),
        };
        // std.debug.print("({d}, {d}) -> ({d}, {d})\n", .{ p[0], p[1], cpos[0], cpos[1] });

        return cpos;
    }

    fn putLine(self: *Self, x0: isize, y0: isize, x1: isize, y1: isize, val: Color) void {
        const dx = asInt(isize, @abs(x1 - x0));
        const sx: isize = if (x0 < x1) 1 else -1;

        const dy = -asInt(isize, (@abs(y1 - y0)));
        const sy: isize = if (y0 < y1) 1 else -1;

        var err = dx + dy;

        var x = x0;
        var y = y0;

        while (true) {
            self.putPixel(x, y, val);

            if (x == x1 and y == y1) break;
            var e2 = err * 2;

            if (e2 >= dy) {
                if (x == x1) break;
                err += dy;
                x += sx;
            }

            if (e2 <= dx) {
                if (y == y1) break;
                err += dx;
                y += sy;
            }
        }
    }

    pub fn drawLine(self: *Self, line: geo.Line, val: Color) void {
        const ca = self.realToCanvas(line.a);
        const cb = self.realToCanvas(line.b);

        std.debug.print("({d}, {d}) -> ({d}, {d})\n", .{ line.a[0], line.a[1], ca[0], ca[1] });
        std.debug.print("({d}, {d}) -> ({d}, {d})\n", .{ line.b[0], line.b[1], cb[0], cb[1] });

        self.putLine(ca[0], ca[1], cb[0], cb[1], val);

        self.putPixel(ca[0], ca[1], 0xff_00_00);
        self.putPixel(cb[0], cb[1], 0xff_00_00);
    }

    pub fn drawCircle(self: *Self, circle: geo.Circle, val: Color, fill: bool) void {
        const R = circle.r * @as(geo.Real, @floatFromInt(@min(self.width, self.height)));

        const cv_r: usize = @intFromFloat(R);
        const co = self.realToCanvas(circle.o);

        // +1 is to make sample area slightly bigger to account for
        // innacuracy
        const left = co[1] -| (cv_r + 1);
        const right = co[1] +| (cv_r + 1);

        const top = co[0] -| (cv_r + 1);
        const bottom = co[0] +| (cv_r + 1);

        std.debug.print("r: {d}, cv_r: {d}\n", .{ circle.r, cv_r });
        for (top..bottom) |row| {
            for (left..right) |col| {
                const d = dist(.{ row, col }, co);
                const should_draw = if (fill) d <= cv_r else d == cv_r;
                if (should_draw) {
                    self.putPixel(row, col, val);
                }
            }
        }
    }

    pub fn drawPoint(self: *Self, p: geo.Vec2, val: Color) void {
        const where = self.realToCanvas(p);
        self.putPixel(where[0], where[1], val);
    }

    pub fn putPixel(self: *Self, x: isize, y: isize, val: Color) void {
        const w = asInt(isize, self.width);
        const h = asInt(isize, self.height);

        const pos = asInt(usize, x + (y * w));
        const in_bounds = (x < w) and (y < h);
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

fn dist(pa: [2]usize, pb: [2]usize) usize {
    const a = geo.Vec2{ @floatFromInt(pa[0]), @floatFromInt(pa[1]) };
    const b = geo.Vec2{ @floatFromInt(pb[0]), @floatFromInt(pb[1]) };

    return @intFromFloat(geo.dist(a, b));
}
