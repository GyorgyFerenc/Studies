package main

import "core:fmt"
import "core:c"
import "core:mem"
import "core:strings"


import "vendor:glfw"
import gl "vendor:OpenGL"
import "engine"

App :: struct{
    window: glfw.WindowHandle,
    vertex_shader: c.uint,
    fragment_shader: c.uint,
    shader_program: c.uint,
}
app: App;

main :: proc(){
    gpa := context.allocator;
    ta := context.temp_allocator;

    context.allocator = mem.panic_allocator();
    context.temp_allocator = mem.panic_allocator();

    engine.init(800, 600, "Test", ta);
    defer engine.terminate();
    
    sh, err := engine.load_shader_from_memory("", MY_FS_SHADER);
    fmt.println(err);
    
    for !engine.should_close(){
        defer engine.render_loop();
        
        engine.clear_background({0.1, 0.2, 0.3, 1.0});
        
        engine.use_shader(sh);
        defer engine.drop_shader();
        
        //engine.set_uniform(sh, "color", engine.RED);
        
        engine.draw_triangle_v2(
            {{-1,  -1, 0.0}, engine.RED},
            {{ 1,  -1, 0.0}, engine.GREEN},
            {{ 0,   1, 0.0}, engine.BLUE},
        );
    }
}

MY_FS_SHADER ::`
#version 330 core
out vec4 final_color;

in vec4 vertex_color;

uniform vec4 color;

void main(){
    final_color = vertex_color;
}
`


draw_shit :: proc(){
/*
    my_shader := load_shader("shader.vs", "shader.fs");
    
    use_shader(my_shader);
    defer drop_shader();
    
    //...
    
    camera_use(camera);
    defer camera_drop();
    
    draw_triangle_v1(p1, p2, p3, color);
*/
}

update :: proc(){
    if glfw.GetKey(app.window, glfw.KEY_ESCAPE) == glfw.PRESS{
        glfw.SetWindowShouldClose(app.window, true);
    }
}

draw :: proc(){
}

    /*
    vsc := VERTEX_SHADER_TEXT;
    app.vertex_shader = gl.CreateShader(gl.VERTEX_SHADER);
    gl.ShaderSource(app.vertex_shader, 1, &vsc, nil);
    gl.CompileShader(app.vertex_shader);
    success: c.int;
    info_log: [1024]c.char;
    gl.GetShaderiv(app.vertex_shader, gl.COMPILE_STATUS, &success);
    if success == 0{
        gl.GetShaderInfoLog(app.vertex_shader, 1024, nil, raw_data(info_log[:]));
        fmt.println(cast(string) info_log[:]);
    }
    
    fsc := FRAGMENT_SHADER_TEXT;
    app.fragment_shader = gl.CreateShader(gl.FRAGMENT_SHADER);
    gl.ShaderSource(app.fragment_shader, 1, &fsc, nil);
    gl.CompileShader(app.fragment_shader);
    gl.GetShaderiv(app.fragment_shader, gl.COMPILE_STATUS, &success);
    if success == 0{
        gl.GetShaderInfoLog(app.fragment_shader, 1024, nil, raw_data(info_log[:]));
        fmt.println(cast(string) info_log[:]);
    }
    
    app.shader_program = gl.CreateProgram();
    gl.AttachShader(app.shader_program, app.vertex_shader);
    gl.AttachShader(app.shader_program, app.fragment_shader);
    gl.LinkProgram(app.shader_program);
    gl.GetProgramiv(app.shader_program, gl.LINK_STATUS, &success);
    if success == 0{
        gl.GetProgramInfoLog(app.shader_program, 1024, nil, raw_data(info_log[:]));
        fmt.println(cast(string) info_log[:]);
    }
    gl.DeleteShader(app.vertex_shader);
    gl.DeleteShader(app.fragment_shader);

    vertecies := [?]f32{
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0,
        0.0,  0.5, 0.0,
    };
    
    vertex_array_object: c.uint;
    gl.GenVertexArrays(1, &vertex_array_object);
    gl.BindVertexArray(vertex_array_object);
    
    vertex_buffer_object: c.uint;
    gl.GenBuffers(1, &vertex_buffer_object);
    gl.BindBuffer(gl.ARRAY_BUFFER, vertex_buffer_object);
    gl.BufferData(gl.ARRAY_BUFFER, size_of(vertecies), &vertecies, gl.STATIC_DRAW);
    
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0);
    gl.EnableVertexAttribArray(0);
    */


