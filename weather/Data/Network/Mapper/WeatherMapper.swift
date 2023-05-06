import Foundation

struct WeatherMapper {

    static func map(_ dto: WeatherResponseDTO, location: Location) -> Weather {
        let current = CurrentWeather(
            temperature: Int(dto.current.temperature2m.rounded()),
            feelsLike: Int(dto.current.apparentTemperature.rounded()),
            humidity: dto.current.relativeHumidity2m,
            windSpeed: dto.current.windSpeed10m,
            condition: WeatherCondition(wmoCode: dto.current.weatherCode)
        )

        let daily = dto.daily.map { dailyDTO -> [DailyWeather] in
            zip(dailyDTO.time.indices, dailyDTO.time).map { index, timeStr in
                DailyWeather(
                    date: parseDate(timeStr) ?? Date(),
                    maxTemp: Int((dailyDTO.temperature2mMax[safe: index] ?? 0).rounded()),
                    minTemp: Int((dailyDTO.temperature2mMin[safe: index] ?? 0).rounded()),
                    maxWindSpeed: dailyDTO.windSpeed10mMax[safe: index] ?? 0,
                    condition: WeatherCondition(wmoCode: dailyDTO.weatherCode[safe: index] ?? 0)
                )
            }
        } ?? []

        return Weather(
            city: location,
            current: current,
            daily: daily,
            updatedAt: parseDate(dto.current.time) ?? Date()
        )
    }

    static func map(_ dto: LocationDTO) -> Location {
        Location(
            id: dto.id,
            name: dto.name,
            latitude: dto.latitude,
            longitude: dto.longitude,
            country: dto.country,
            region: dto.admin1
        )
    }

    private static func parseDate(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        if let date = formatter.date(from: string) { return date }

        let shortFormatter = DateFormatter()
        shortFormatter.dateFormat = "yyyy-MM-dd"
        return shortFormatter.date(from: string)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
