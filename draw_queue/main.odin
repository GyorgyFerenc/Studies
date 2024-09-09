package main

import "core:mem"

import rl "vendor:raylib"

v2 :: [2]f32;

main :: proc(){
    rl.InitWindow(1080, 720, "test");
    defer rl.CloseWindow();

    group := make_draw_group(context.allocator);
    defer destroy_draw_group(group);

    for !rl.WindowShouldClose(){
        draw_rectangle(&group, {0, 0}, {1080, 720}, {0, 0, 0, 1});
        draw_rectangle(&group, {100, 100}, {100, 100}, {0, 0, 1, .1});
        //draw_rectangle(&group, {100, 100}, {100, 100}, {0, 1, 1, .1});

        draw(&group);
    }
}

Color :: [4]f32;

Draw :: union{
    Draw_Rectangle,
}

Draw_Rectangle :: struct{
    position: v2,
    size: v2,
    color: Color,
}

Draw_Group :: struct{
    draws: [dynamic]Draw,
}

make_draw_group :: proc(allocator: mem.Allocator) -> Draw_Group{
    return {
        draws = make([dynamic]Draw, allocator = allocator),
    };
}

destroy_draw_group :: proc(group: Draw_Group){
    delete(group.draws);
}

draw_rectangle :: proc(g: ^Draw_Group, position: v2, size: v2, color: Color){
    append(&g.draws, Draw_Rectangle{position, size, color});
}

draw :: proc(g: ^Draw_Group){
    rl.BeginDrawing();

    for draw in g.draws{
        switch d in draw{
        case Draw_Rectangle:
            rl.DrawRectangleV(d.position, d.size, to_rl_color(d.color));
        }
    }

    rl.EndDrawing();

    clear_draw_group(g);

    to_rl_color :: proc(c: Color) -> rl.Color{
        c := c * 255;
        return {
            cast(u8) c.r,
            cast(u8) c.g,
            cast(u8) c.b,
            cast(u8) c.a,
        };
    }
}

clear_draw_group :: proc(g: ^Draw_Group){
    clear(&g.draws);
}
