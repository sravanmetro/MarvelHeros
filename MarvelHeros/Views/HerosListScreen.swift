//
//  HerosListScreen.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//


import SwiftUI
    
struct HerosListScreen: View {
    @StateObject var viewModel = HerosViewModel()
    
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
        if let _ = viewModel.errorMessage {
            errorView
        } else if viewModel.heros.isEmpty {
            ProgressView("Loading…")
        } else {
            herosListView
        }
    }
    
    var herosListView: some View {
        List {
            ForEach(viewModel.heros) { hero in
                NavigationLink(value: hero) {
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: hero.imageURL)) { phase in
                            switch phase {
                            case .success(let image): image.resizable().scaledToFill()
                            case .failure(_): Color.gray.opacity(0.2)
                            case .empty: ProgressView()
                            @unknown default: EmptyView()
                            }
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                        VStack(alignment: .leading) {
                            Text(hero.name)
                                .font(.headline)
                            Text("Team: \(hero.teamName)")
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .navigationDestination(for: Hero.self) { hero in
            HeroScreen(hero: hero)
        }
    }
    
    var errorView: some View {
        VStack(spacing: 12) {
            Text(viewModel.errorMessage ?? "")
                .foregroundColor(.red)
            Button("Retry") {
                Task { await viewModel.fetchHeros() }
            }
        }
        .padding()
    }
}

#Preview {
    HerosListScreen()
}
