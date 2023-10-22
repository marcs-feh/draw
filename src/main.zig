const std = @import("std");
const geo = @import("geometry.zig");
const img = @import("image.zig");
const cv = @import("canvas.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};

pub fn main() !void {
    var allocator = gpa.allocator();
    const w = 400;
    const h = 400;

    var data = try allocator.alloc(u32, w * h);
    @memset(data, cv.rgba(45, 60, 100, 0xff));
    try img.writePPM(u32, "toma.ppm", data, w, h);
}
