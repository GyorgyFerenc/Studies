package main

import rl "vendor:raylib"
import "core:c"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"

HEIGHT :: 100;
WIDTH  :: 100;
RATIO  :: 10;
DETAIL :: 1;

v2 :: [2]f32;

main :: proc(){
    rl.InitWindow(RATIO * WIDTH, RATIO * HEIGHT, "World generate");
    defer rl.CloseWindow();

    m := heigth_map(WIDTH, HEIGHT);

    for !rl.WindowShouldClose(){
        rl.BeginDrawing();
            draw_map(m);
        rl.EndDrawing();
    }
}

draw_map :: proc(m: Map){
    for y in 0..<m.heigth{
        for x in 0..<m.width{
            f := get(m, x, y);
            color := field_color(f);
            xx := RATIO * cast(c.int) x;
            yy := RATIO * cast(c.int) y;

            rl.DrawRectangle(xx, yy, RATIO, RATIO, color);
        }
    }
}

field_color :: proc(f: Field) -> rl.Color{
    switch f{
    case .Grass:    return rl.GREEN;
    case .Mountain: return rl.GRAY;
    case .Water:    return rl.BLUE;
    case .Desert:   return rl.YELLOW;
    case .Wheat:    return rl.ORANGE;
    case .Forest:   return rl.DARKGREEN;
    }

    return {};
}

full_random_map :: proc(width, heigth, detail: int) -> Map{
    m := create_map(width, heigth);

    fields := []Field{
        .Grass,
        .Mountain,
        .Water,
        .Desert,
        .Wheat,
        .Forest,
    };
    l := len(fields);

    for y in 0..<m.heigth{
        for x in 0..<m.width{
            p := cast(int) (rand.float32() * cast(f32) l);
            set(&m, x, y, fields[p]);
        }
    }

    return m;
}

heigth_map :: proc(width, heigth: int) -> Map{
    m := create_map(width, heigth);

    mountain_tops :=  make([]Mountain_Top, 3);
    top_heigth: f32 = 100;
    sea_level := cast(int) rand.float32_range(40, 60);
    heigth_map := create_matrix(int, width, heigth);

    for &top in mountain_tops{
        top.x = cast(int) rand.float32_range(0, cast(f32) width);
        top.y = cast(int) rand.float32_range(0, cast(f32) heigth);
        top.heigth = rand.float32_range(80, top_heigth);
        fmt.println(top.x, top.y);
    }
    
    for y in 0..<m.heigth{
        for x in 0..<m.width{
            p := v2{cast(f32) x, cast(f32) y};
            heigth: f32 = 0;

            for top in mountain_tops{
                distance := linalg.distance(p, v2{cast(f32) top.x, cast(f32) top.y});
                distance = math.clamp(0, top.heigth, distance);
                v := 1 - distance / top.heigth;
                heigth = math.max(heigth, v * top.heigth);
            }

            set(&heigth_map, x, y, cast(int) heigth);
        }
    }

    for y in 0..<m.heigth{
        for x in 0..<m.width{
            heigth := get(heigth_map, x, y);
            if (heigth <= sea_level){
                set(&m, x, y, Field.Water);
            }
        }
    }


    return m;

    Mountain_Top :: struct{
        x, y: int,
        heigth: f32,
    }
}

sigmoid :: proc(x: f32) -> f32{
    return 1 / (1 - math.exp(-x));
}
