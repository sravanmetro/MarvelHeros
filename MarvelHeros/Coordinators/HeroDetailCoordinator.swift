import UIKit
import SwiftUI

class HeroDetailCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    let hero: Hero
    
    init(navigationController: UINavigationController, hero: Hero) {
        self.navigationController = navigationController
        self.hero = hero
    }
    
    func start() {
        let heroScreen = HeroScreen(hero: hero)
        let hostingController = UIHostingController(rootView: heroScreen)
        navigationController.pushViewController(hostingController, animated: true)
    }
}
