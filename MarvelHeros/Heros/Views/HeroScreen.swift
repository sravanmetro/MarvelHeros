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
        VStack(spacing: 12) {
            Text(hero.name)
                .font(.title)
                .accessibilityAddTraits(.isHeader)
            
            Text("Real Name: \(hero.realName)")
                .accessibilityLabel("Real name is \(hero.realName)")
            
            Text("Team: \(hero.teamName)")
                .accessibilityLabel("Member of \(hero.teamName)")
                
            Text("First Appearance: \(hero.firstAppearance)")
                .accessibilityLabel("First appeared in \(hero.firstAppearance)")
                
            Text("Created by: \(hero.createdBy)")
                .accessibilityLabel("Created by \(hero.createdBy)")
                
            Text("Publisher: \(hero.publisher)")
                .accessibilityLabel("Published by \(hero.publisher)")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(hero.name) Details")
        .navigationTitle(hero.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HeroScreen(hero: Hero(name:"Hero Name", teamName: "Avengers", realName: "Real Name", imageURL: "https://example.com/image.jpg", createdBy: "Stan Lee", publisher: "Marvel Comics", firstAppearance: "1961"))
}
