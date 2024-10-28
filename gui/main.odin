package main

import "core:mem"
import "core:fmt"
import "core:unicode/utf8"
import "core:strings"

import rl "vendor:raylib"

v2 :: [2]f32;

main :: proc(){
    rl.InitWindow(1080, 720, "test");

    buffer: [1000]u8;
    str := "";
    for !rl.WindowShouldClose(){
        rl.BeginDrawing();
        defer rl.EndDrawing();
        rl.ClearBackground(rl.BLACK);

        str = text_input(buffer[:], len(str));
    }
}

button :: proc(position, size: v2, label: string) -> bool{
    pushed := false;
    mouse := rl.GetMousePosition();

    if position.x <= mouse.x && mouse.x <= position.x + size.x &&
       position.y <= mouse.y && mouse.y <= position.y + size.y {
        pushed = rl.IsMouseButtonPressed(.LEFT)
    }

    rl.DrawRectangleV(position, size, rl.GREEN);
    return pushed;
}

/*
   The buffer will hold the string,
   the actual_len if there is still a string in 
   it
*/
text_input :: proc(buffer: []u8, actual_len: int) -> string{
    actual_len := actual_len;

    if len(buffer) > actual_len{
        char := rl.GetCharPressed();
        if char != 0{
            r, s := utf8.encode_rune(char);
            for i in 0..<s{
                buffer[actual_len + i] = r[i];
            }
            actual_len += s;
        }
    }

    str := cast(string) buffer[:actual_len];
    cstr := strings.clone_to_cstring(str);
    defer delete(cstr);

    rl.DrawText(cstr, 0, 0, 20, rl.WHITE);

    return str;
}
