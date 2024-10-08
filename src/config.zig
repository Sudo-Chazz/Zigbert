const std = @import("std");
const ArrayList = std.ArrayList;
const fs = std.fs;
const io = std.io;
const mem = std.mem;

const tomlz = @import("tomlz");

pub const WeatherConfig = struct {
    ow_key: ArrayList(u8),
    lat: f64 = 0.00,
    lon: f64 = 0.00,
    units: u8 = 'F', // using a single char for simplicity might change to enum in future

};

pub const Config = struct {
    weather: WeatherConfig,
    ical_url: ArrayList(u8),

    pub const ConfigError = error{
        ConfigNotFound,
        ConfigReadFailed,
        FailedParsingToml,
    };
    /// File content is released at the end of this function but need to safely deinit toml table
    /// This could be done if the values gotten from tomlz were copied to struct instead of
    /// referencing table values.
    pub fn init(alloc: mem.Allocator) ConfigError!Config {
        const config_file = fs.cwd().openFile("config/vars.toml", .{ .mode = .read_only }) catch return ConfigError.ConfigNotFound;
        defer config_file.close();

        const file_stat = config_file.stat() catch return ConfigError.ConfigReadFailed;
        const config_contents = config_file.reader().readAllAlloc(alloc, file_stat.size) catch return ConfigError.ConfigReadFailed;
        defer alloc.free(config_contents);

        return Config.parse(alloc, config_contents);
    }

    fn parse(alloc: mem.Allocator, table: []u8) ConfigError!Config {
        var parsed_config = tomlz.parse(alloc, table) catch return ConfigError.FailedParsingToml;
        defer parsed_config.deinit(alloc);

        // parse weather vars
        const openWeather_table = parsed_config.getTable("openWeather") orelse return ConfigError.FailedParsingToml;
        const coords = openWeather_table.getTable("coordinates") orelse return ConfigError.FailedParsingToml;

        var weather = WeatherConfig{ .ow_key = ArrayList(u8).init(alloc), .lat = coords.getFloat("lat") orelse 0.00, .lon = coords.getFloat("lon") orelse 0.00, .units = @intCast(openWeather_table.getInteger("units") orelse 'F') };
        weather.ow_key.appendSlice(openWeather_table.getString("api_key") orelse "") catch return ConfigError.FailedParsingToml;

        // parse calendar vars
        const cal_table = parsed_config.getTable("Calendar") orelse return ConfigError.FailedParsingToml;
        var parsed: Config = .{
            .weather = weather,
            .ical_url = ArrayList(u8).init(alloc),
        };
        errdefer parsed.deinit();
        parsed.ical_url.appendSlice(cal_table.getString("ical_url") orelse "") catch return ConfigError.FailedParsingToml;

        return parsed;
    }

    pub fn deinit(self: *Config) void {
        self.weather.ow_key.deinit();
        self.ical_url.deinit();
    }
};
