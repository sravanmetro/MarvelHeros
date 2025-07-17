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

    init(service: MarvelHerosServicing) {
        self.service = service
    }
    
    @MainActor
    func fetchHeros() async {
        do {
            heros = try await service.fetchHeros()
        } catch {
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
    }
}