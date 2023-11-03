const std = @import("std");
const geo = @import("geometry.zig");
const math = std.math;
const mem = std.mem;
const heap = std.heap;

// TODO: scanline draw with memset

fn numCast(comptime To: type, x: anytype) To {
    const dest_info = @typeInfo(To);
    const src_info = @typeInfo(@TypeOf(x));

    return switch (dest_info) {
        .Float => switch (src_info) {
            .Int => @as(To, @floatFromInt(x)),
            .Float => @as(To, @floatCast(x)),
            else => @compileError("Cannot convert types"),
        },
        .Int => switch (src_info) {
            .Int => @as(To, @intCast(x)),
            .Float => @as(To, @intFromFloat(@floor(x))),
            else => @compileError("Cannot convert types"),
        },
        else => @compileError("Cannot convert types"),
    };
}

const Real = geo.Real;
const Vec2 = geo.Vec2;

pub const Canvas = struct {
    const Self = @This();

    data: []Color,
    width: usize,
    height: usize,
    allocator: mem.Allocator,
    temp_allocator: heap.FixedBufferAllocator,

    pub fn aspectRatio(self: Canvas) Real {
        const W: Real = @floatFromInt(self.width);
        const H: Real = @floatFromInt(self.height);

        return W / H;
    }

    fn realToCanvas(self: Canvas, p: Vec2) [2]isize {
        const rw: Real = @floatFromInt(self.width - 1);
        const rh: Real = @floatFromInt(self.height - 1);

        const cx = p[0];
        const cy = p[1];

        var cv_coord = Vec2{
            (rw / 2) + cx,
            (rh / 2) - cy,
        };

        const cpos = [2]isize{
            @intFromFloat(cv_coord[0]),
            @intFromFloat(cv_coord[1]),
        };

        return cpos;
    }

    fn putLine(self: *Self, x0: isize, y0: isize, x1: isize, y1: isize, val: Color) void {
        const dx = numCast(isize, @abs(x1 - x0));
        const sx: isize = if (x0 < x1) 1 else -1;

        const dy = -numCast(isize, (@abs(y1 - y0)));
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

    fn fillBottomFlatTriangle(self: *Canvas, v1: Vec2, v2: Vec2, v3: Vec2, val: Color) void {
        var invslope_left = (v2[0] - v1[0]) / (v2[1] - v1[1]);
        var invslope_right = (v3[0] - v1[0]) / (v3[1] - v1[1]);

        var xl = v1[0];
        var xr = v1[0];

        var scanline = v1[1];
        while (scanline <= v2[1]) : (scanline += 1) {
            // TODO: scanline draw that uses memset
            self.drawLine(geo.Line{ .{ xl, scanline }, .{ xr, scanline } }, val);
            xl += invslope_left;
            xr += invslope_right;
        }
    }

    fn fillTopFlatTriangle(self: *Canvas, v1: Vec2, v2: Vec2, v3: Vec2, val: Color) void {
        var invslope_left = (v3[0] - v1[0]) / (v3[1] - v1[1]);
        var invslope_right = (v3[0] - v2[0]) / (v3[1] - v2[1]);

        var xl = v3[0];
        var xr = v3[0];

        var scanline = v3[1];
        while (scanline > v1[1]) : (scanline -= 1) {
            // TODO: scanline draw that uses memset
            self.drawLine(geo.Line{ .{ xl, scanline }, .{ xr, scanline } }, val);
            xl -= invslope_left;
            xr -= invslope_right;
        }
    }

    pub fn drawTriangle(self: *Canvas, tri: geo.Triangle, val: Color, fill: bool) void {
        if (!fill) {
            self.drawLine(.{ tri[0], tri[1] }, val);
            self.drawLine(.{ tri[0], tri[2] }, val);
            self.drawLine(.{ tri[1], tri[2] }, val);
        } else {
            var t = geo.triangleSortY(tri);

            const a = t[0];
            const b = t[1];
            const c = t[2];

            // middle == bottom
            if (t[1][1] == t[2][1]) {
                self.fillBottomFlatTriangle(a, b, c, val);
            }
            // middle == top
            else if (t[1][1] == t[0][1]) {
                self.fillTopFlatTriangle(a, b, c, val);
            } else {
                const splitx = a[0] + ((b[1] - a[1]) / (c[1] - a[1])) * (c[0] - a[0]);
                const m = Vec2{ splitx, b[1] };

                self.fillBottomFlatTriangle(a, b, m, val);
                self.fillTopFlatTriangle(b, m, c, val);
            }
        }
    }

    fn allocTemp(self: *Canvas, comptime T: type, n: usize) ![]T {
        return try self.temp_allocator.allocator().alloc(T, n);
    }

    fn freeTemp(self: *Canvas) void {
        self.temp_allocator.reset();
    }

    pub fn drawLine(self: *Self, line: geo.Line, val: Color) void {
        const ca = self.realToCanvas(line[0]);
        const cb = self.realToCanvas(line[1]);

        self.putLine(ca[0], ca[1], cb[0], cb[1], val);
    }

    pub fn drawCircle(self: *Self, circle: geo.Circle, val: Color, fill: bool) void {
        const R = circle.r;

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

    pub fn drawPoint(self: *Self, p: Vec2, val: Color) void {
        const where = self.realToCanvas(p);
        self.putPixel(where[0], where[1], val);
    }

    pub fn putPixel(self: *Self, x: isize, y: isize, val: Color) void {
        const w = numCast(isize, self.width);
        const h = numCast(isize, self.height);

        const pos = numCast(usize, x + (y * w));
        const in_bounds = (x < w) and (y < h);
        if (!in_bounds) return;
        self.data[pos] = val;
    }

    pub fn init(width: usize, height: usize, allocator: mem.Allocator, temp_buf: []u8) !Self {
        var canvas = Self{
            .width = width,
            .height = height,
            .data = try allocator.alloc(Color, width * height),
            .allocator = allocator,
            .temp_allocator = std.heap.FixedBufferAllocator.init(temp_buf),
        };

        @memset(canvas.data, 0);
        return canvas;
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.data);
    }

    // TODO: improve, this is how Gambetta's book implements it and I really
    // don't like doing memory allocation just for that, make sure to call
    // freeTemp() once you're done with the list.
    // fn interpolate(list: *std.ArrayList(Real), ind0: isize, dep0: Real, ind1: isize, dep1: Real) !void {
    //     std.debug.print("i0: {d} i1: {d}\nd0: {d} d1: {d}\n", .{ind0, ind1, dep0, dep1});
    //     if (ind0 == ind1){
    //         std.debug.print("<< {d} == {d} >>\n", .{ind0, ind1});
    //         return ;
    //     }
    //     const a: Real = (dep0 - dep1) / (numCast(Real, ind1 - ind0));
    //     var d = dep0;
    //
    //     var i = ind0;
    //     while(i < ind1):(i += 1){
    //         // std.debug.print("<< {d} >>\n", .{i});
    //         try list.append(d);
    //         d += a;
    //     }
    // }

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

// pub fn lerp(ind0: isize, dep0: Real, ind1: isize, dep1: Real) []Real {
// }

fn dist(pa: [2]usize, pb: [2]usize) usize {
    const a = Vec2{ @floatFromInt(pa[0]), @floatFromInt(pa[1]) };
    const b = Vec2{ @floatFromInt(pb[0]), @floatFromInt(pb[1]) };

    return @intFromFloat(geo.dist(a, b));
}

fn kili(n: usize) usize {
    return n * 1024;
}
