const std = @import("std");
const config = @import("config.zig");
const weather = @import("weather.zig");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();
    var conf_out = config.Config.init(alloc) catch |e| std.debug.panic("[CONFIG ERR]: {!}", .{e});
    defer conf_out.deinit(alloc);
    std.debug.print("PARAMETERS\n\tWeather:\n\t\tow_key: {s}\n\t\tunits: {c}\n\t\tlat: {d:.2}\n\t\tlon: {d:.2}\n\tCalendar:\n\t\tical_url: {s}\n", .{ conf_out.weather.ow_key, conf_out.weather.units, conf_out.weather.lat, conf_out.weather.lon, conf_out.ical_url });

    const current_weather = weather.fetchWeather(alloc, conf_out.weather) catch |err| {
        std.debug.print("{!}\n", .{err});
        std.process.abort();
    };
    defer alloc.free(current_weather);
    std.debug.print("Current weather: {s}\n", .{current_weather});
}
