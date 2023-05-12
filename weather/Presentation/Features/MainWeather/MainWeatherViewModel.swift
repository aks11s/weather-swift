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
        storage: LocationStorageProtocol = LocationStorage()
    ) {
        self.repository = repository
        self.storage = storage
        self.currentLocation = storage.load().first ?? Location(
            id: 0, name: "Paris", latitude: 48.8566, longitude: 2.3522,
            country: "France", region: "Île-de-France"
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
