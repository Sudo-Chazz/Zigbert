const std = @import("std");
const ArrayList = std.ArrayList;
const fs = std.fs;
const io = std.io;
const mem = std.mem;

const tomlz = @import("tomlz");

// [==========TO-DO==========]
// * expand the error type to make debugging easier
// ↳ in regards to errors I am contemplating building out the error system
//
// * Expand the config options to allow for a more customizable experience

pub const WeatherConfig = struct {
    ow_key: []u8,
    lat: f64 = 0.00,
    lon: f64 = 0.00,
    units: u8 = 'F', // using a single char for simplicity might change to enum in future

};

pub const Config = struct {
    weather: WeatherConfig,
    ical_url: []u8,

    pub const ConfigError = error{
        ConfigNotFound,
        ConfigReadFailed,
        FailedParsingToml,
    };
    /// This function handles initialization of the users config with the use
    /// of a helper function to parse the toml file.
    pub fn init(alloc: mem.Allocator) ConfigError!Config {
        const config_file = fs.cwd().openFile("config/vars.toml", .{ .mode = .read_only }) catch return ConfigError.ConfigNotFound;
        defer config_file.close();

        const file_stat = config_file.stat() catch return ConfigError.ConfigReadFailed;
        const config_contents = config_file.reader().readAllAlloc(alloc, file_stat.size) catch return ConfigError.ConfigReadFailed;
        defer alloc.free(config_contents);

        return Config.parse(alloc, config_contents);
    }

    /// This function handles the parsing of toml objects from the config file.
    /// all allocated memory is hnadled by this function except ow_api &
    /// ical_url. which is owned by the return struct. See deinit below for
    /// freeing those.
    fn parse(alloc: mem.Allocator, table: []u8) ConfigError!Config {
        var parsed_config = tomlz.parse(alloc, table) catch return ConfigError.FailedParsingToml;
        defer parsed_config.deinit(alloc);

        // parse weather vars
        const openWeather_table = parsed_config.getTable("openWeather") orelse return ConfigError.FailedParsingToml;
        const coords = openWeather_table.getTable("coordinates") orelse return ConfigError.FailedParsingToml;

        var temp_arr = ArrayList(u8).init(alloc);
        defer temp_arr.deinit();

        var weather: WeatherConfig = .{ .ow_key = "", .lat = coords.getFloat("lat") orelse 0.00, .lon = coords.getFloat("lon") orelse 0.00, .units = @intCast(openWeather_table.getInteger("units") orelse 'F') };
        temp_arr.appendSlice(openWeather_table.getString("api_key") orelse "") catch return ConfigError.FailedParsingToml;

        weather.ow_key = temp_arr.toOwnedSlice() catch return ConfigError.FailedParsingToml;

        // parse calendar vars
        const cal_table = parsed_config.getTable("Calendar") orelse return ConfigError.FailedParsingToml;
        var parsed: Config = .{
            .weather = weather,
            .ical_url = "",
        };
        errdefer parsed.deinit(alloc);
        temp_arr.appendSlice(cal_table.getString("ical_url") orelse "") catch return ConfigError.FailedParsingToml;
        parsed.ical_url = temp_arr.toOwnedSlice() catch return ConfigError.FailedParsingToml;
        return parsed;
    }

    /// a helper function to make freeing of heap allocated items within Config easy.
    pub fn deinit(self: *Config, alloc: mem.Allocator) void {
        alloc.free(self.weather.ow_key);
        alloc.free(self.ical_url);
    }
};
