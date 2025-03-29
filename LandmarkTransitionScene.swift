import SpriteKit

class LandmarkTransitionScene: SKScene {
    
    let landmark: Landmark
    
    // ✅ Add these two lines:
    var completionHandler: (() -> Void)? = nil
    
    // Pass the landmark when initializing the scene
    init(size: CGSize, landmark: Landmark) {
        self.landmark = landmark
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    private func setupScene() {
        backgroundColor = .black
        
        // Background image
        let backgroundNode = SKSpriteNode(imageNamed: landmark.imageName)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.size = size
        backgroundNode.zPosition = -1
        addChild(backgroundNode)
        
        // Country flag + name (emoji + name)
        let countryLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        countryLabel.text = "\(landmark.countryFlagEmoji) \(landmark.countryName)"
        countryLabel.fontSize = 40
        countryLabel.fontColor = .white
        countryLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.85)
        countryLabel.zPosition = 2
        addChild(countryLabel)
        
        // Landmark name
        let landmarkNameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        landmarkNameLabel.text = landmark.displayName
        landmarkNameLabel.fontSize = 48
        landmarkNameLabel.fontColor = .white
        landmarkNameLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        landmarkNameLabel.zPosition = 2
        addChild(landmarkNameLabel)
        
        // Fun Fact box
        let factBoxWidth = size.width * 0.8
        let factBoxHeight: CGFloat = 120
        
        let factBackground = SKShapeNode(rectOf: CGSize(width: factBoxWidth, height: factBoxHeight), cornerRadius: 16)
        factBackground.fillColor = UIColor.black.withAlphaComponent(0.6)
        factBackground.position = CGPoint(x: size.width / 2, y: size.height * 0.5)
        factBackground.zPosition = 2
        addChild(factBackground)
        
        let factLabel = SKLabelNode(fontNamed: "Helvetica")
        factLabel.text = landmark.funFact
        factLabel.fontSize = 20
        factLabel.fontColor = .white
        factLabel.numberOfLines = 0
        factLabel.preferredMaxLayoutWidth = factBoxWidth - 40
        factLabel.horizontalAlignmentMode = .center
        factLabel.verticalAlignmentMode = .center
        factLabel.position = CGPoint(x: 0, y: 0)
        factLabel.zPosition = 3
        factBackground.addChild(factLabel)
        
        // Next Level button
        let nextButtonWidth = size.width * 0.5
        let nextButtonHeight: CGFloat = 60
        
        let nextButton = SKShapeNode(rectOf: CGSize(width: nextButtonWidth, height: nextButtonHeight), cornerRadius: 12)
        nextButton.fillColor = UIColor.systemGreen
        nextButton.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        nextButton.name = "nextButton"
        nextButton.zPosition = 2
        addChild(nextButton)
        
        let nextButtonLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        nextButtonLabel.text = "Next Level ➔"
        nextButtonLabel.fontSize = 24
        nextButtonLabel.fontColor = .white
        nextButtonLabel.verticalAlignmentMode = .center
        nextButtonLabel.position = CGPoint(x: 0, y: 0)
        nextButton.addChild(nextButtonLabel)
    }
    
    // MARK: - Touches for Next Level Button
    // ✅ This makes the button trigger your handler:
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)

            let nodes = self.nodes(at: location)
            for node in nodes {
                if node.name == "nextButton" {
                    print("Next Level tapped!")

                    // ✅ Call the completion handler if it exists
                    completionHandler?()

                    // Optional: Clear the scene or do something fancy
                }
            }
        }
}
