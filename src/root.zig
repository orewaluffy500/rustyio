//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;

pub const Writer = struct {
    const Self = @This();

    buffer: []u8,
    allocator: std.mem.Allocator,
    writer: std.Io.File.Writer,

    pub fn init(io: std.Io, file: std.Io.File, allocator: std.mem.Allocator, defaultBufferCapacity: usize) !Self {
        const buf = try allocator.alloc(u8, defaultBufferCapacity);
        const writer = std.Io.File.Writer.init(file, io, buf);
        return .{
            .buffer = buf,
            .allocator = allocator,
            .writer = writer
        };
    }

    pub fn initStdout(io: std.Io, allocator: std.mem.Allocator, defaultBufferCapacity: usize) !Self { return init(io, .stdout(), allocator, defaultBufferCapacity); }
    pub fn initStderr(io: std.Io, allocator: std.mem.Allocator, defaultBufferCapacity: usize) !Self { return init(io, .stderr(), allocator, defaultBufferCapacity); }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.buffer);
    }

    pub fn print(self: *Self, comptime fmt: []const u8, args: anytype) !void {
        try self.writer.interface.print(fmt, args);
    }

    pub fn flush(self: *Self) !void {
        try self.writer.interface.flush();
    }

    pub fn printline(self: *Self, comptime fmt: []const u8, args: anytype) !void {
        try self.print(fmt, args);
        try self.print("\n", .{});
        try self.flush();
    }

    pub fn printlineIgnoreError(self: *Self, comptime fmt: []const u8, args: anytype) void {
        _ = self.printline(fmt, args) catch 0;
    }

    pub fn printIgnoreError(self: *Self, comptime fmt: []const u8, args: anytype) void {
        _ = self.print(fmt, args) catch 0;
    }
};

pub const Reader = struct {
    const Self = @This();

    buffer: []u8,
    reader: std.Io.File.Reader,
    allocator: std.mem.Allocator,

    pub fn init(io: std.Io, file: std.Io.File, allocator: std.mem.Allocator, defaultBufferCapacity: usize) !Self {
        const buf = try allocator.alloc(u8, defaultBufferCapacity);

        return .{
            .allocator = allocator,
            .buffer = buf,
            .reader = std.Io.File.Reader.init(file, io, buf)
        };
    }

    pub fn initStdin(io: std.Io, allocator: std.mem.Allocator, defaultBufferCapacity: usize) !Self { return init(io, .stdin(), allocator, defaultBufferCapacity); }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.buffer);
    }

    pub fn read(self: *Self, stringAllocator: anytype) ![]const u8 {
        const result = try self.reader.interface.takeDelimiter('\n');
        const empty: []u8 = "";

        var it = std.mem.splitAny(u8, std.mem.trim(u8, result orelse empty, "\r"), " ");
        const final = it.next();

        return stringAllocator.dupe(u8, final);
    }

    pub fn readline(self: *Self, stringAllocator: anytype) ![]const u8 {
        const result = try self.reader.interface.takeDelimiter('\n');
        const empty: []u8 = "";

        return stringAllocator.dupe(u8, std.mem.trim(u8, result orelse empty, "\r"));
    }

    pub fn readIgnoreError(self: *Self, stringAllocator: anytype) []const u8 {
        return self.read(stringAllocator) catch "";
    }

    pub fn readlineIgnoreError(self: *Self, stringAllocator: anytype) []const u8 {
        return self.readline(stringAllocator) catch "";
    }
};