package main

import "core:fmt"
import rl "vendor:raylib"
import "core:mem"
import "core:c"
import "core:math/linalg"
 
canvas_to_img :: proc(canvas: Canvas) -> rl.Image{
    s := mem.slice_to_bytes(canvas.data);
    data := cast(rawptr)raw_data(s);
    img := rl.Image{
        data   = data,
        width  = cast(c.int) canvas.width,
        height = cast(c.int) canvas.height,
        mipmaps = 1,
        format = .UNCOMPRESSED_R8G8B8A8,
    };

    return img;
}

check_board :: proc(fs: Fragment_Shader) -> ColorF{
    posi := fs.posi / 50;
    if posi.x % 2 == posi.y % 2 {
        return color_to_colorf(WHITE);
    }

    return color_to_colorf(BLACK);
}

main :: proc(){
    rl.InitWindow(500, 500, "Kecske");
    defer rl.CloseWindow();
    
    rl.SetTraceLogLevel(.NONE);

    canvas := make_canvas(500, 500);
    //back_canvas  := make_canvas(500, 500);

    triangle: [3]v3 = { {50, -100, 0}, {20, 0, -100}, {10, 100, 0},};

    camera := Camera{
        pos = {0, 0, 0},
        dir = {1, 0, 0},
        up  = {0, 0, 1},
    };

    for !rl.WindowShouldClose(){
        if rl.IsKeyDown(.W) do camera.pos.x += 1;
        if rl.IsKeyDown(.S) do camera.pos.x -= 1;
        if rl.IsKeyDown(.A) do camera.pos.y -= 1;
        if rl.IsKeyDown(.D) do camera.pos.y += 1;

        fill(&canvas, BLACK);

        render := Render{
            canvas = &canvas,
            transform = get_ortho_transform(canvas, camera, -100, 100, -100, 100, 0, -100),
        };
        render_triangle(&render, 
            triangle[0], triangle[1], triangle[2],
            RED,         BLUE,        GREEN);

        img := canvas_to_img(canvas);
        texture := rl.LoadTextureFromImage(img);

        rl.BeginDrawing();
            rl.DrawTexture(texture, 0, 0, rl.GetColor(0xFF_FF_FF_FF));
        rl.EndDrawing();
    }

}
