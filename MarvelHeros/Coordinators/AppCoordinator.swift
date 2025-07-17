import UIKit
import SwiftUI

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        // Use VIPER HerosList module
        let herosListVC = HerosListModuleBuilder.build(navigationController: navigationController)
        navigationController.setViewControllers([herosListVC], animated: false)
    }
}
