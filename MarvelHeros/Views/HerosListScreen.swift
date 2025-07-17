//
//  HerosListScreen.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//


import SwiftUI
    
struct HerosListScreen: View {
    @StateObject var viewModel = HerosViewModel(service: MarvelHerosService())
    
    var body: some View {
        NavigationStack {
            homeView
                .navigationTitle("Marvel Heros")
        }
        .onAppear {
            Task {
                await viewModel.fetchHeros()
            }
        }
    }
    
    @ViewBuilder
    var homeView: some View {
        if let _ = viewModel.error {
            errorView
        } else if viewModel.heros.isEmpty {
            Text("Loading...")
                .foregroundColor(.gray)
        } else {
            herosListView
        }
    }
    
    var herosListView: some View {
        List {
            ForEach(viewModel.heros) { hero in
                NavigationLink(value: hero) {
                    VStack {
                        Text(hero.name)
                            .font(.headline)
                        Text("Team: \(hero.teamName)")
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationDestination(for: Hero.self) { hero in
            HeroScreen(hero: hero)
        }
    }
    
    var errorView: some View {
        Text(viewModel.error ?? "")
            .foregroundColor(.red)
            .padding()
    }
}

#Preview {
    HerosListScreen()
}
