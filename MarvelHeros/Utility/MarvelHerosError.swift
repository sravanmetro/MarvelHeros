//
//  MarvelHerosError.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//


public enum MarvelHerosError: Error {
    case invalidURL
    case invalidResponse
    case httpError(code: Int)
    case noData
    case parseError
    case fileNotFound
    case transport(Error)
}
