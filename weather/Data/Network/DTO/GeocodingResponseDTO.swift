import Foundation

struct GeocodingResponseDTO: Decodable {
    let results: [LocationDTO]?
}

struct LocationDTO: Decodable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, country, admin1
    }
}
