import UIKit
import SpriteKit
import GameplayKit

class GameView: UIViewController {
    // Game services
    private let dataService = DataPersistenceService()
    private let questionGenerator = QuestionGeneratorService()
    private let spacedRepetition = SpacedRepetitionService()
    
    // Game scene
    private var gameScene: GameScene!
    private var skView: SKView!
    
    // State variables
    private var enteredAnswer: String = ""
    private var showHint: Bool = false
    private var showTransition: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view
        skView = SKView(frame: view.bounds)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        view.addSubview(skView)
        
        // Create and configure the game scene
        setupGameScene()
    }
    
    private func setupGameScene() {
        gameScene = GameScene(size: skView.bounds.size)
        gameScene.gameViewController = self as? GameViewController
        gameScene.scaleMode = .aspectFill
        
        // Try to load saved progress
        if let savedProgress = dataService.loadUserProgress() {
            gameScene.initializeWithProgress(savedProgress)
        } else {
            // Start a new game if no progress exists
            gameScene.initializeNewGame()
        }
        
        // Present the scene
        skView.presentScene(gameScene)
    }
    
    // MARK: - Game Interaction Methods
    
    func submitAnswer() {
        guard !enteredAnswer.isEmpty else { return }
        
        let isCorrect = gameScene.checkAnswer(enteredAnswer)
        
        if isCorrect {
            // Handle correct answer
            showHint = false
            enteredAnswer = ""
            showTransition = true
            
            // Trigger landmark transition
            if let gameViewController = gameScene.gameViewController {
                gameViewController.presentLandmarkTransition(landmark: gameScene.currentLandmark) {
                    // Move to next landmark when transition is complete
                    self.gameScene.moveToNextLandmark()
                }
            }
        } else {
            // Handle incorrect answer
            showHint = true
            enteredAnswer = ""
        }
    }
    
    // MARK: - Device Orientation Support
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// Extension to GameScene to add missing methods
extension GameScene {
    // Method to check answer (to match the previous GameView implementation)
    func checkAnswer(_ answer: String) -> Bool {
        guard !answer.isEmpty else { return false }
        
        let isCorrect = answer == currentQuestion.correctAnswer
        
        // Update question history
        updateQuestionHistory(questionId: currentQuestion.id, isCorrect: isCorrect)
        
        if isCorrect {
            handleCorrectAnswer()
            return true
        } else {
            handleIncorrectAnswer()
            return false
        }
    }
}
