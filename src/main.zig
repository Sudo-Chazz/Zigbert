const std = @import("std");
const http = std.http;
const process = std.process;
const uri = std.Uri;

const Config = @import("config.zig").Config;

fn fetch_weather(allocator: std.mem.Allocator, api_key: []const u8, lat: f32, lon: f32) !http.Client.Response {
    // TODO
    _ = allocator;
    _ = api_key;
    _ = lat;
    _ = lon;
    return error{TODO};
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const config_alloc = gpa.allocator();
    var config = Config.init(config_alloc) catch |e| std.debug.panic("[CONFIG ERR]: {!}", .{e});
    defer config.deinit();
    std.debug.print("PARAMETERS\n\tWeather:\n\t\tow_key: {s}\n\t\tunits: {c}\n\t\tlat: {d:.2}\n\t\tlon: {d:.2}\n\tCalendar:\n\t\tical_url: {s}\n", .{ config.ow_key.items, config.units, config.lat, config.lon, config.ical_url.items });
    // fetch_weather(gpa.allocator(), params.ow_key, params.lat.?, params.lon.?) catch |err| {
    //std.debug.print("Failed to fetch weather: {!}\n", .{err});
    //};
}
