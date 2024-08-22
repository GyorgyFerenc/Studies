package main

import "core:math"
import "core:fmt"
import "core:math/linalg"

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
                cf1 := color_to_colorf(c1);
                cf2 := color_to_colorf(c2);
                cf3 := color_to_colorf(c3);
                c := cf1 * w1 + cf2 * w2 + cf3 * w3;
                setf(canvas, x, y, c);
            }
        }
    }
}

Camera :: struct{
    pos: v3,
    dir: v3, // should be normalized
    up:  v3, // should be normalized
}

Render :: struct{
    canvas: ^Canvas,
    transform: Transform_3D,
};


get_ortho_transform :: proc(canvas: Canvas, camera: Camera, l, r, b, t, n, f: f32) -> Transform_3D{
    nx := cast(f32) canvas.width;
    ny := cast(f32) canvas.height;

    m_vp := matrix[4, 4]f32{
        nx / 2, 0,      0, (nx  - 1) / 2,
        0,      ny / 2, 0, (ny - 1) / 2,
        0,      0,      1, 0,
        0,      0,      0, 1,
    };

    m_orth := matrix[4, 4]f32{
        2 / (r - l), 0,           0,           -(r + l) / (r - l),
        0,           2 / (t - b), 0,           -(t + b) / (t - b),
        0,           0,           2 / (n - f), -(n + f) / (n - f),
        0,           0,           0,           1,
    };

    m_cam := get_camera_transform(camera);
    m := m_vp * m_orth * m_cam;
    return m;

    get_camera_transform :: proc(camera: Camera) -> Transform_3D{
        e := camera.pos;
        g := camera.dir;
        t := camera.up;

        w := -g; // g must be normalized
        tw := linalg.cross(t, w);
        u := tw / linalg.length(tw);
        v := linalg.cross(w, u);
        m_cam_1 := Transform_3D{
            u.x, u.y, u.z, 0,
            v.x, v.y, v.z, 0,
            w.x, w.y, w.z, 0,
            0,   0,   0,   1,
        };

        m_cam_2 := Transform_3D{
           1, 0, 0, -e.x,
           0, 1, 0, -e.y,
           0, 0, 1, -e.z,
           0, 0, 0, 1,
        };

        return m_cam_1 * m_cam_2;
    }
}

render_triangle :: proc(render: ^Render, p1, p2, p3: v3, c1, c2, c3: Color){
    translated_p1 := apply(p1, render.transform);
    translated_p2 := apply(p2, render.transform);
    translated_p3 := apply(p3, render.transform);

    draw_triangle(render.canvas, 
        translated_p1.xy, translated_p2.xy, translated_p3.xy, 
        c1,               c2,               c3,
    );
}


Fragment_Shader_Proc :: proc(fs: Fragment_Shader) -> ColorF;

Fragment_Shader :: struct{
    canvas: Canvas,
    pos: v2,
    posi: v2i,
    data: rawptr,
}

run_fragment_shader :: proc(write_canvas: ^Canvas, read_canvas: Canvas, shader: Fragment_Shader_Proc, data: rawptr){
    fs := Fragment_Shader{
        canvas = read_canvas,
        data   = data,
    };
    for y in 0..<read_canvas.height{
        for x in 0..<read_canvas.width{
            fs.pos  = v2{cast(f32) x, cast(f32) y};
            fs.posi = v2i{x, y};
            setf(write_canvas, x, y, shader(fs));
        }
    }
}



