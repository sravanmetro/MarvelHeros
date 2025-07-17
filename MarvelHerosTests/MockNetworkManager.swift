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
    var mockResponseCode: Int = 200
    var mockDelay: TimeInterval = 0
    
    override func getData<T>(endPoint: EndPoint, type: T.Type) async throws -> T where T: Decodable {
        if mockDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(mockDelay * 1_000_000_000))
        }
        
        if let error = mockError {
            throw error
        }
        
        // Simulate HTTP response
        if mockResponseCode != 200 {
            throw MarvelHerosError.noData
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
