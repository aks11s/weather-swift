import Foundation

class SearchViewModel {
    var resultsDidChange: (([Location]) -> Void)?
    var isLoadingDidChange: ((Bool) -> Void)?

    private(set) var results: [Location] = [] {
        didSet { resultsDidChange?(results) }
    }

    private var isLoading = false {
        didSet { isLoadingDidChange?(isLoading) }
    }

    private let repository: WeatherRepositoryProtocol
    private var searchTask: Task<Void, Never>?

    init(repository: WeatherRepositoryProtocol = WeatherRepository()) {
        self.repository = repository
    }

    func search(query: String) {
        searchTask?.cancel()
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }

        searchTask = Task { @MainActor in
            // Ждём 400мс — если пользователь ещё печатает, предыдущий запрос отменится
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }

            isLoading = true
            do {
                let locations = try await repository.searchLocations(query: query)
                results = locations
            } catch {
                results = []
            }
            isLoading = false
        }
    }
}
