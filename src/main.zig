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
    const w = 300;
    const h = 300;

    var canvas = try cv.Canvas.init(w, h, allocator);

    demo.drawKeyPoints(&canvas);
    canvas.drawCircle(geo.Circle{ .o = Vec2{ 0.8, -0.3 }, .r = 0.3 }, cv.rgb(200, 100, 100));
    // const r = 0.5;
    // for(0..10_000)|i|{
    //     const x: f32 = @floatFromInt(i);
    //     const p = Vec2{
    //         @sin( x) * r,
    //         @cos( x) * r,
    //     };
    //     canvas.drawPoint(p, 0xff_00_ff);
    // }

    defer canvas.deinit();

    try img.writePPM(u32, "toma.ppm", canvas.data, canvas.width, canvas.height);
}
