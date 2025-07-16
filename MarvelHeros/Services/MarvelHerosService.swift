//
//  MarvelHerosService.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//


import Foundation
class MarvelHerosService: MarvelHerosServicing {
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func fetchHeros() async throws -> [Hero] {
        let endPoint = NetworkManager.EndPoint.heros
        let heros = try await self.networkManager.getData(endPoint: endPoint, type: [Hero].self)
        return heros
    }
}