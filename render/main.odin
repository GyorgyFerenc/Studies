package main

import "core:fmt"
import rl "vendor:raylib"
import "core:mem"
import "core:c"
 
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

filter :: proc(x, y: int, color: Color, data: rawptr) -> Color{
    color := color;
    if color.r <= 128 do color.r = 0;
    return color;
}

main :: proc(){
    rl.InitWindow(500, 500, "Kecske");
    defer rl.CloseWindow();

    canvas := make_canvas(500, 500);

    draw_triangle(&canvas, 
        {0, 0}, {0, 500}, {500, 0}, 
        RED,    GREEN,    BLUE,
    );

    run_fragment_shader(&canvas, filter, nil);

    img := canvas_to_img(canvas);
    //img := rl.LoadImage("render/kecske.png");
    fmt.println(img.format);
    texture := rl.LoadTextureFromImage(img);

    for !rl.WindowShouldClose(){
        rl.BeginDrawing();
            rl.DrawTexture(texture, 0, 0, rl.GetColor(0xFF_FF_FF_FF));
        rl.EndDrawing();
    }
}
