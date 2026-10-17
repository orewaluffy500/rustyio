const std = @import("std");
const Io = std.Io;

const rustyio = @import("rustyio");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    var stdout = try rustyio.Writer.initStdout(init.io, gpa, 2000);
    defer stdout.deinit();
    var stdin = try rustyio.Reader.initStdin(init.io, gpa, 2000);
    defer stdin.deinit();

    stdout.printlineIgnoreError("Enter your name", .{});

    const name = stdin.readlineIgnoreError(init.arena.allocator());
    stdout.printlineIgnoreError("Hello {s}!", .{name});
}
