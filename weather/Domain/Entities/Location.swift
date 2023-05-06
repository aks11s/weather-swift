import Foundation

struct Location: Equatable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let region: String?
}
