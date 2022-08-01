const std = @import("std");

fn brainfuck(allocator: std.mem.Allocator, code: []const u8) !void {
    var bytes = std.ArrayList(u8).init(allocator);
    try bytes.append(0);
    var dlen: usize = 0;

    var pc: usize = 0;
    while (pc < code.len) : (pc += 1) {
        switch (code[pc]) {
            '+' => {
                bytes.items[dlen] +%= 1;
            },
            '-' => {
                bytes.items[dlen] -%= 1;
            },
            '>' => {
                dlen += 1;
                if (bytes.items.len <= dlen) {
                    try bytes.append(0);
                }
            },
            '<' => {
                if (dlen > 0) {
                    dlen -= 1;
                }
            },
            '.' => {
                try std.io.getStdOut().writer().print("{c}", .{bytes.items[dlen]});
            },
            ',' => {
                bytes.items[dlen] = try std.io.getStdIn().reader().readByte();
            },
            '[' => {
                if (bytes.items[dlen] == 0) {
                    var depth: u32 = 1;
                    while (depth > 0) {
                        pc += 1;
                        var srcCharacter = code[pc];
                        if (srcCharacter == '[') {
                            depth += 1;
                        } else if (srcCharacter == ']') {
                            depth -= 1;
                        }
                    }
                }
            },
            ']' => {
                var depth: u32 = 1;
                while (depth > 0) {
                    pc -= 1;
                    var srcCharacter = code[pc];
                    if (srcCharacter == '[') {
                        depth -= 1;
                    } else if (srcCharacter == ']') {
                        depth += 1;
                    }
                }
                pc -= 1;
            },
            else => {},
        }
    }
}

pub fn main() anyerror!void {
    var allocator = std.heap.page_allocator;
    const reader = std.io.getStdIn().reader();
    while (true) {
        var code = try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1000);
        if (code == null) break;
        try brainfuck(allocator, code.?);
    }
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
