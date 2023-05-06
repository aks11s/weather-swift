import Foundation

protocol NetworkServiceProtocol {
    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> WeatherResponseDTO
    func fetchLocations(query: String) async throws -> [LocationDTO]
}

class NetworkService: NetworkServiceProtocol {
    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> WeatherResponseDTO {
        guard let url = APIEndpoints.forecast(latitude: latitude, longitude: longitude) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(WeatherResponseDTO.self, from: data)
    }

    func fetchLocations(query: String) async throws -> [LocationDTO] {
        guard let url = APIEndpoints.geocoding(query: query) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(GeocodingResponseDTO.self, from: data)
        return response.results ?? []
    }
}
