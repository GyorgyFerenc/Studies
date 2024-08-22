package main

import "core:math"

Color  :: [4]u8;
ColorF :: [4]f32; // values between 0 and 1

BLACK :: Color{0   , 0,    0,    0xFF};
WHITE :: Color{0xFF, 0xFF, 0xFF, 0xFF};
RED   :: Color{0xFF, 0,    0,    0xFF};
GREEN :: Color{0,    0xFF, 0,    0xFF};
BLUE  :: Color{0,    0,    0xFF, 0xFF};

color_from :: proc(hex: u32be) -> Color{
    return transmute(Color)hex;
}

color_to_colorf :: proc(c: Color) -> ColorF{
    cf: ColorF;
    cf.r = (cast(f32) c.r) / 255;
    cf.g = (cast(f32) c.g) / 255;
    cf.b = (cast(f32) c.b) / 255;
    cf.a = (cast(f32) c.a) / 255;
    return cf;
}

colorf_to_color :: proc(cf: ColorF) -> Color{
    c: Color;
    c.r = cast(u8) (cf.r * 255);
    c.g = cast(u8) (cf.g * 255);
    c.b = cast(u8) (cf.b * 255);
    c.a = cast(u8) (cf.a * 255);
    return c;
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

getf :: proc(c: Canvas, x, y: int) -> ColorF{
    return color_to_colorf(get(c, x, y));
}

set :: proc(c: ^Canvas, x, y: int, color: Color){
    c.data[y * c.height + x] = color;
}

setf :: proc(c: ^Canvas, x, y: int, colorf: ColorF){
    set(c, x, y, colorf_to_color(colorf));
}

fill :: proc(c: ^Canvas, color: Color){
    for &d in c.data{
        d = color;
    }
}

