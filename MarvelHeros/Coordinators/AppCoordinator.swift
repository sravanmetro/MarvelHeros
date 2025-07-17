import UIKit
import SwiftUI

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let herosListCoordinator = HerosListCoordinator(navigationController: navigationController)
        childCoordinators.append(herosListCoordinator)
        herosListCoordinator.start()
    }
}
