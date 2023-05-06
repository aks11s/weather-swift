import Foundation

struct WeatherResponseDTO: Decodable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let current: CurrentDTO
    let hourly: HourlyDTO?
    let daily: DailyDTO?

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, timezone, current, hourly, daily
    }
}

struct CurrentDTO: Decodable {
    let time: String
    let temperature2m: Double
    let relativeHumidity2m: Int
    let weatherCode: Int
    let windSpeed10m: Double
    let apparentTemperature: Double

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m          = "temperature_2m"
        case relativeHumidity2m     = "relative_humidity_2m"
        case weatherCode            = "weather_code"
        case windSpeed10m           = "wind_speed_10m"
        case apparentTemperature    = "apparent_temperature"
    }
}

struct HourlyDTO: Decodable {
    let time: [String]
    let temperature2m: [Double]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m  = "temperature_2m"
        case weatherCode    = "weather_code"
    }
}

struct DailyDTO: Decodable {
    let time: [String]
    let weatherCode: [Int]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let windSpeed10mMax: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode        = "weather_code"
        case temperature2mMax   = "temperature_2m_max"
        case temperature2mMin   = "temperature_2m_min"
        case windSpeed10mMax    = "wind_speed_10m_max"
    }
}
