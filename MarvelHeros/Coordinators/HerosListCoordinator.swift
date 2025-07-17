import UIKit
import SwiftUI

class HerosListCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("[Coordinator] Starting HerosListCoordinator and pushing HerosListScreen")
        let viewModel = HerosViewModel()
        viewModel.coordinator = self
        let herosListView = HerosListScreen(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: herosListView)
        navigationController.pushViewController(hostingController, animated: false)
    }
    
    func showHeroDetail(hero: Hero) {
        let heroDetailCoordinator = HeroDetailCoordinator(navigationController: navigationController, hero: hero)
        childCoordinators.append(heroDetailCoordinator)
        heroDetailCoordinator.start()
    }
}
