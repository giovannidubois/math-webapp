import UIKit
import SpriteKit
import GameplayKit

// This updated class will adopt the functionality of GameView
// But keep the GameViewController name for compatibility with storyboard
class GameViewController: UIViewController, GameView {
    
    // Reference to the game services
    private let dataService = DataPersistenceService()
    private let questionGenerator = QuestionGeneratorService()
    private let spacedRepetition = SpacedRepetitionService()
    
    // Game scene
    private var gameScene: GameScene?
    private var skView: SKView!
    
    // Game state properties
    var currentGameState: GameState = .mainMenu
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view if it's not already a SKView
        if !(self.view is SKView) {
            skView = SKView(frame: view.bounds)
            skView.ignoresSiblingOrder = true
            skView.showsFPS = false
            skView.showsNodeCount = false
            view.addSubview(skView)
        } else {
            skView = self.view as? SKView
        }
        
        // Load main menu scene first
        presentMainMenu()
    }
    
    // MARK: - Scene Presentation Methods
    
    func presentMainMenu() {
        let scene = MainMenuScene(size: skView.bounds.size)
        scene.gameView = self
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        // Present the scene
        skView.presentScene(scene)
        
        currentGameState = .mainMenu
    }
    
    func presentGameScene(countryId: String? = nil, landmarkId: String? = nil) {
        gameScene = GameScene(size: skView.bounds.size)
        
        if let scene = gameScene {
            scene.gameView = self
            
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
            skView.presentScene(scene, transition: SKTransition.fade(withDuration: 1.0))
        }
        
        currentGameState = .playing
    }
    
    func presentLandmarkTransition(landmark: Landmark, onComplete: @escaping () -> Void) {
        let scene = LandmarkTransitionScene(size: skView.bounds.size, landmark: landmark)
        scene.gameView = self
        scene.completionHandler = onComplete
        
        scene.scaleMode = .aspectFill
        skView.presentScene(scene, transition: SKTransition.crossFade(withDuration: 0.5))
        
        currentGameState = .landmarkTransition
    }
    
    func presentProgressDashboard() {
        let scene = ProgressDashboardScene(size: skView.bounds.size)
        scene.gameView = self
        
        scene.scaleMode = .aspectFill
        skView.presentScene(scene, transition: SKTransition.moveIn(with: .right, duration: 0.5))
        
        currentGameState = .progressDashboard
    }
    
    func presentSettings() {
        let scene = SettingsScene(size: skView.bounds.size)
        scene.gameView = self
        
        scene.scaleMode = .aspectFill
        skView.presentScene(scene, transition: SKTransition.doorway(withDuration: 0.5))
        
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
