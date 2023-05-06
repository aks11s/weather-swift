import Foundation

struct Weather {
    let city: Location
    let current: CurrentWeather
    let daily: [DailyWeather]
    let updatedAt: Date
}

struct CurrentWeather {
    let temperature: Int
    let feelsLike: Int
    let humidity: Int
    let windSpeed: Double
    let condition: WeatherCondition
}

struct DailyWeather {
    let date: Date
    let maxTemp: Int
    let minTemp: Int
    let maxWindSpeed: Double
    let condition: WeatherCondition
}
