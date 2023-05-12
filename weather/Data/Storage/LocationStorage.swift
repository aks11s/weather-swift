import Foundation

protocol LocationStorageProtocol {
    func load() -> [Location]
    func save(_ locations: [Location])
    func add(_ location: Location)
    func remove(id: Int)
}

class LocationStorage: LocationStorageProtocol {
    private let key = "saved_locations"
    private let defaults = UserDefaults.standard

    private static let defaultLocations: [Location] = [
        Location(id: 1, name: "Paris", latitude: 48.8566, longitude: 2.3522, country: "France", region: "Île-de-France")
    ]

    func load() -> [Location] {
        guard let data = defaults.data(forKey: key),
              let locations = try? JSONDecoder().decode([Location].self, from: data),
              !locations.isEmpty
        else {
            return Self.defaultLocations
        }
        return locations
    }

    func save(_ locations: [Location]) {
        guard let data = try? JSONEncoder().encode(locations) else { return }
        defaults.set(data, forKey: key)
    }

    func add(_ location: Location) {
        var current = load()
        guard !current.contains(where: { $0.id == location.id }) else { return }
        current.append(location)
        save(current)
    }

    func remove(id: Int) {
        var current = load()
        current.removeAll { $0.id == id }
        save(current)
    }
}
