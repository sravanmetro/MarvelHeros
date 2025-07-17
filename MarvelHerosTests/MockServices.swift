//
//  EmptyHerosService.swift
//  MarvelHeros
//
//  Created by Sravan on 17/07/2025.
//

import Foundation
@testable import MarvelHeros

// MARK: - Mock Services
class EmptyHerosService: MarvelHerosServicing {
    func fetchHeros() async throws -> [Hero] {
        return []
    }
}

class ErrorHerosService: MarvelHerosServicing {
    func fetchHeros() async throws -> [Hero] {
        throw MarvelHerosError.invalidURL
    }
}

class DelayedHerosService: MarvelHerosServicing {
    func fetchHeros() async throws -> [Hero] {
        // Check for cancellation before delay
        try Task.checkCancellation()
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        // Check for cancellation after delay
        try Task.checkCancellation()
        
        // Return some mock data if not cancelled
        return []
    }
}
