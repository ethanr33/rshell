const std = @import("std");

const stdout_file = std.io.getStdOut().writer();
const stdin_file = std.io.getStdIn().reader();

// List of builtin commands which are supported by the shell right now
const builtin_list = [1][]const u8{"exit"};

fn exit(status: u8) u8 {
    std.process.exit(status);
}

// Check if a string is a builtin command
pub fn isBuiltin(command: []const u8) bool {
    for (builtin_list) |s| {
        if (std.mem.eql(u8, command, s)) {
            return true;
        }
    }

    return false;
}

// Execute a builtin from a list of args, and return the error code
// Assumes that the command being executed is a builtin already
pub fn executeBuiltin(args: [][]const u8) !u8 {
    if (std.mem.eql(u8, args[0], "exit")) {
        if (args.len > 2) {
            try stdout_file.print("exit: too many arguments\n", .{});
            return 1;
        }

        const exit_code: u8 = std.fmt.parseInt(u8, args[1], 10) catch |err| {
            switch (err) {
                std.fmt.ParseIntError.InvalidCharacter => {
                    try stdout_file.print("exit: parameters are invalid\n", .{});
                    return 128;
                },
                std.fmt.ParseIntError.Overflow => {
                    try stdout_file.print("exit: parameter is out of range\n", .{});
                    return 1;
                },
            }
        };

        return exit(exit_code);
    } else {
        unreachable;
    }

    return 0;
}
