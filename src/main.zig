const std = @import("std");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    const stdin_file = std.io.getStdIn().reader();

    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    while (true) {
        try stdout.print("> ", .{});
        try bw.flush();

        var buf: [1024]u8 = undefined;
        const string_to_encode: []u8 = try stdin_file.readUntilDelimiter(&buf, '\n');
        var argv_it = std.mem.splitScalar(u8, string_to_encode, ' ');

        var argv = std.ArrayList([]const u8).init(std.heap.page_allocator);
        defer argv.deinit();

        while (argv_it.next()) |arg| {
            try argv.append(arg);
        }

        var child = std.process.Child.init(argv.items, std.heap.page_allocator);

        try child.spawn();
        _ = child.wait() catch |err| {
            try stdout.print("Error: {}\n", .{err});
        };

    }
}
