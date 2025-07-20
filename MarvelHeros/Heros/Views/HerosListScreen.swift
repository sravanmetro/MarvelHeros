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
        switch viewModel.state {
        case .loading:
            ProgressView("Loading Heros...")
                .progressViewStyle(CircularProgressViewStyle())
                .accessibilityLabel("Loading heroes")
                .accessibilityAddTraits(.updatesFrequently)
        case .error(let message):
            Text(message)
                .foregroundColor(.red)
                .padding()
        case .empty:
            Text("No heroes found.")
                .foregroundColor(.gray)
        case .loaded:
            herosListView
        default:
            EmptyView()
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
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(hero.name) from \(hero.teamName)")
                    .accessibilityHint("Tap to view hero details")
                }
            }
        }
        .navigationDestination(for: Hero.self) { hero in
            HeroScreen(hero: hero)
        }
    }
    
    func errorView(errorMsg: String) -> any View {
        Text(errorMsg)
            .foregroundColor(.red)
            .padding()
    }
}

#Preview {
    HerosListScreen()
}
