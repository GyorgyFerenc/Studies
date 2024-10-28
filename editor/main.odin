package main

import "core:fmt"
import "core:mem"
import Buffer "buffer"

main :: proc(){
    allocator := context.allocator;
    context.allocator      = mem.panic_allocator();
    context.temp_allocator = mem.panic_allocator();
}
