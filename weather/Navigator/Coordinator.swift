
import Foundation
import UIKit

enum Event {
    case popToRoot
    case pop(animated: Bool)
    case dismiss
    case present(viewController: UIViewController & Routing)
    case showLocations
    case showSearch
    case showWeatherPreview(location: Location)  // modal — при добавлении
    case showWeather(location: Location)          // push — при тапе на ячейку
}

protocol Coordinator: AnyObject {
    func eventOccurred(with type: Event)
    func start()
}

protocol Routing: AnyObject {
    var coordinator: Coordinator? { get }
}

class MainCoordinator: Coordinator {

    let navigationController = UINavigationController()

    private let repository: WeatherRepositoryProtocol = WeatherRepository()
    private let storage: LocationStorageProtocol = LocationStorage()

    func start() {
        let vm = MainWeatherViewModel(repository: repository, storage: storage)
        let mainVC = MainWeatherViewController(viewModel: vm)
        mainVC.coordinator = self
        navigationController.setViewControllers([mainVC], animated: false)
    }

    func eventOccurred(with type: Event) {
        switch type {
        case .popToRoot:
            navigationController.popToRootViewController(animated: true)
        case .pop(let animated):
            navigationController.popViewController(animated: animated)
        case .dismiss:
            navigationController.dismiss(animated: true, completion: nil)
        case .present(let viewController):
            navigationController.pushViewController(viewController, animated: true)
        case .showLocations:
            let vm = LocationsViewModel(repository: repository, storage: storage)
            let locationsVC = LocationsViewController(viewModel: vm)
            locationsVC.coordinator = self
            navigationController.pushViewController(locationsVC, animated: true)

        case .showSearch:
            let searchVM = SearchViewModel(repository: repository)
            let searchVC = SearchViewController(viewModel: searchVM)
            searchVC.coordinator = self
            searchVC.onLocationSelected = { [weak self] location in
                self?.eventOccurred(with: .showWeatherPreview(location: location))
            }
            let nav = UINavigationController(rootViewController: searchVC)
            nav.modalPresentationStyle = .formSheet
            topViewController.present(nav, animated: true)

        case .showWeatherPreview(let location):
            let vm = MainWeatherViewModel(repository: repository, storage: storage, location: location)
            let previewVC = MainWeatherViewController(
                viewModel: vm,
                mode: .preview(location: location, storage: storage)
            )
            previewVC.modalPresentationStyle = .fullScreen
            topViewController.present(previewVC, animated: true)

        case .showWeather(let location):
            let vm = MainWeatherViewModel(repository: repository, storage: storage, location: location)
            let weatherVC = MainWeatherViewController(viewModel: vm, mode: .normal)
            weatherVC.coordinator = self
            navigationController.pushViewController(weatherVC, animated: true)
        }
    }

    private var topViewController: UIViewController {
        var top: UIViewController = navigationController
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}
