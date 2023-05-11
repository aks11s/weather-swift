import Foundation

class LocationsViewModel {
    var stateDidChange: ((ViewState<[Weather]>) -> Void)?

    private(set) var state: ViewState<[Weather]> = .idle {
        didSet { stateDidChange?(state) }
    }

    init() {
        load()
    }

    func load() {
        state = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.state = .loaded(Self.mockLocations)
        }
    }

    private static let mockLocations: [Weather] = [
        Weather(
            city: Location(id: 1, name: "New York", latitude: 40.7128, longitude: -74.0060, country: "USA", region: "New York"),
            current: CurrentWeather(temperature: 33, feelsLike: 31, humidity: 52, windSpeed: 15, condition: .clearSky),
            daily: [],
            updatedAt: Date()
        ),
        Weather(
            city: Location(id: 2, name: "London", latitude: 51.5074, longitude: -0.1278, country: "UK", region: "England"),
            current: CurrentWeather(temperature: 18, feelsLike: 16, humidity: 71, windSpeed: 20, condition: .partlyCloudy),
            daily: [],
            updatedAt: Date()
        ),
        Weather(
            city: Location(id: 3, name: "Tokyo", latitude: 35.6762, longitude: 139.6503, country: "Japan", region: "Kanto"),
            current: CurrentWeather(temperature: 28, feelsLike: 30, humidity: 68, windSpeed: 8, condition: .clearSky),
            daily: [],
            updatedAt: Date()
        )
    ]
}
