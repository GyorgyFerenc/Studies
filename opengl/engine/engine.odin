package engine

import "core:fmt"
import "core:c"
import "core:mem"
import "core:strings"
import "core:os"

import "vendor:glfw"
import gl "vendor:OpenGL"

OPENGL_MAJOR :: 3;
OPENGL_MINOR :: 3;

Engine :: struct{
    window: glfw.WindowHandle,
    ta:     mem.Allocator, // temporary_allocator
    shader: Shader,
    vao: c.uint,
    vbo: c.uint,
    
    
    current_shader: Shader,
}
engine: Engine;

init :: proc(width, height: int, title: string, ta: mem.Allocator){
    engine.ta = ta;

    glfw.Init();    
    
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, OPENGL_MAJOR);
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, OPENGL_MINOR);
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);
    
    w, h := cast(c.int) width, cast(c.int) height;
    t := strings.clone_to_cstring(title, engine.ta);
    engine.window = glfw.CreateWindow(w, h, t, nil, nil);
    if engine.window == nil{
        panic("Window could not be created");
    }
    
    glfw.MakeContextCurrent(engine.window);
    
    gl.load_up_to(OPENGL_MAJOR, OPENGL_MINOR, glfw.gl_set_proc_address);
    gl.Viewport(0, 0, w, h);
    
    glfw.SetFramebufferSizeCallback(engine.window, frame_buffer_callback);

    shader, err := load_shader_from_memory(VERTEX_SHADER_TEXT, FRAGMENT_SHADER_TEXT);
    if err.kind != .None do panic(err.log);
    use_shader(shader);
    
    engine.shader = shader;
    
    gl.GenVertexArrays(1, &engine.vao);
    gl.GenBuffers(1, &engine.vbo);
    
    frame_buffer_callback :: proc "c" (_: glfw.WindowHandle, w, h: c.int){
        gl.Viewport(0, 0, w, h);
    }
}

terminate :: proc(){
    glfw.Terminate();
}

should_close :: proc() -> bool{
    return cast(bool) glfw.WindowShouldClose(engine.window);
}

clear_background :: proc(color: Color){
    gl.ClearColor(color.r, color.g, color.b, color.a);
    gl.Clear(gl.COLOR_BUFFER_BIT);
}

render_loop :: proc(){
    glfw.SwapBuffers(engine.window);
    glfw.PollEvents();
    free_all(engine.ta);
}

draw_triangle_v1 :: proc(p1, p2, p3: v3, color: Color){
    vertecies := [?]v3{p1, p2, p3};
    color_loc := gl.GetUniformLocation(engine.shader, "color");
    
    gl.BindVertexArray(engine.vao);
    gl.BindBuffer(gl.ARRAY_BUFFER, engine.vbo);
    
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertecies), &vertecies, gl.DYNAMIC_DRAW);
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0);
    gl.EnableVertexAttribArray(0);
    gl.Uniform4f(color_loc, color.r, color.g, color.b, color.a);
    
    gl.DrawArrays(gl.TRIANGLES, 0, 3);
}

draw_triangle_v2 :: proc(p1, p2, p3: Vertex){
    vertecies := [?]Vertex{p1, p2, p3};
    
    gl.BindVertexArray(engine.vao);
    gl.BindBuffer(gl.ARRAY_BUFFER, engine.vbo);
    
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertecies), &vertecies, gl.DYNAMIC_DRAW);
    
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), 0);
    gl.EnableVertexAttribArray(0);
    
    gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, size_of(Vertex), offset_of(p1.color));
    gl.EnableVertexAttribArray(1);
    
    gl.DrawArrays(gl.TRIANGLES, 0, 3);
}

Color :: [4]f32;
v4    :: [4]f32;
v3    :: [3]f32;
v2    :: [2]f32;

Vertex :: struct {
    position: v3,
    color: Color,
}

Location :: c.int;

RED   :: Color{1, 0, 0, 1};
GREEN :: Color{0, 1, 0, 1};
BLUE  :: Color{0, 0, 1, 1};

VERTEX_SHADER_TEXT ::`
#version 330 core
layout (location = 0) in vec3 pos;
layout (location = 1) in vec4 color;

out vec4 vertex_color;

void main(){
    gl_Position = vec4(pos, 1.0);
    vertex_color = color;
}
`

FRAGMENT_SHADER_TEXT ::`
#version 330 core
out vec4 FragColor;

in vec4 vertex_color;

uniform vec4 color;

void main(){
    FragColor = vertex_color; //vec4(1.0, 0.5, 0.2, 1.0);
}
`
