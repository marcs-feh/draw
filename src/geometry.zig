const std = @import("std");

pub const vec2 = @Vector(2, f32);

pub fn dist(a: vec2, b: vec2) f32 {
    const dx = (a[0] - b[0]);
    const dy = (a[1] - b[1]);
    const d = @sqrt((dx * dx) + (dy * dy));
    return d;
}

pub fn lerp(a: f32, b: f32, t: f32) f32 {
    return ((1 - t) * a) + (t * b);
}

pub fn lerp2(a: vec2, b: vec2, t: f32) vec2 {
    return vec2{
        lerp(a[0], b[0], t),
        lerp(a[1], b[1], t),
    };
}
