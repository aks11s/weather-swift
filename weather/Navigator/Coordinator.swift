
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
    
    func start() {
        let mainWeatherVC = MainWeatherViewController()
        mainWeatherVC.coordinator = self
        navigationController.setViewControllers([mainWeatherVC], animated: false)
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
            let locationsVC = LocationsViewController()
            locationsVC.coordinator = self
            navigationController.pushViewController(locationsVC, animated: true)
        }
       
    }
}
