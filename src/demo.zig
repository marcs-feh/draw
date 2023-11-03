const cv = @import("canvas.zig");
const geo = @import("geometry.zig");

// FIX ME do normalized shit
const Vec2 = geo.Vec2;
pub fn drawKeyPoints(canvas: *cv.Canvas) void {
    const c = cv.rgb(0xff, 0xff, 0xff);
    const cl = cv.rgb(50, 50, 50);
    const points = [_]Vec2{
        Vec2{ 0, 0 },

        Vec2{ 0, 1 },
        Vec2{ 1, 0 },
        Vec2{ 1, 1 },

        Vec2{ 0, -1 },
        Vec2{ -1, 0 },
        Vec2{ -1, -1 },

        Vec2{ -1, 1 },
        Vec2{ 1, -1 },
    };

    for (points) |p| {
        canvas.drawLine(.{ Vec2{ 0, 0 }, p }, cl);
    }

    for (points) |p| {
        canvas.drawPoint(p, c);
    }

    // canvas.drawLine(geo.Line{Vec2{-0.5, 1}, Vec2{-0.5, -1}}, c);
    // canvas.drawLine(geo.Line{Vec2{0.5, 1}, Vec2{0.5, -1}}, c);
    //
    // canvas.drawLine(geo.Line{Vec2{1, 0.5}, Vec2{-1, 0.5}}, c);
    // canvas.drawLine(geo.Line{Vec2{1, -0.5}, Vec2{-1, -0.5}}, c);

}
