//
//  MarvelHerosServicing.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//


import Foundation
protocol MarvelHerosServicing {
    func fetchHeros() async throws -> [Hero]
}