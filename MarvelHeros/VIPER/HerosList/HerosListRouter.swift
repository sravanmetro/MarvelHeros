import UIKit
import SwiftUI

protocol HerosListRouterInput {
    func showHeroDetail(_ hero: Hero)
}

class HerosListRouter: HerosListRouterInput {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func showHeroDetail(_ hero: Hero) {
        let detailView = HeroDetailView(hero: hero)
        let detailVC = UIHostingController(rootView: detailView)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
