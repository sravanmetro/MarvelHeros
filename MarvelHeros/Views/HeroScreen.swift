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
        ScrollView {
            VStack(spacing: 16) {
                AsyncImage(url: URL(string: hero.imageURL)) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFit()
                    case .failure(_): Color.gray.opacity(0.2)
                    case .empty: ProgressView()
                    @unknown default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 8) {
                    Text(hero.name).font(.title).bold()
                    Text("Team: \(hero.teamName)").font(.headline)
                    Text("Real name: \(hero.realName)")
                    Text("First appearance: \(hero.firstAppearance)")
                    Text("Created by: \(hero.createdBy)")
                    Text("Publisher: \(hero.publisher)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
        }
        .navigationTitle(hero.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}