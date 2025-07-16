//
//  HeroScreen.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//


import SwiftUI

struct HeroScreen: View {
    var hero: Hero
    
    var body: some View {
        VStack {
            Text(hero.name)
            Text(hero.teamName)
        }
        .navigationTitle(hero.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}