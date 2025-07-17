//
//  HerosViewModel.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//


import Foundation
class HerosViewModel: ObservableObject {
    let service: MarvelHerosServicing
    @Published var heros: [Hero] = []
    @Published var error: String? = nil
    weak var coordinator: HerosListCoordinator?

    init(service: MarvelHerosServicing = MarvelHerosService()) {
        self.service = service
    }

    @MainActor
    func fetchHeros() async {
        print("[ViewModel] fetchHeros called")
        do {
            heros = try await service.fetchHeros()
            print("[ViewModel] fetchHeros loaded: \(heros.count) heros")
        } catch {
            print("[ViewModel] fetchHeros error: \(error)")
            switch error as? MarvelHerosError {
            case .invalidURL:
                self.error = "Invalid URL"
            case .noData:
                self.error = "No data received"
            case .parseError:
                self.error = "Failed to parse data"
            default:
                self.error = "An unknown error occurred"
            }
        }
        // Fallback static data for UI debug
        if heros.isEmpty {
            heros = [
                Hero(name: "Spider-Man", teamName: "Avengers", realName: "Peter Parker", imageURL: "", createdBy: "Stan Lee", publisher: "Marvel", firstAppearance: "1962", bio: "Friendly neighborhood Spider-Man!"),
                Hero(name: "Iron Man", teamName: "Avengers", realName: "Tony Stark", imageURL: "", createdBy: "Stan Lee", publisher: "Marvel", firstAppearance: "1963", bio: "Genius billionaire playboy philanthropist.")
            ]
            print("[ViewModel] Fallback static heros loaded: \(heros.count)")
        }
    }

    func showHeroDetail(hero: Hero) {
        coordinator?.showHeroDetail(hero: hero)
    }
}