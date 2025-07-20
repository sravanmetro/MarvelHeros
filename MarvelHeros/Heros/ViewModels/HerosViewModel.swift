//
//  HerosViewModel.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//


import Foundation

enum AppState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
    case empty
}
class HerosViewModel: ObservableObject {
    let service: MarvelHerosServicing
    @Published var heros: [Hero] = []
    @Published var state: AppState = .idle

    init(service: MarvelHerosServicing) {
        self.service = service
    }
    
    @MainActor
    func fetchHeros() async {
        state = .loading
        do {
            let result = try await service.fetchHeros()
            if result.isEmpty {
                state = .empty
            } else {
                heros = result
                state = .loaded
            }
        } catch {
            let errorMsg: String
            switch error as? MarvelHerosError {
            case .invalidURL:
                errorMsg = "Invalid URL"
            case .noData:
                errorMsg = "No data received"
            case .parseError:
                errorMsg = "Failed to parse data"
            default:
                errorMsg = "An unknown error occurred"
            }
            state = .error(errorMsg)
        }
    }
}