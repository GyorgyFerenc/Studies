const std = @import("std");

pub fn main() !void {
    var asd = std.heap.GeneralPurposeAllocator(.{}){};
    var gpa = asd.allocator();
    const ptr = try gpa.create(i32);
    std.debug.print("ptr = {*}", .{ptr});
}
