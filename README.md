# RustyIO

#### AI usage: In my previous IO helper I used AI for basically everything but this time I actually sat down and read the documentation so I could make this work!

A simple zig IO helper.

I made this library to help with zig IO, because I feel like printing a hello world and reading a line from stdin should definitely be easier.

The `Writer` and `Reader` structs in the module both take an `std.Io` instance aswell as an `std.mem.Allocator` and `defaultBufferCapacity` and also a file.

## The Writer

The Writer has three constructors and a destructor:

- `init(io, file, allocator, bufCapacity) !Writer`: Base constructor
- `initStdout(io, allocator, bufCapacity) !Writer`: Defaults to `.stdout()` for the file
- `initStderr(io, allocator, bufCapacity) !Writer`: Defaults to `.stderr()` for the file
- `deinit() void`: destructor

And it has the methods:

- `print(comptime fmt, args) !void`: print without flushing
- `printline(comptime fmt, args) !void`: print with newline and auto-flush
- `flush() !void`: flush
- `printIgnoreError(comptime fmt, args) void`: `print` but ignores errors
- `printlineIgnoreError(comptime fmt, args) void`: `printline` but ignores errors

I would definitely love some feedback as I'm still a relatively new Zig developer. Also If you notice any memory leaks that I didn't notice, please inform me.

## The Reader

The Reader has 2 constructors and a destructor:

- `init(io, file, alloc, bufCapac) !Reader`: Base constructor
- `initStdin(io, alloc, bufCapac) !Reader`: Defaults to `.stdin()` for the file.

And it has these four methods:

- `read(alloc) ![]const u8`: reads until a space, allocates a heap slice using `alloc` and returns it, we use a seperate allocator so you can use a gpa for the base allocator but instead an arena for taking input.
- `readline(alloc) ![]const u8`: reads a line into a heap slice and returns it
- `readIgnoreError(alloc) ![]const u8`: self explanatory
- `readlineIgnoreError(alloc) ![]const u8`: self explanatory