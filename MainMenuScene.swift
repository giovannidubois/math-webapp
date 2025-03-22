import SpriteKit
import GameplayKit

class MainMenuScene: SKScene {
    
    weak var gameView: GameView?
    private let dataService = DataPersistenceService()
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    private func setupScene() {
        // Set background
        backgroundColor = SKColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 1.0)
        
        // Debug test of image
        let testNode = SKSpriteNode(imageNamed: "eiffel-tower")
        testNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(testNode)
        
        // Add world map background
        let backgroundNode = SKSpriteNode(imageNamed: "world_map_background")
        backgroundNode.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundNode.size = size
        backgroundNode.alpha = 0.3
        backgroundNode.zPosition = -10
        addChild(backgroundNode)
        
        // Add title
        let titleLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        titleLabel.text = "Math Travel Adventure"
        titleLabel.fontSize = 42
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width/2, y: size.height - 100)
        titleLabel.zPosition = 1
        addChild(titleLabel)
        
        // Add subtitle
        let subtitleLabel = SKLabelNode(fontNamed: "Helvetica")
        subtitleLabel.text = "Learn math as you explore the world!"
        subtitleLabel.fontSize = 24
        subtitleLabel.fontColor = .white
        subtitleLabel.position = CGPoint(x: size.width/2, y: size.height - 150)
        subtitleLabel.zPosition = 1
        addChild(subtitleLabel)
        
        // Add flag decorations around the screen (using emoji flags)
        addFlagDecorations()
        
        // Add landmark previews
        addLandmarkPreviews()
        
        // Add menu buttons
        let buttonY = size.height/2
        let buttonSpacing: CGFloat = 70
        
        let newGameButton = createMenuButton(title: "Start New Game", yPos: buttonY + buttonSpacing)
        newGameButton.name = "newGameButton"
        addChild(newGameButton)
        
        let continueButton = createMenuButton(title: "Continue", yPos: buttonY)
        continueButton.name = "continueButton"
        addChild(continueButton)
        
        let progressButton = createMenuButton(title: "Progress", yPos: buttonY - buttonSpacing)
        progressButton.name = "progressButton"
        addChild(progressButton)
        
        let settingsButton = createMenuButton(title: "Settings", yPos: buttonY - (buttonSpacing * 2))
        settingsButton.name = "settingsButton"
        addChild(settingsButton)
    }
    
    private func addFlagDecorations() {
        // Add some emoji flags around the edges of the screen as decoration
        let flagEmojis = ["🇺🇸", "🇬🇧", "🇫🇷", "🇩🇪", "🇮🇹", "🇯🇵", "🇨🇳", "🇧🇷", "🇪🇸", "🇲🇽", "🇦🇺", "🇨🇦", "🇮🇳"]
        
        // Top row of flags
        for i in 0..<7 {
            addFlagEmoji(
                flagEmojis[i],
                position: CGPoint(x: size.width * CGFloat(i+1) / 8, y: size.height - 200)
            )
        }
        
        // Bottom row of flags
        for i in 0..<6 {
            addFlagEmoji(
                flagEmojis[i+7],
                position: CGPoint(x: size.width * CGFloat(i+1) / 7, y: 50)
            )
        }
    }
    
    private func addLandmarkPreviews() {
        // Create a carousel of landmark previews at the bottom of the screen
        let landmarks = [
            (countryId: "france", imageName: "eiffel-tower.png", name: "Eiffel Tower"),
            (countryId: "usa", imageName: "statue-of-liberty.png", name: "Statue of Liberty"),
            (countryId: "spain", imageName: "sagrada-familia.png", name: "Sagrada Familia"),
            (countryId: "china", imageName: "great-wall.png", name: "Great Wall")
        ]
        
        let previewWidth: CGFloat = 120
        let spacing: CGFloat = 20
        let totalWidth = previewWidth * CGFloat(landmarks.count) + spacing * CGFloat(landmarks.count - 1)
        let startX = (size.width - totalWidth) / 2 + previewWidth / 2
        
        for (index, landmark) in landmarks.enumerated() {
            // Create a preview container
            let previewContainer = SKNode()
            previewContainer.position = CGPoint(
                x: startX + CGFloat(index) * (previewWidth + spacing),
                y: 150
            )
            previewContainer.zPosition = 5
            addChild(previewContainer)
            
            // Landmark image - using country folder path
            let imagePath = landmark.imageName.replacingOccurrences(of: ".png", with: "")
            print("Attempting to load image: \(imagePath)") // Add this line
            let imageNode = SKSpriteNode(imageNamed: imagePath)
            imageNode.size = CGSize(width: previewWidth, height: previewWidth)
            imageNode.position = CGPoint(x: 0, y: 0)
            
            // Add a frame/border
            let frame = SKShapeNode(rectOf: CGSize(width: previewWidth + 4, height: previewWidth + 4), cornerRadius: 10)
            frame.fillColor = .clear
            frame.strokeColor = .white
            frame.lineWidth = 2
            frame.position = imageNode.position
            
            // Landmark name
            let nameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
            nameLabel.text = landmark.name
            nameLabel.fontSize = 14
            nameLabel.fontColor = .white
            nameLabel.position = CGPoint(x: 0, y: -previewWidth/2 - 15)
            
            // Add to container
            previewContainer.addChild(frame)
            previewContainer.addChild(imageNode)
            previewContainer.addChild(nameLabel)
            
            // Add subtle animation
            let scaleAction = SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 1.5),
                SKAction.scale(to: 0.95, duration: 1.5)
            ])
            previewContainer.run(SKAction.repeatForever(scaleAction))
        }
    }
    
    private func addFlagEmoji(_ emoji: String, position: CGPoint) {
        let flagLabel = SKLabelNode(fontNamed: "AppleColorEmoji")
        flagLabel.text = emoji
        flagLabel.fontSize = 30
        flagLabel.position = position
        flagLabel.zPosition = 1
        flagLabel.alpha = 0.7
        
        // Add a subtle rotating animation
        let rotateAction = SKAction.sequence([
            SKAction.rotate(byAngle: CGFloat.pi/12, duration: 2),
            SKAction.rotate(byAngle: -CGFloat.pi/6, duration: 3),
            SKAction.rotate(byAngle: CGFloat.pi/12, duration: 2)
        ])
        
        flagLabel.run(SKAction.repeatForever(rotateAction))
        addChild(flagLabel)
    }
    
    private func createMenuButton(title: String, yPos: CGFloat) -> SKNode {
        let buttonWidth: CGFloat = 250
        let buttonHeight: CGFloat = 60
        
        // Button container
        let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 15)
        button.fillColor = UIColor.blue.withAlphaComponent(0.7)
        button.strokeColor = .white
        button.lineWidth = 2
        button.position = CGPoint(x: size.width/2, y: yPos)
        button.zPosition = 5
        
        // Button shadow
        let shadow = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 15)
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.alpha = 0.3
        shadow.position = CGPoint(x: 5, y: -5)
        shadow.zPosition = 4
        button.addChild(shadow)
        
        // Button text
        let buttonLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        buttonLabel.text = title
        buttonLabel.fontSize = 24
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.position = CGPoint(x: 0, y: 0)
        buttonLabel.zPosition = 6
        button.addChild(buttonLabel)
        
        return button
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if let nodeName = node.name {
                switch nodeName {
                case "newGameButton":
                    gameView?.presentGameScene()
                    break
                    
                case "continueButton":
                    // Load saved game if available
                    gameView?.presentGameScene()
                    break
                    
                case "progressButton":
                    gameView?.presentProgressDashboard()
                    break
                    
                case "settingsButton":
                    gameView?.presentSettings()
                    break
                    
                default:
                    break
                }
            }
        }
    }
}
