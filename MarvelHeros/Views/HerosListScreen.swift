//
//  HerosListScreen.swift
//  MarvelHeros
//
//  Created by Sravan on 16/07/2025.
//


import SwiftUI
    

struct HerosListScreen: View {
    @ObservedObject var viewModel: HerosViewModel

    var body: some View {
        print("[SwiftUI] HerosListScreen body loaded. Heros count: \(viewModel.heros.count)")
        return VStack {
            if let _ = viewModel.error {
                errorView
            } else if viewModel.heros.isEmpty {
                Text("Loading...")
                    .foregroundColor(.gray)
            } else {
                herosListView
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchHeros()
            }
        }
    }

    var herosListView: some View {
        List(viewModel.heros) { hero in
            Button(action: {
                viewModel.showHeroDetail(hero: hero)
            }) {
                VStack(alignment: .leading) {
                    Text(hero.name)
                        .font(.headline)
                    Text("Team: \(hero.teamName)")
                        .font(.subheadline)
                }
            }
        }
    }

    var errorView: some View {
        Text(viewModel.error ?? "")
            .foregroundColor(.red)
            .padding()
    }
}

//#Preview {
//    HerosListScreen()
//}
