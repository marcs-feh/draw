const std = @import("std");
const mem = std.mem;
const math = std.math;

pub const Real = f64;
pub const Vec2 = @Vector(2, Real);

// TODO: Things like area, perimiter, etc.

pub const Line = [2]Vec2;

pub const Triangle = [3]Vec2;

pub fn swap(comptime T: type, a: *T, b: *T) void {
    const t = a.*;
    a.* = b.*;
    b.* = t;
}

pub fn triangleSortY(tri: Triangle) Triangle {
    var out: Triangle = tri;

    if (out[1][1] < out[0][1]) {
        swap(Vec2, &out[1], &out[0]);
    }

    if (out[2][1] < out[0][1]) {
        swap(Vec2, &out[2], &out[0]);
    }

    if (out[2][1] < out[1][1]) {
        swap(Vec2, &out[2], &out[1]);
    }

    return out;
}

pub const Circle = struct {
    const Self = @This();

    /// Origin
    o: Vec2 = Vec2{ 0, 0 },
    /// Radius
    r: Real,
};

pub const Shape = union(enum) {
    circle: Circle,
    line: Line,
    triangle: Triangle,
    point: Vec2,
};

pub fn dist(a: Vec2, b: Vec2) Real {
    const dx = (a[0] - b[0]);
    const dy = (a[1] - b[1]);
    const d = @sqrt((dx * dx) + (dy * dy));
    return d;
}

pub fn lerp(a: Real, b: Real, t: Real) Real {
    return ((1 - t) * a) + (t * b);
}

pub fn lerp2(a: Vec2, b: Vec2, t: Real) Vec2 {
    return Vec2{
        lerp(a[0], b[0], t),
        lerp(a[1], b[1], t),
    };
}

pub const LerpIterator = struct {};
