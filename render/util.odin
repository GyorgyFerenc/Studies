package main

import "core:math"

Color :: [4]u8;

BLACK :: Color{0   , 0,    0,    0xFF};
RED   :: Color{0xFF, 0,    0,    0xFF};
GREEN :: Color{0,    0xFF, 0,    0xFF};
BLUE  :: Color{0,    0,    0xFF, 0xFF};

color_from :: proc(hex: u32be) -> Color{
    return transmute(Color)hex;
}


weight_color :: proc(color: Color, weigth: f32) -> Color{
    return {
        aux(color.r, weigth),
        aux(color.g, weigth),
        aux(color.b, weigth),
        aux(color.a, weigth),
    };
    aux :: proc(a: u8, w: f32) -> u8{
        v := cast(f32) a / 255;
        v = v * w;
        v = v * 255;
        return cast(u8) v;
    }
}

blend :: proc(c1, c2: Color) -> Color{
    return c1 * (0xFF - c2.a) + c2.a * c2;
}

Canvas :: struct{
    width:  int,
    height: int,
    data: []Color, // (x, y), (width, height)
}

make_canvas :: proc(width: int, height: int) -> Canvas{
    c := Canvas{
        width  = width,
        height = height,
    };

    c.data = make_slice([]Color, width * height);
    return c;
}

destroy_canvas :: proc(c: Canvas){
    delete(c.data);
}

get :: proc(c: Canvas, x, y: int) -> Color{
    return c.data[y * c.height + x];
}

set :: proc(c: ^Canvas, x, y: int, color: Color){
    c.data[y * c.height + x] = color;
}


