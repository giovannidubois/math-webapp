import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    // Reference to the game services
    let dataService = DataPersistenceService()
    let questionGenerator = QuestionGeneratorService()
    let spacedRepetition = SpacedRepetitionService()
    
    // Game state properties
    var currentGameState: GameState = .mainMenu
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load main menu scene first
        presentMainMenu()
    }
    
    // MARK: - Scene Presentation Methods
    
    func presentMainMenu() {
        if let view = self.view as? SKView {
            let scene = MainMenuScene(size: view.bounds.size)
            scene.gameViewController = self
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            // Only set these properties on SKView
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
        
        currentGameState = .mainMenu
    }
    
    func presentGameScene(countryId: String? = nil, landmarkId: String? = nil) {
        if let view = self.view as! SKView? {
            let scene = GameScene(size: view.bounds.size)
            scene.gameViewController = self
            
            // Load saved game state if available
            if let userProgress = dataService.loadUserProgress() {
                scene.initializeWithProgress(userProgress)
            } else if let countryId = countryId, let landmarkId = landmarkId {
                scene.initializeWithLandmark(countryId: countryId, landmarkId: landmarkId)
            } else {
                // Start new game
                scene.initializeNewGame()
            }
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
        }
        
        currentGameState = .playing
    }
    
    func presentLandmarkTransition(landmark: Landmark, onComplete: @escaping () -> Void) {
        if let view = self.view as! SKView? {
            let scene = LandmarkTransitionScene(size: view.bounds.size, landmark: landmark)
            scene.gameViewController = self
            scene.completionHandler = onComplete
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene, transition: SKTransition.crossFade(withDuration: 0.5))
        }
        
        currentGameState = .landmarkTransition
    }
    
    func presentProgressDashboard() {
        if let view = self.view as! SKView? {
            let scene = ProgressDashboardScene(size: view.bounds.size)
            scene.gameViewController = self
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene, transition: SKTransition.moveIn(with: .right, duration: 0.5))
        }
        
        currentGameState = .progressDashboard
    }
    
    func presentSettings() {
        if let view = self.view as! SKView? {
            let scene = SettingsScene(size: view.bounds.size)
            scene.gameViewController = self
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene, transition: SKTransition.doorway(withDuration: 0.5))
        }
        
        currentGameState = .settings
    }
    
    // MARK: - Device Orientation Support
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// Enum to track current game state
enum GameState {
    case mainMenu
    case playing
    case landmarkTransition
    case progressDashboard
    case settings
    case profile
}
