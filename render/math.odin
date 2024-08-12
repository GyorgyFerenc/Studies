package main

v2 :: [2]f32;
v3 :: [3]f32;
v4 :: [4]f32;

barycentric_weights :: proc(p, p1, p2, p3: v2) -> (f32, f32, f32){
    // source: ttps://codeplea.com/triangular-interpolation
    
    w1 := ((p2.y - p3.y) * (p.x - p3.x) + (p3.x - p2.x)*(p.y - p3.y)) / ((p2.y - p3.y)*(p1.x - p3.x) + (p3.x - p2.x)*(p1.y - p3.y));
    w2 := ((p3.y - p1.y) * (p.x - p3.x) + (p1.x - p3.x)*(p.y - p3.y)) / ((p2.y - p3.y)*(p1.x - p3.x) + (p3.x - p2.x)*(p1.y - p3.y));
    w3 := 1 - w1 - w2;

    return w1, w2, w3;
}

point_in_triangle2d :: proc(p, t1, t2, t3: v2) -> bool{
    // point = a  + w1 * (b - a) + w2 * (c - a)
    // w1 < 1, w2 < 1, 0 < w1 + w2 < 1 has to be true

    b1 := aux(p, t1, t2) < 0;  
    b2 := aux(p, t2, t3) < 0;
    b3 := aux(p, t3, t1) < 0;
    return ((b1 == b2) && (b2 == b3));

    aux :: proc(p1, p2, p3: v2) -> f32{  
        return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
    }
}

mul2d :: proc(p: v2, a: f32) -> v2{
    return {p.x * a, p.y * a};
}

mul3d :: proc(p: v3, a: f32) -> v3{
    return {p.x * a, p.y * a, p.z * a};
}

mul :: proc{
    mul2d,
    mul3d,
}
