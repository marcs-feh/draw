const std = @import("std");
const geo = @import("geometry.zig");
const img = @import("image.zig");
const cv = @import("canvas.zig");
const demo = @import("demo.zig");

const Vec2 = geo.Vec2;

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};

pub fn main() !void {
    var allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();
    const w = 500;
    const h = 300;

    var canvas = try cv.Canvas.init(w, h, allocator);

    demo.drawKeyPoints(&canvas);
    // canvas.drawCircle(geo.Circle{ .o = Vec2{ 0.5, 0.0 }, .r = 0.3 }, cv.rgb(200, 100, 100), true);
    canvas.drawLine(geo.Line{ .a = Vec2{ 0.0, 0.1 }, .b = Vec2{ 0.3, 1.0 } }, cv.rgb(255, 255, 0));

    defer canvas.deinit();

    try img.writePPM(u32, "toma.ppm", canvas.data, canvas.width, canvas.height);
}
