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
    ta: mem.Allocator, // temporary_allocator
}
engine: Engine;

init :: proc(ta: mem.Allocator){
    engine.ta = ta;

    glfw.Init();    
    
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, OPENGL_MAJOR);
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, OPENGL_MINOR);
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);
}

terminate :: proc(){
    glfw.Terminate();
}

create_main_window :: proc(width, height: int, title: string){
    w, h := cast(c.int) width, cast(c.int) height;
    
    t := strings.clone_to_cstring(title, engine.ta);

    engine.window = glfw.CreateWindow(w, h, t, nil, nil);
    if engine.window == nil{
        panic("Window could not be created");
    }
    
    glfw.MakeContextCurrent(engine.window);
    glfw.SetFramebufferSizeCallback(engine.window, frame_buffer_callback);
    
    gl.load_up_to(OPENGL_MAJOR, OPENGL_MINOR, glfw.gl_set_proc_address);
    gl.Viewport(0, 0, w, h);
    
    frame_buffer_callback :: proc "c" (_: glfw.WindowHandle, w, h: c.int){
        gl.Viewport(0, 0, w, h);
    }
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

draw_triangle :: proc(p1, p2, p3: Vertex){
}

/*
    If the any of the paths are empty the default shader is used for that
    
    Shader_Error.log is allocated with the engine.ta
*/
load_shader_from_file :: proc(vertex_shader_path, fragment_shader_path: string) -> (Shader, Shader_Error){
    vss := VERTEX_SHADER_TEXT;
    fss := FRAGMENT_SHADER_TEXT;
    
    if vertex_shader_path != ""{
        err: Shader_Error;
        vss, err = load_file(vertex_shader_path);
        if err.kind != .None do return {}, err;
    }
    if fragment_shader_path != ""{
        err: Shader_Error;
        fss, err = load_file(fragment_shader_path);
        if err.kind != .None do return {}, err;
    }

    return load_shader(vss, fss);
    
    load_file :: proc(path: string) -> (string, Shader_Error){
        source, ok := os.read_entire_file(path, engine.ta);
        if !ok{
            return {}, {kind = .File_Load, log = strings.clone(path, engine.ta)};
        }
        return cast(string) source, {};
    }
}

/*
    If the any of the sources are empty the default shader is used for that
    
    Shader_Error.log is allocated with the engine.ta
*/
load_shader :: proc(vertex_shader_source, fragment_shader_source: string) -> (Shader, Shader_Error){
    vss := vertex_shader_source;
    fss := fragment_shader_source;
    if vss == "" do vss = VERTEX_SHADER_TEXT;
    if fss == "" do fss = FRAGMENT_SHADER_TEXT;
    
    vs := gl.CreateShader(gl.VERTEX_SHADER);
    defer gl.DeleteShader(vs);
    err := compile_shader(vs, vss);
    if err.kind != .None do return {}, err;
    
    fs := gl.CreateShader(gl.FRAGMENT_SHADER);
    defer gl.DeleteShader(fs);
    err = compile_shader(fs, fss, "Fragment Shader:\n");
    if err.kind != .None do return {}, err;
    
    shader := gl.CreateProgram();
    gl.AttachShader(shader, vs);
    gl.AttachShader(shader, fs);
    gl.LinkProgram(shader);
    success: c.int;
    gl.GetProgramiv(shader, gl.LINK_STATUS, &success);
    if success == 0{
        info_log_len: c.int;
        gl.GetProgramiv(shader, gl.INFO_LOG_LENGTH, &info_log_len);
        err := Shader_Error{
            kind = .Link,
            log = cast(string)  make([]u8, info_log_len, allocator = engine.ta),
        };
        gl.GetProgramInfoLog(shader, info_log_len - 1, nil, raw_data(err.log[:])); // ignore NULL termination
        return {}, err;
    }

    return shader, {};

    compile_shader :: proc(sh: c.uint, source: string, err_msg: string) -> Shader_Error{
        err := Shader_Error{};
        
        csource := cast(cstring) raw_data(source);
        lengths := [?]c.int{ cast(c.int) len(source)};
        gl.ShaderSource(sh, 1, &csource, cast([^]c.int) &lengths);
        gl.CompileShader(sh);
        success: c.int;
        gl.GetShaderiv(sh, gl.COMPILE_STATUS, &success);
        if success == 0{
            info_log_len: c.int;
            gl.GetShaderiv(sh, gl.INFO_LOG_LENGTH, &info_log_len);
            err.kind = .Compile;
            err.log = cast(string) make([]u8, info_log_len, allocator = engine.ta);
            gl.GetShaderInfoLog(sh, info_log_len - 1, nil, raw_data(err.log[:])); // ignore NULL termination
        }
        return err;
    }
}

Shader_Error :: struct{
    kind: enum{
        None = 0,
        File_Load,
        Compile,
        Link,
    },
    log: string,
};

Shader :: c.uint;

Color :: [4]f32;
v4    :: [4]f32;
v3    :: [3]f32;
v2    :: [2]f32;

Vertex :: struct{
    position: v3,
    color: Color,
}

VERTEX_SHADER_TEXT ::`
#version 330 core
layout (location = 0) in vec3 pos;

void main(){
    gl_Position = vec4(pos, 1.0);
}
`

FRAGMENT_SHADER_TEXT ::`
#version 330 core
out vec4 FragColor;

void main(){
    FragColor = vec4(1.0, 0.5, 0.2, 1.0);
}
`
