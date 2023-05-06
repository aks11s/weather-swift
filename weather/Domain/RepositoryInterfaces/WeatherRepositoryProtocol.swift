import Foundation

protocol WeatherRepositoryProtocol {
    func fetchWeather(for location: Location) async throws -> Weather
    func searchLocations(query: String) async throws -> [Location]
}
