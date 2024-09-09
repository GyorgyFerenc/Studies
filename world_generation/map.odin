package main

Field :: enum {
    Grass,
    Mountain,
    Water,
    Desert,
    Wheat,
    Forest,
}

Map :: Matrix(Field);

create_map :: proc(width, heigth: int) -> Map{
    return create_matrix(Field, width, heigth);
}


Matrix :: struct($T: typeid){
    width:  int,
    heigth: int,
    data: []T,
}

create_matrix :: proc($T: typeid, width, heigth: int) -> Matrix(T){
    return {
        width = width,
        heigth = heigth,
        data = make([]T, width * heigth),
    };
}

destroy :: proc(m: Matrix($T)){
    delete(m.data);
}

get :: proc(m: Matrix($T), x, y: int) -> T{
    return m.data[y * m.heigth + x];
}

get_ptr :: proc(m: Matrix($T), x, y: int) -> ^T{
    return &m.data[y * m.heigth + x];
}

set :: proc(m: ^Matrix($T), x, y: int, v: T){
    m.data[y * m.heigth + x] = v;
}
