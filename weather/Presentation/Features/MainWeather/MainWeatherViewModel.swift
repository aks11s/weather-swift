import Foundation

class MainWeatherViewModel {
    var stateDidChange: ((ViewState<Weather>) -> Void)?

    private(set) var state: ViewState<Weather> = .idle {
        didSet {
            stateDidChange?(state)
        }
    }

    // MARK: - Mock Data

    static let mockParis = Location(
        id: 1,
        name: "Paris",
        latitude: 48.8566,
        longitude: 2.3522,
        country: "France",
        region: "Île-de-France"
    )

    static let mockWeather = Weather(
        city: mockParis,
        current: CurrentWeather(
            temperature: 24,
            feelsLike: 22,
            humidity: 56,
            windSpeed: 4.63,
            condition: .clearSky
        ),
        daily: [
            DailyWeather(
                date: Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date(),
                maxTemp: 25, minTemp: 18,
                maxWindSpeed: 5.2,
                condition: .clearSky
            ),
            DailyWeather(
                date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                maxTemp: 22, minTemp: 17,
                maxWindSpeed: 4.8,
                condition: .partlyCloudy
            ),
            DailyWeather(
                date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                maxTemp: 23, minTemp: 18,
                maxWindSpeed: 6.1,
                condition: .clearSky
            ),
            DailyWeather(
                date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                maxTemp: 25, minTemp: 19,
                maxWindSpeed: 5.0,
                condition: .clearSky
            ),
            DailyWeather(
                date: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date(),
                maxTemp: 26, minTemp: 20,
                maxWindSpeed: 4.5,
                condition: .clearSky
            ),
        ],
        updatedAt: Date()
    )

    init() {
        loadWeather()
    }

    func loadWeather() {
        state = .loading
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.state = .loaded(Self.mockWeather)
        }
    }
}
