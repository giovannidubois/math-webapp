import SwiftUI
import SpriteKit
import GameplayKit

struct SpriteGameView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GameViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}

struct GameViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameViewController {
        // Create and return a new instance of GameViewController
        return GameViewController()
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: Context) {
        // Updates happen automatically in the GameViewController
    }
}
