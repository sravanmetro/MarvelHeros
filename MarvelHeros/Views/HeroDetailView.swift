import SwiftUI

struct HeroDetailView: View {
    let hero: Hero

    var body: some View {
        VStack(spacing: 16) {
            Text(hero.name).font(.largeTitle)
            Text(hero.teamName).font(.title2)
            Text(hero.bio).font(.body)
        }
        .padding()
    }
}
