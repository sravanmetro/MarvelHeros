import Foundation

class HerosListPresenter: ObservableObject, HerosListPresenterInput {
    @Published var heros: [Hero] = []
    @Published var error: String? = nil
    private let interactor: HerosListInteractorInput
    private let router: HerosListRouterInput
    
    init(interactor: HerosListInteractorInput, router: HerosListRouterInput) {
        self.interactor = interactor
        self.router = router
    }
    
    func onAppear() {
        interactor.fetchHeros()
    }
    
    func didFetchHeros(_ heros: [Hero]) {
        self.heros = heros
    }
    
    func didFail(with error: String) {
        self.error = error
    }
    
    func didSelectHero(_ hero: Hero) {
        router.showHeroDetail(hero)
    }
}

protocol HerosListPresenterInput: AnyObject {
    func didFetchHeros(_ heros: [Hero])
    func didFail(with error: String)
}
