
import Foundation
import UIKit

enum Event {
    case popToRoot
    case pop(animated: Bool)
    case dismiss
    case present(viewController: UIViewController & Routing)
    case showLocations
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
        }
    }
}
