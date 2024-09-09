package main

import "core:mem"
import "core:fmt"
import "base:runtime"
import "core:os"

main :: proc(){
    context.allocator      = mem.panic_allocator();
    context.temp_allocator = mem.panic_allocator();

    buffer: [1024]u8;
    arena: mem.Arena;
    mem.arena_init(&arena, buffer[:]);
    fa := mem.arena_allocator(&arena);
    defer free_all(fa);
    gpa := os.heap_allocator();

    a := make([dynamic]i32);
    append(&a, 12);
    fmt.println(a);
}
