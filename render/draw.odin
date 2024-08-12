package main

import "core:math"

draw_triangle :: proc(canvas: ^Canvas, p1, p2, p3: v2, c1, c2, c3: Color){
    min_x := cast(int) math.min(p1.x, p2.x, p3.x);
    min_y := cast(int) math.min(p1.y, p2.y, p3.y);
    max_x := cast(int) math.max(p1.x, p2.x, p3.x);
    max_y := cast(int) math.max(p1.y, p2.y, p3.y);

    for y in min_y..<max_y{
        if y < 0 do continue;
        if y >= canvas.height do break;

        for x in min_x..<max_x{
            if x < 0 do continue;
            if x >= canvas.width do break;

            p := v2{cast(f32) x, cast(f32) y};
            if point_in_triangle2d(p, p1, p2, p3){
                w1, w2, w3 := barycentric_weights(p, p1, p2, p3);
                c := weight_color(c1, w1) + weight_color(c2, w2) + weight_color(c3, w3);
                set(canvas, x, y, c);
            }
        }
    }
}




Fragment_Shader :: proc(x, y: int, color: Color, data: rawptr) -> Color;
run_fragment_shader :: proc(canvas: ^Canvas, shader: Fragment_Shader, data: rawptr){
    for y in 0..<canvas.height{
        for x in 0..<canvas.width{
            set(canvas, x, y, shader(x, y, get(canvas^, x, y), data));
        }
    }
}
