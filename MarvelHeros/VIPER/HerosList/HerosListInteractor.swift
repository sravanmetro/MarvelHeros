import Foundation

protocol HerosListInteractorInput {
    func fetchHeros()
}

class HerosListInteractor: HerosListInteractorInput {
    weak var presenter: HerosListPresenterInput?
    let service: MarvelHerosServicing
    
    init(service: MarvelHerosServicing = MarvelHerosService()) {
        self.service = service
    }
    
    func fetchHeros() {
        Task {
            do {
                let heros = try await service.fetchHeros()
                await MainActor.run {
                    self.presenter?.didFetchHeros(heros)
                }
            } catch {
                await MainActor.run {
                    self.presenter?.didFail(with: error.localizedDescription)
                }
            }
        }
    }
}
