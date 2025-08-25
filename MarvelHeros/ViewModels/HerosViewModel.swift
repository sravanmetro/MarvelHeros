//
//  HerosViewModel.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//


import Foundation
@MainActor
class HerosViewModel: ObservableObject {
    let service: MarvelHerosServicing
    @Published var heros: [Hero] = []
    @Published var errorMessage: String? = nil
    
    init(service: MarvelHerosServicing = MarvelHerosService()) {
        self.service = service
    }
    
    func fetchHeros() async {
        do {
            heros = try await service.fetchHeros()
            errorMessage = nil
        } catch let serviceError {
            switch serviceError as? MarvelHerosError {
            case .invalidURL:
                self.errorMessage = "Invalid URL"
            case .invalidResponse:
                self.errorMessage = "Invalid response from server"
            case .httpError(let code):
                self.errorMessage = "Server error (\(code))"
            case .noData:
                self.errorMessage = "No data received"
            case .parseError:
                self.errorMessage = "Failed to parse data"
            case .fileNotFound:
                self.errorMessage = "Offline data not found"
            case .transport:
                self.errorMessage = "Network error"
            default:
                self.errorMessage = "An unknown error occurred"
            }
            // Attempt offline fallback
            do {
                let offline = OfflineHerosService()
                heros = try await offline.fetchHeros()
                errorMessage = nil
            } catch {
                // Keep the original errorMessage; do not override if offline fails
            }
        }
    }
}