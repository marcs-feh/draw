const std = @import("std");
const geo = @import("geometry.zig");
const img = @import("image.zig");
const cv = @import("canvas.zig");
const demo = @import("demo.zig");

const Vec2 = geo.Vec2;

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};

var temp_buf = [_]u8{0} ** kili(8);

pub fn main() !void {
    var allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();
    const w = 500;
    const h = 300;

    var canvas = try cv.Canvas.init(w, h, allocator, &temp_buf);

    // demo.drawKeyPoints(&canvas);
    // canvas.drawCircle(geo.Circle{ .o = Vec1{ 0.5, 0.0 }, .r = 0.3 }, cv.rgb(200, 100, 100), true);
    // canvas.drawLine(geo.Line{Vec2{ 0.0, 0.1 }, Vec2{ 0.3, 1.0 } }, cv.rgb(255, 255, 0));
    canvas.drawTriangle(geo.Triangle{
        .{ -45, 90 },
        .{ 40, 50 },
        .{ 20, -60 },
    }, cv.rgb(230, 160, 10), true);

    defer canvas.deinit();

    try img.writePPM(u32, "toma.ppm", canvas.data, canvas.width, canvas.height);
}

fn kili(n: usize) usize {
    return n * 1024;
}
