const std = @import("std");
const math = std.math;

pub const Real = f32;
pub const Vec2 = @Vector(2, Real);

// TODO: Things like area, perimiter, etc.

pub const Line = struct {
    const Self = @This();

    a: Vec2,
    b: Vec2,

    pub fn size(self: Self) Real {
        return dist(self.a, self.b);
    }
};

pub const Triangle = struct {
    const Self = @This();

    a: Vec2,
    b: Vec2,
    c: Vec2,

    pub fn sortY() Triangle {}

    pub fn sortX() Triangle {}
};

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
