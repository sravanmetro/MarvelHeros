//
//  MockNetworkManager.swift
//  MarvelHeros
//
//  Created by Sravan on 17/07/2025.
//

import Foundation
@testable import MarvelHeros

class MockNetworkManager: NetworkManager {
    var mockData: Data?
    var mockError: Error?
    
    override func getData<T>(endPoint: EndPoint, type: T.Type) async throws -> T where T: Decodable {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData else {
            throw MarvelHerosError.noData
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw MarvelHerosError.parseError
        }
    }
}
