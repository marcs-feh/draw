const cv = @import("canvas.zig");
const geo = @import("geometry.zig");

const Vec2 = geo.Vec2;
pub fn drawKeyPoints(canvas: *cv.Canvas) void {
    const c = cv.rgb(0xff, 0xff, 0xff);
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
