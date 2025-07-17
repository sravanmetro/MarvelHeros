import SwiftUI

struct HerosListView: View {
    @ObservedObject var presenter: HerosListPresenter
    
    var body: some View {
        VStack {
            if let error = presenter.error {
                Text(error).foregroundColor(.red)
            } else if presenter.heros.isEmpty {
                Text("Loading...").foregroundColor(.gray)
            } else {
                List(presenter.heros) { hero in
                    Button(action: {
                        presenter.didSelectHero(hero)
                    }) {
                        VStack(alignment: .leading) {
                            Text(hero.name).font(.headline)
                            Text("Team: \(hero.teamName)").font(.subheadline)
                        }
                    }
                }
            }
        }
        .onAppear {
            presenter.onAppear()
        }
    }
}
