import Foundation

class WeatherRepository: WeatherRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchWeather(for location: Location) async throws -> Weather {
        let dto = try await networkService.fetchWeatherData(
            latitude: location.latitude,
            longitude: location.longitude
        )
        return WeatherMapper.map(dto, location: location)
    }

    func searchLocations(query: String) async throws -> [Location] {
        let dtos = try await networkService.fetchLocations(query: query)
        return dtos.map(WeatherMapper.map(_:))
    }
}
