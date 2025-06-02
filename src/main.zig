const std = @import("std");
const builtins = @import("builtins.zig");

pub fn main() !u8 {
    const stdout_file = std.io.getStdOut().writer();
    const stdin_file = std.io.getStdIn().reader();

    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    while (true) {
        try stdout.print("> ", .{});
        try bw.flush();

        var buf: [1024]u8 = undefined;
        const command: []u8 = try stdin_file.readUntilDelimiter(&buf, '\n');
        var argv_it = std.mem.splitScalar(u8, command, ' ');

        var argv = std.ArrayList([]const u8).init(std.heap.page_allocator);
        defer argv.deinit();

        while (argv_it.next()) |arg| {
            try argv.append(arg);
        }

        // Check if the command being run is a builtin, before we attempt to run an executable
        if (builtins.isBuiltin(argv.items[0])) {
            const exit_code: u8 = try builtins.executeBuiltin(argv.items);

            _ = exit_code;
        } else {
            var child = std.process.Child.init(argv.items, std.heap.page_allocator);

            try child.spawn();
            _ = child.wait() catch |err| {
                try stdout.print("Error: {}\n", .{err});
            };
        }
    }
}
