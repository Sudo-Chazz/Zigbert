const std = @import("std");
const ascii = std.ascii;
const crypto = std.crypto;
const http = std.http;
const io = std.io;
const process = std.process;
const uri = std.Uri;

// This implementation is not perfect and quite simple
// But I did not want to have an argument parsing dep
// so I developed something that fits my specific need
const Parameters = struct {
    ow_key: crypto.hash.Md5,
    ical_url: ?[]const u8,
    lat: ?f32,
    lon: ?f32,

    fn init() Parameters {
        return Parameters{
            .ow_key = crypto.hash.Md5.init(.{}),
            .ical_url = null,
            .lat = null,
            .lon = null,
        };
    }

    fn parse(self: *Parameters, args: *process.ArgIterator) void {
        while (args.next()) |arg| {
            if (ascii.eqlIgnoreCase("-h", arg)) {
                var writer = io.getStdOut().writer();
                writer.print("-h                Displays this help dialog\n-k <MD5 Hash>     Is optional but required for weather funcionality\n-c <ical URL>     Is optional but required to synchronize calendar\n", .{}) catch |err| {
                    std.debug.panic("Error parsing args: {!}", .{err});
                };
            }
            if (ascii.eqlIgnoreCase("-k", arg)) if (args.next()) |hash| self.ow_key.update(hash);
            if (ascii.eqlIgnoreCase("-c", arg)) {
                if (args.next()) |url| {
                    self.ical_url = url;
                }
            }
            if (ascii.eqlIgnoreCase("-l", arg)) {
                if (args.next()) |coords| {
                    var coords_iter = std.mem.tokenizeSequence(u8, coords, ",");
                    if (coords_iter.next()) |val| {
                        self.lat = std.fmt.parseFloat(f32, val) catch |err| {
                            std.debug.panic("failed to parse corrdinates: {!}\n", .{err});
                        };
                    }

                    if (coords_iter.next()) |val| {
                        self.lon = std.fmt.parseFloat(f32, val) catch |err| {
                            std.debug.panic("failed to parse corrdinates: {!}\n", .{err});
                        };
                    }
                }
            }
        }
    }
};

fn fetch_weather(allocator: std.mem.Allocator, api_key: crypto.hash.Md5, lat: f32, lon: f32) !http.Client.Response {
    const crafted_req = 
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var args = process.argsWithAllocator(gpa.allocator()) catch |err| {
        std.debug.panic("{!}\n", .{err});
    };
    defer args.deinit();
    var params = Parameters.init();
    params.parse(&args);

    std.debug.print("PARAMETERS\n\tow_key: {s}\n\tical_url: {?s}\n\tlat: {?d:.2}\n\tlon: {?d:.2}\n", .{ params.ow_key.buf, params.ical_url, params.lat, params.lon });
    fetch_weather(params.ow_key, params.lat, params.lon) catch |err| {
        std.debug.print("Failed to fetch weather: {!}\n", .{err});
    };
}
