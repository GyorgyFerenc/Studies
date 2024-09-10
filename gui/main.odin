package main

import "core:mem"

import rl "vendor:raylib"

v2 :: [2]f32;

main :: proc(){
    rl.InitWindow(1080, 720, "test");
    defer rl.CloseWindow();

    for !rl.WindowShouldClose(){
        rl.BeginDrawing();
            
        rl.EndDrawing();
    }
}

Event :: union{
}

poll :: proc() -> Event{
    e: Event;
    return e;
}
