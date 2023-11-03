const std = @import("std");
const builtin = @import("builtin");
const debug = std.debug;
const mem = std.mem;
const fs = std.fs;

const little_endian = builtin.target.cpu.arch.endian() == .little;

const PPMError = error{
    SizeMismatch,
};

fn openOrCreateFile(path: []const u8) !fs.File {
    const here = fs.cwd();
    var f = here.openFile(path, .{ .mode = .write_only }) catch |err| try_fix: {
        if (err == error.FileNotFound) {
            debug.print("File '{s}' not found, trying to create it...\n", .{path});
            break :try_fix try here.createFile(path, .{});
        } else {
            return err;
        }
    };
    return f;
}

fn extractRGB(comptime Int: type, v: Int) [3]u8 {
    comptime if (!checkIntType(Int))
        @compileError("Integer type must be 24[RGB] or 32[RGBA] bits");

    const c = if (little_endian) @byteSwap(v) else v;
    return [3]u8{
        @intCast((c >> (8 * 0)) & 0xff),
        @intCast((c >> (8 * 1)) & 0xff),
        @intCast((c >> (8 * 2)) & 0xff),
    };
}

fn checkIntType(comptime T: type) bool {
    var info = @typeInfo(T);
    return comptime switch (info) {
        .Int => |I| (I.bits == 24) or (I.bits == 32),
        else => false,
    };
}

pub fn writePPM(comptime Int: type, outfile: []const u8, px_data: []const Int, width: usize, height: usize) !void {
    if (px_data.len < (width * height)) {
        return PPMError.SizeMismatch;
    }

    const fmt = "P6\n{d} {d}\n255\n";
    var buf = [_]u8{0} ** 0xff;

    var f = try openOrCreateFile(outfile);
    defer f.close();

    var header = try std.fmt.bufPrint(&buf, fmt, .{ width, height });

    _ = try f.write(header);
    for (px_data) |px| {
        var rgb = extractRGB(Int, px);
        _ = try f.write(&rgb);
    }
}
