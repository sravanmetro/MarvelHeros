import UIKit
import SwiftUI

class HerosListModuleBuilder {
    static func build(navigationController: UINavigationController?) -> UIViewController {
        let interactor = HerosListInteractor()
        let router = HerosListRouter(navigationController: navigationController)
        let presenter = HerosListPresenter(interactor: interactor, router: router)
        interactor.presenter = presenter
        let view = HerosListView(presenter: presenter)
        return UIHostingController(rootView: view)
    }
}
