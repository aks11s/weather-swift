import Foundation

class MainWeatherViewModel {
    var stateDidChange: ((ViewState<Weather>) -> Void)?

    private(set) var state: ViewState<Weather> = .idle {
        didSet { stateDidChange?(state) }
    }

    private let repository: WeatherRepositoryProtocol
    private let storage: LocationStorageProtocol
    private(set) var currentLocation: Location

    init(
        repository: WeatherRepositoryProtocol = WeatherRepository(),
        storage: LocationStorageProtocol = LocationStorage(),
        location: Location? = nil
    ) {
        self.repository = repository
        self.storage = storage
        self.currentLocation = location ?? storage.load().first ?? Location(
            id: 524901, name: "Moscow", latitude: 55.7558, longitude: 37.6173,
            country: "Russia", region: "Moscow"
        )
        loadWeather()
    }

    func loadWeather(for location: Location? = nil) {
        if let location { currentLocation = location }
        state = .loading

        Task { @MainActor in
            do {
                let weather = try await repository.fetchWeather(for: currentLocation)
                state = .loaded(weather)
            } catch {
                state = .error(error)
            }
        }
    }
}
