//
//  OfflineManager.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//

import Foundation

class OfflineHerosService: MarvelHerosServicing {
    
    // Get heros from local storage - Json
    func fetchHeros() async throws -> [Hero] {
        // get JSON Path
        guard let jsonPath = Bundle.main.path(forResource: "Heros", ofType: "json") else {
            throw MarvelHerosError.invalidURL
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
            let json = try JSONDecoder().decode([Hero].self, from: data)
            return json
        } catch {
            throw MarvelHerosError.parseError
        }
    }
}

