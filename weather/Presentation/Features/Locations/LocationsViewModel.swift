import Foundation

class LocationsViewModel {
    var stateDidChange: ((ViewState<[Weather]>) -> Void)?

    private(set) var state: ViewState<[Weather]> = .idle {
        didSet { stateDidChange?(state) }
    }

    private let repository: WeatherRepositoryProtocol
    private let storage: LocationStorageProtocol

    init(
        repository: WeatherRepositoryProtocol = WeatherRepository(),
        storage: LocationStorageProtocol = LocationStorage()
    ) {
        self.repository = repository
        self.storage = storage
        load()
    }

    func load() {
        let locations = storage.load()
        state = .loading

        Task { @MainActor in
            do {
                // Параллельный fetch для всех локаций
                let weathers = try await withThrowingTaskGroup(of: Weather.self) { group in
                    for location in locations {
                        group.addTask { try await self.repository.fetchWeather(for: location) }
                    }
                    var results: [Weather] = []
                    for try await weather in group {
                        results.append(weather)
                    }
                    return results
                }
                state = .loaded(weathers)
            } catch {
                state = .error(error)
            }
        }
    }

    func addLocation(_ location: Location) {
        storage.add(location)
        load()
    }

    func removeLocation(id: Int) {
        storage.remove(id: id)
        load()
    }
}
