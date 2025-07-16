//
//  NetworkManager.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//


import Foundation
public class NetworkManager {
    public enum EndPoint: String {
        case heros = "demos/marvel/"
    }
    
    public func getData<T>(endPoint: EndPoint, type: T.Type) async throws -> T where T: Decodable {
        guard let url = URL(string: Constants.baseURL + endPoint.rawValue) else {
            throw MarvelHerosError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw MarvelHerosError.noData
        }
        
        do {
            let parsedResponse = try JSONDecoder().decode(T.self, from: data)
            return parsedResponse
        } catch {
            throw MarvelHerosError.parseError
        }
    }
}