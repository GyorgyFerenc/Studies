package engine

import "core:fmt"
import "core:c"
import "core:mem"
import "core:strings"
import "core:os"

import "vendor:glfw"
import gl "vendor:OpenGL"

Shader :: c.uint;
Shader_Error :: struct{
    kind: enum{
        None = 0,
        File_Load,
        Compile,
        Link,
    },
    log: string,
};

/*
    If the any of the paths are empty the default shader is used for that
    
    Shader_Error.log is allocated with the engine.ta
*/
load_shader :: proc(vertex_shader_path, fragment_shader_path: string) -> (Shader, Shader_Error){
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
load_shader_from_memory :: proc(vertex_shader_source, fragment_shader_source: string) -> (Shader, Shader_Error){
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
    err = compile_shader(fs, fss);
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

    compile_shader :: proc(sh: c.uint, source: string) -> Shader_Error{
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

use_shader :: proc(shader: Shader){
    engine.current_shader = shader;
    gl.UseProgram(shader);
}

drop_shader :: proc(){
    use_shader(engine.shader);
}

set_uniform :: proc{
    set_uniform_by_name,
    set_uniform_by_location,
}

set_uniform_by_name :: proc(shader: Shader, name: string, value: Uniform_Type){
    loc := gl.GetUniformLocation(shader, strings.clone_to_cstring(name, engine.ta));
    set_uniform_by_location(shader, loc, value);
}

set_uniform_by_location :: proc(shader: Shader, location: Location, value: Uniform_Type){
    switch v in value{
    case f32:  gl.Uniform1f(location, v);
    case f64:  gl.Uniform1d(location, v);
    case i32:  gl.Uniform1i(location, v);
    case u32:  gl.Uniform1ui(location, v);
    case bool: gl.Uniform1i(location, cast(i32) v);
    
    case [2]f32:  gl.Uniform2f(location, v[0], v[1]);
    case [2]f64:  gl.Uniform2d(location, v[0], v[1]);
    case [2]i32:  gl.Uniform2i(location, v[0], v[1]);
    case [2]u32:  gl.Uniform2ui(location, v[0], v[1]);
    case [2]bool: gl.Uniform2i(location, cast(i32) v[0], cast(i32) v[1]);

    case [3]f32:  gl.Uniform3f(location, v[0], v[1], v[2]);
    case [3]f64:  gl.Uniform3d(location, v[0], v[1], v[2]);
    case [3]i32:  gl.Uniform3i(location, v[0], v[1], v[2]);
    case [3]u32:  gl.Uniform3ui(location, v[0], v[1], v[2]);
    case [3]bool: gl.Uniform3i(location, cast(i32) v[0], cast(i32) v[1], cast(i32) v[2]);

    case [4]f32:  gl.Uniform4f(location, v[0], v[1], v[2], v[3]);
    case [4]f64:  gl.Uniform4d(location, v[0], v[1], v[2], v[3]);
    case [4]i32:  gl.Uniform4i(location, v[0], v[1], v[2], v[3]);
    case [4]u32:  gl.Uniform4ui(location, v[0], v[1], v[2], v[3]);
    case [4]bool: gl.Uniform4i(location, cast(i32) v[0], cast(i32) v[1], cast(i32) v[2], cast(i32) v[3]);
    }
}

Uniform_Type :: union{
    f32,
    f64,
    i32,
    u32,
    bool,
    
    [2]f32,
    [2]f64,
    [2]i32,
    [2]u32,
    [2]bool,

    [3]f32,
    [3]f64,
    [3]i32,
    [3]u32,
    [3]bool,

    [4]f32,
    [4]f64,
    [4]i32,
    [4]u32,
    [4]bool,
    
    // Todo(Ferenc): Add matrices
}




