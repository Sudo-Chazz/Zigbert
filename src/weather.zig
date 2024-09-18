const std = @import("std");
const http = std.http;
const mem = std.mem;
const Uri = std.Uri;

const WeatherConfig = @import("config.zig").WeatherConfig;

pub fn fetch_weather(alloc: mem.Allocator, weather_config: WeatherConfig) void {
    const endpoint = ;
    const request_preset = http.Client.Request {
    };
}
