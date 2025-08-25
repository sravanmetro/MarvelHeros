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
        
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        } catch {
            throw MarvelHerosError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw MarvelHerosError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw MarvelHerosError.httpError(code: httpResponse.statusCode)
        }
        
        do {
            let parsedResponse = try JSONDecoder().decode(T.self, from: data)
            return parsedResponse
        } catch {
            throw MarvelHerosError.parseError
        }
    }
}