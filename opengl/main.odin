package main

import "core:fmt"
import "core:c"

import "vendor:glfw"
import gl "vendor:OpenGL"

OPENGL_MAJOR :: 3;
OPENGL_MINOR :: 3;

App :: struct{
    window: glfw.WindowHandle,
    vertex_shader: c.uint,
    fragment_shader: c.uint,
    shader_program: c.uint,
}
app: App;

main :: proc(){
    glfw.Init();    
    defer glfw.Terminate();
    
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, OPENGL_MAJOR);
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, OPENGL_MINOR);
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);
    app.window = glfw.CreateWindow(800, 600, "Test", nil, nil);
    if app.window == nil{
        fmt.println("Error");
        return;
    }
    glfw.MakeContextCurrent(app.window);
    
    gl.load_up_to(OPENGL_MAJOR, OPENGL_MINOR, glfw.gl_set_proc_address);
    gl.Viewport(0, 0, 800, 600);
    
    glfw.SetFramebufferSizeCallback(app.window, frame_buffer_callback);
    
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
    
    for !glfw.WindowShouldClose(app.window){
        update();
        
        gl.ClearColor(0.2, 0.3, 0.3, 1);
        gl.Clear(gl.COLOR_BUFFER_BIT);
        
        gl.UseProgram(app.shader_program);
        gl.BindVertexArray(vertex_array_object);
        gl.DrawArrays(gl.TRIANGLES, 0, 3);
    
        glfw.SwapBuffers(app.window);
        glfw.PollEvents();
    }
}

update :: proc(){
    if glfw.GetKey(app.window, glfw.KEY_ESCAPE) == glfw.PRESS{
        glfw.SetWindowShouldClose(app.window, true);
    }
}

draw :: proc(){
}

frame_buffer_callback :: proc "c" (_: glfw.WindowHandle, w, h: c.int){
    gl.Viewport(0, 0, w, h);
}

VERTEX_SHADER_TEXT: cstring : `
#version 330 core
layout (location = 0) in vec3 pos;

void main(){
    gl_Position = vec4(pos, 1.0);
}
`

FRAGMENT_SHADER_TEXT: cstring :`
#version 330 core
out vec4 FragColor;

void main(){
    FragColor = vec4(1.0, 0.5, 0.2, 1.0);
}
`

