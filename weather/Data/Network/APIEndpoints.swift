import Foundation

enum APIEndpoints {
    static let forecastBase = "https://api.open-meteo.com/v1/forecast"
    static let geocodingBase = "https://geocoding-api.open-meteo.com/v1/search"

    static func forecast(latitude: Double, longitude: Double) -> URL? {
        var components = URLComponents(string: forecastBase)
        components?.queryItems = [
            .init(name: "latitude",              value: "\(latitude)"),
            .init(name: "longitude",             value: "\(longitude)"),
            .init(name: "current",               value: "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m"),
            .init(name: "hourly",                value: "temperature_2m,weather_code"),
            .init(name: "daily",                 value: "weather_code,temperature_2m_max,temperature_2m_min,wind_speed_10m_max"),
            .init(name: "timezone",              value: "auto"),
            .init(name: "forecast_days",         value: "5")
        ]
        return components?.url
    }

    static func geocoding(query: String) -> URL? {
        var components = URLComponents(string: geocodingBase)
        components?.queryItems = [
            .init(name: "name",     value: query),
            .init(name: "count",    value: "10"),
            .init(name: "language", value: "en"),
            .init(name: "format",   value: "json")
        ]
        return components?.url
    }
}
