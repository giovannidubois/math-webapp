import SpriteKit
import GameplayKit

class LandmarkTransitionScene: SKScene {
    
    weak var gameView: GameView?
    var landmark: Landmark
    var completionHandler: (() -> Void)?
    private let dataService = DataPersistenceService()
    
    init(size: CGSize, landmark: Landmark) {
        self.landmark = landmark
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        setupScene()
        animateContent()
    }
    
    private func setupScene() {
        // Background with blur effect - using the path with country folder
        let imagePath = "\(landmark.countryId)/\(landmark.imageName)"
        let backgroundNode = SKSpriteNode(imageNamed: imagePath)
        backgroundNode.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundNode.size = size
        backgroundNode.zPosition = -10
        addChild(backgroundNode)
        
        // Add blur effect using a dark overlay
        let blurOverlay = SKSpriteNode(color: .black, size: size)
        blurOverlay.position = CGPoint(x: size.width/2, y: size.height/2)
        blurOverlay.alpha = 0.5
        blurOverlay.zPosition = -5
        addChild(blurOverlay)
        
        // Get country info for this landmark
        let currentCountry = getCountryForLandmark()
        
        // Country and flag at the top (if country found)
        if let country = currentCountry {
            let countryInfoNode = SKNode()
            countryInfoNode.position = CGPoint(x: size.width/2, y: size.height - 80)
            countryInfoNode.zPosition = 2
            countryInfoNode.alpha = 0 // Will fade in during animation
            countryInfoNode.name = "countryInfo"
            addChild(countryInfoNode)
            
            // Country flag emoji
            let flagLabel = SKLabelNode(fontNamed: "AppleColorEmoji")
            flagLabel.text = country.flagEmoji
            flagLabel.fontSize = 36
            flagLabel.position = CGPoint(x: -70, y: 0)
            countryInfoNode.addChild(flagLabel)
            
            // Country name
            let countryName = SKLabelNode(fontNamed: "Helvetica-Bold")
            countryName.text = country.name
            countryName.fontSize = 28
            countryName.fontColor = .white
            countryName.position = CGPoint(x: 20, y: 0)
            countryInfoNode.addChild(countryName)
        }
        
        // Landmark image without blur - using the path with country folder
        let landmarkImage = SKSpriteNode(imageNamed: imagePath)
        landmarkImage.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
        landmarkImage.setScale(0.8)
        landmarkImage.zPosition = 1
        // Apply rounded corners effect
        landmarkImage.name = "landmarkImage"
        addChild(landmarkImage)
        
        // Landmark name
        let nameLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        nameLabel.text = landmark.displayName
        nameLabel.fontSize = 36
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        nameLabel.zPosition = 2
        nameLabel.name = "nameLabel"
        nameLabel.alpha = 0 // Will fade in
        addChild(nameLabel)
        
        // Fun fact container
        let factBackground = SKShapeNode(rectOf: CGSize(width: size.width - 100, height: 100), cornerRadius: 15)
        factBackground.fillColor = UIColor.black.withAlphaComponent(0.6)
        factBackground.strokeColor = .clear
        factBackground.position = CGPoint(x: size.width/2, y: size.height/2 - 200)
        factBackground.zPosition = 2
        factBackground.name = "factBackground"
        factBackground.alpha = 0 // Will fade in
        addChild(factBackground)
        
        // Fun fact text
        let factLabel = SKLabelNode(fontNamed: "Helvetica")
        factLabel.text = landmark.funFact
        factLabel.fontSize = 18
        factLabel.fontColor = .white
        factLabel.preferredMaxLayoutWidth = size.width - 150
        factLabel.numberOfLines = 0
        factLabel.verticalAlignmentMode = .center
        factLabel.position = CGPoint(x: 0, y: 0)
        factLabel.zPosition = 3
        factBackground.addChild(factLabel)
        
        // Next button
        let buttonNode = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 15)
        buttonNode.fillColor = UIColor.green
        buttonNode.strokeColor = .white
        buttonNode.lineWidth = 2
        buttonNode.position = CGPoint(x: size.width/2, y: 100)
        buttonNode.zPosition = 3
        buttonNode.name = "nextButton"
        buttonNode.alpha = 0 // Will fade in
        addChild(buttonNode)
        
        let buttonLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        buttonLabel.text = "Next Level"
        buttonLabel.fontSize = 22
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.position = CGPoint(x: 0, y: 0)
        buttonLabel.zPosition = 4
        buttonNode.addChild(buttonLabel)
    }
    
    private func getCountryForLandmark() -> Country? {
        // Get all countries from the data service
        let allCountries = getAllCountries()
        
        // Find the country that contains this landmark
        return allCountries.first { $0.id == landmark.countryId }
    }
    
    private func getAllCountries() -> [Country] {
        // In a real app, this would come from your data service
        // For now, we'll return a simple array of countries with emoji flags
        return [
            Country(id: "france", name: "France", flagEmoji: "🇫🇷", landmarks: [
                "eiffel-tower", "louvre-museum", "mont-saint-michel", "notre-dame", "palace-of-versailles"
            ], visitOrder: 1),
            
            Country(id: "spain", name: "Spain", flagEmoji: "🇪🇸", landmarks: [
                "alhambra", "park-gell", "plaza-mayor", "sagrada-familia", "seville-cathedral"
            ], visitOrder: 2),
            
            Country(id: "usa", name: "United States", flagEmoji: "🇺🇸", landmarks: [
                "golden-gate-bridge", "grand-canyon", "statue-of-liberty", "times-square", "yellowstone-national-park"
            ], visitOrder: 3),
            
            Country(id: "china", name: "China", flagEmoji: "🇨🇳", landmarks: [
                "great-wall"
            ], visitOrder: 4)
        ]
    }
    
    private func animateContent() {
        // Animate landmark image
        let landmarkImage = childNode(withName: "landmarkImage")
        landmarkImage?.run(SKAction.sequence([
            SKAction.scale(to: 0.7, duration: 0.5),
            SKAction.scale(to: 0.75, duration: 0.5)
        ]))
        
        // Fade in country info
        let countryInfo = childNode(withName: "countryInfo")
        countryInfo?.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
        
        // Fade in name
        let nameLabel = childNode(withName: "nameLabel")
        nameLabel?.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
        
        // Fade in fact
        let factBackground = childNode(withName: "factBackground")
        factBackground?.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
        
        // Fade in button
        let nextButton = childNode(withName: "nextButton")
        nextButton?.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.5),
            SKAction.fadeIn(withDuration: 0.5)
        ]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "nextButton" {
                // Call completion handler to move to next level
                completionHandler?()
                break
            }
        }
    }
}
