const std = @import("std");
const ArrayList = std.ArrayList;
const Client = std.http.Client;
const mem = std.mem;
const Uri = std.Uri;

const WeatherConfig = @import("config.zig").WeatherConfig;

const Weather = error{
    FailedToOpen,
    FailedToSend,
    FailedToWait,
    FailedToFinish,
    UriParseError,
};

pub fn fetchWeather(alloc: mem.Allocator, weather_config: WeatherConfig) ![]u8 {
    var client = Client{ .allocator = alloc };
    const url = std.fmt.allocPrint(alloc, "https://api.openweathermap.org/data/2.5/weather?lat={d}&lon={d}&appid={s}", .{ weather_config.lat, weather_config.lon, weather_config.ow_key }) catch |err| return err;
    std.debug.print("{s}\n", .{url});
    const uri = Uri.parse(url) catch return Weather.UriParseError;
    defer {
        client.deinit();
        alloc.free(url);
    }

    const server_header_buf: []u8 = alloc.alloc(u8, 1024 * 8) catch |err| return err;
    defer alloc.free(server_header_buf);

    var data = client.open(.GET, uri, .{ .server_header_buffer = server_header_buf }) catch return Weather.FailedToOpen;
    defer data.deinit();

    data.send() catch return Weather.FailedToSend;
    data.finish() catch return Weather.FailedToFinish;
    data.wait() catch return Weather.FailedToWait;

    const resp_body = data.reader().readAllAlloc(alloc, 1024 * 8) catch |err| return err;

    return resp_body;
}
