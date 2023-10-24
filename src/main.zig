const std = @import("std");
const geo = @import("geometry.zig");
const img = @import("image.zig");
const cv = @import("canvas.zig");

const Vec2 = geo.Vec2;

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};

pub fn main() !void {
    var allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();
    const w = 120;
    const h = 100;

    var canvas = try cv.Canvas.init(w, h, allocator);

    defer canvas.deinit();

    try img.writePPM(u32, "toma.ppm", canvas.data, canvas.width, canvas.height);
}

fn drawKeyPoints(canvas: *cv.Canvas) void {
    const c = cv.rgb(190, 40, 130);
    canvas.drawPoint(Vec2{ 0, 0 }, c);

    canvas.drawPoint(Vec2{ 0, 1 }, c);
    canvas.drawPoint(Vec2{ 1, 0 }, c);
    canvas.drawPoint(Vec2{ 1, 1 }, c);

    canvas.drawPoint(Vec2{ 0, -1 }, c);
    canvas.drawPoint(Vec2{ -1, 0 }, c);
    canvas.drawPoint(Vec2{ -1, -1 }, c);

    canvas.drawPoint(Vec2{ -1, 1 }, c);
    canvas.drawPoint(Vec2{ 1, -1 }, c);
}
