const std = @import("std");
const geo = @import("geometry.zig");
const img = @import("image.zig");
const cv = @import("canvas.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};

pub fn main() !void {
    var allocator = gpa.allocator();
    defer _ = gpa.detectLeaks();
    const w = 600;
    const h = 400;

    var canvas = try cv.Canvas.init(w, h, allocator);
    defer canvas.deinit();

    try img.writePPM(u32, "toma.ppm", canvas.data, canvas.width, canvas.height);
}
