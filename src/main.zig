const std = @import("std");
const config = @import("config.zig");
const weather = @import("weather.zig");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const config_alloc = gpa.allocator();
    var conf_out = config.Config.init(config_alloc) catch |e| std.debug.panic("[CONFIG ERR]: {!}", .{e});
    defer conf_out.deinit();
    std.debug.print("PARAMETERS\n\tWeather:\n\t\tow_key: {s}\n\t\tunits: {c}\n\t\tlat: {d:.2}\n\t\tlon: {d:.2}\n\tCalendar:\n\t\tical_url: {s}\n", .{ conf_out.weather.ow_key.items, conf_out.weather.units, conf_out.weather.lat, conf_out.weather.lon, conf_out.ical_url.items });
}
