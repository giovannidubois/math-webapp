import SpriteKit
import GameplayKit

// MARK: - Settings Scene
class SettingsScene: SKScene {
    
    weak var gameView: GameView?
    private var settings: GameSettings!
    private let dataService = DataPersistenceService()
    
    // Toggle switches
    private var musicSwitch: SKSpriteNode!
    private var soundSwitch: SKSpriteNode!
    private var adaptiveDifficultySwitch: SKSpriteNode!
    
    // Hint level buttons
    private var minimalButton: SKShapeNode!
    private var mediumButton: SKShapeNode!
    private var detailedButton: SKShapeNode!
    
    override func didMove(to view: SKView) {
        // Load settings
        settings = dataService.loadGameSettings() ?? GameSettings()
        
        setupScene()
    }
    
    private func setupScene() {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        titleLabel.text = "Settings"
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width/2, y: size.height - 50)
        titleLabel.zPosition = 1
        addChild(titleLabel)
        
        // Back button
        let backButton = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 10)
        backButton.fillColor = UIColor.gray.withAlphaComponent(0.7)
        backButton.strokeColor = .white
        backButton.lineWidth = 1
        backButton.position = CGPoint(x: 70, y: size.height - 50)
        backButton.zPosition = 1
        backButton.name = "backButton"
        addChild(backButton)
        
        let backLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        backLabel.text = "Back"
        backLabel.fontSize = 18
        backLabel.fontColor = .white
        backLabel.verticalAlignmentMode = .center
        backLabel.horizontalAlignmentMode = .center
        backLabel.position = CGPoint(x: 0, y: 0)
        backLabel.zPosition = 2
        backButton.addChild(backLabel)
        
        // Settings container
        let settingsContainer = SKShapeNode(rectOf: CGSize(width: size.width - 100, height: size.height - 150), cornerRadius: 20)
        settingsContainer.fillColor = UIColor.black.withAlphaComponent(0.3)
        settingsContainer.strokeColor = .white
        settingsContainer.lineWidth = 1
        settingsContainer.position = CGPoint(x: size.width/2, y: size.height/2 - 25)
        settingsContainer.zPosition = 0
        addChild(settingsContainer)
        
        // Sound options
        setupSoundOptions(in: settingsContainer)
        
        // Game options
        setupGameOptions(in: settingsContainer)
        
        // Save button
        let saveButton = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 15)
        saveButton.fillColor = UIColor.green.withAlphaComponent(0.7)
        saveButton.strokeColor = .white
        saveButton.lineWidth = 2
        saveButton.position = CGPoint(x: size.width/2, y: 100)
        saveButton.zPosition = 1
        saveButton.name = "saveButton"
        addChild(saveButton)
        
        let saveLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        saveLabel.text = "Save Settings"
        saveLabel.fontSize = 20
        saveLabel.fontColor = .white
        saveLabel.verticalAlignmentMode = .center
        saveLabel.horizontalAlignmentMode = .center
        saveLabel.position = CGPoint(x: 0, y: 0)
        saveLabel.zPosition = 2
        saveButton.addChild(saveLabel)
    }
    
    private func setupSoundOptions(in container: SKShapeNode) {
        let sectionLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        sectionLabel.text = "Sound Options"
        sectionLabel.fontSize = 24
        sectionLabel.fontColor = .white
        sectionLabel.position = CGPoint(x: 0, y: container.frame.height/2 - 50)
        sectionLabel.zPosition = 1
        container.addChild(sectionLabel)
        
        // Music toggle
        let musicLabel = SKLabelNode(fontNamed: "Helvetica")
        musicLabel.text = "Music"
        musicLabel.fontSize = 20
        musicLabel.fontColor = .white
        musicLabel.horizontalAlignmentMode = .left
        musicLabel.position = CGPoint(x: -container.frame.width/2 + 50, y: container.frame.height/2 - 100)
        musicLabel.zPosition = 1
        container.addChild(musicLabel)
        
        musicSwitch = createToggleSwitch(isOn: settings.musicEnabled)
        musicSwitch.position = CGPoint(x: container.frame.width/2 - 80, y: container.frame.height/2 - 100)
        musicSwitch.name = "musicSwitch"
        container.addChild(musicSwitch)
        
        // Sound effects toggle
        let soundLabel = SKLabelNode(fontNamed: "Helvetica")
        soundLabel.text = "Sound Effects"
        soundLabel.fontSize = 20
        soundLabel.fontColor = .white
        soundLabel.horizontalAlignmentMode = .left
        soundLabel.position = CGPoint(x: -container.frame.width/2 + 50, y: container.frame.height/2 - 150)
        soundLabel.zPosition = 1
        container.addChild(soundLabel)
        
        soundSwitch = createToggleSwitch(isOn: settings.soundEnabled)
        soundSwitch.position = CGPoint(x: container.frame.width/2 - 80, y: container.frame.height/2 - 150)
        soundSwitch.name = "soundSwitch"
        container.addChild(soundSwitch)
    }
    
    private func setupGameOptions(in container: SKShapeNode) {
        let sectionLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        sectionLabel.text = "Game Options"
        sectionLabel.fontSize = 24
        sectionLabel.fontColor = .white
        sectionLabel.position = CGPoint(x: 0, y: container.frame.height/2 - 230)
        sectionLabel.zPosition = 1
        container.addChild(sectionLabel)
        
        // Adaptive difficulty toggle
        let adaptiveLabel = SKLabelNode(fontNamed: "Helvetica")
        adaptiveLabel.text = "Adaptive Difficulty"
        adaptiveLabel.fontSize = 20
        adaptiveLabel.fontColor = .white
        adaptiveLabel.horizontalAlignmentMode = .left
        adaptiveLabel.position = CGPoint(x: -container.frame.width/2 + 50, y: container.frame.height/2 - 280)
        adaptiveLabel.zPosition = 1
        container.addChild(adaptiveLabel)
        
        adaptiveDifficultySwitch = createToggleSwitch(isOn: settings.adaptiveDifficulty)
        adaptiveDifficultySwitch.position = CGPoint(x: container.frame.width/2 - 80, y: container.frame.height/2 - 280)
        adaptiveDifficultySwitch.name = "adaptiveSwitch"
        container.addChild(adaptiveDifficultySwitch)
        
        // Hint level selection
        let hintLabel = SKLabelNode(fontNamed: "Helvetica")
        hintLabel.text = "Hint Level:"
        hintLabel.fontSize = 20
        hintLabel.fontColor = .white
        hintLabel.position = CGPoint(x: 0, y: container.frame.height/2 - 340)
        hintLabel.zPosition = 1
        container.addChild(hintLabel)
        
        // Hint level buttons
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        let spacing: CGFloat = 20
        let totalWidth = (buttonWidth * 3) + (spacing * 2)
        let startX = -totalWidth/2 + buttonWidth/2
        
        // Minimal button
        minimalButton = createHintLevelButton(title: "Minimal", width: buttonWidth, height: buttonHeight)
        minimalButton.position = CGPoint(x: startX, y: container.frame.height/2 - 390)
        minimalButton.name = "minimalButton"
        container.addChild(minimalButton)
        
        // Medium button
        mediumButton = createHintLevelButton(title: "Medium", width: buttonWidth, height: buttonHeight)
        mediumButton.position = CGPoint(x: startX + buttonWidth + spacing, y: container.frame.height/2 - 390)
        mediumButton.name = "mediumButton"
        container.addChild(mediumButton)
        
        // Detailed button
        detailedButton = createHintLevelButton(title: "Detailed", width: buttonWidth, height: buttonHeight)
        detailedButton.position = CGPoint(x: startX + (buttonWidth + spacing) * 2, y: container.frame.height/2 - 390)
        detailedButton.name = "detailedButton"
        container.addChild(detailedButton)
        
        // Highlight currently selected hint level
        updateHintLevelSelection()
    }
    
    private func createToggleSwitch(isOn: Bool) -> SKSpriteNode {
        let switchTexture = isOn ? SKTexture(imageNamed: "switch_on") : SKTexture(imageNamed: "switch_off")
        let switchNode = SKSpriteNode(texture: switchTexture)
        switchNode.size = CGSize(width: 60, height: 30)
        switchNode.zPosition = 2
        return switchNode
    }
    
    private func createHintLevelButton(title: String, width: CGFloat, height: CGFloat) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 10)
        button.fillColor = UIColor.blue.withAlphaComponent(0.5)
        button.strokeColor = .white
        button.lineWidth = 1
        button.zPosition = 1
        
        let label = SKLabelNode(fontNamed: "Helvetica")
        label.text = title
        label.fontSize = 16
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        label.zPosition = 2
        button.addChild(label)
        
        return button
    }
    
    private func updateHintLevelSelection() {
        // Reset all buttons
        minimalButton.fillColor = UIColor.blue.withAlphaComponent(0.5)
        mediumButton.fillColor = UIColor.blue.withAlphaComponent(0.5)
        detailedButton.fillColor = UIColor.blue.withAlphaComponent(0.5)
        
        // Highlight selected button
        switch settings.hintLevel {
        case .minimal:
            minimalButton.fillColor = UIColor.green.withAlphaComponent(0.7)
        case .medium:
            mediumButton.fillColor = UIColor.green.withAlphaComponent(0.7)
        case .detailed:
            detailedButton.fillColor = UIColor.green.withAlphaComponent(0.7)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if let nodeName = node.name {
                switch nodeName {
                case "backButton":
                    gameView?.presentMainMenu()
                    return
                    
                case "saveButton":
                    saveSettings()
                    gameView?.presentMainMenu()
                    return
                    
                case "musicSwitch":
                    settings.musicEnabled = !settings.musicEnabled
                    updateSwitchTexture(musicSwitch, isOn: settings.musicEnabled)
                    return
                    
                case "soundSwitch":
                    settings.soundEnabled = !settings.soundEnabled
                    updateSwitchTexture(soundSwitch, isOn: settings.soundEnabled)
                    return
                    
                case "adaptiveSwitch":
                    settings.adaptiveDifficulty = !settings.adaptiveDifficulty
                    updateSwitchTexture(adaptiveDifficultySwitch, isOn: settings.adaptiveDifficulty)
                    return
                    
                case "minimalButton":
                    settings.hintLevel = .minimal
                    updateHintLevelSelection()
                    return
                    
                case "mediumButton":
                    settings.hintLevel = .medium
                    updateHintLevelSelection()
                    return
                    
                case "detailedButton":
                    settings.hintLevel = .detailed
                    updateHintLevelSelection()
                    return
                    
                default:
                    break
                }
            }
        }
    }
    
    private func updateSwitchTexture(_ switchNode: SKSpriteNode, isOn: Bool) {
        let switchTexture = isOn ? SKTexture(imageNamed: "switch_on") : SKTexture(imageNamed: "switch_off")
        switchNode.texture = switchTexture
    }
    
    private func saveSettings() {
        dataService.saveGameSettings(settings)
    }
}

// MARK: - Progress Dashboard Scene
class ProgressDashboardScene: SKScene {
    
    weak var gameView: GameView?
    private let dataService = DataPersistenceService()
    
    // Progress statistics
    private var countriesVisited: Int = 0
    private var totalCountries: Int = 0
    private var landmarksVisited: Int = 0
    private var totalLandmarks: Int = 0
    private var totalTickets: Int = 0
    private var correctAnswers: Int = 0
    
    override func didMove(to view: SKView) {
        loadProgressData()
        setupScene()
    }
    
    private func loadProgressData() {
        // In a real app, this would load from data service
        // For now, using sample data
        countriesVisited = 3
        totalCountries = 40
        landmarksVisited = 7
        totalLandmarks = 120
        totalTickets = 42
        correctAnswers = 57
    }
    
    private func setupScene() {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        titleLabel.text = "Your Progress"
        titleLabel.fontSize = 36
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width/2, y: size.height - 50)
        titleLabel.zPosition = 1
        addChild(titleLabel)
        
        // Back button
        let backButton = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 10)
        backButton.fillColor = UIColor.gray.withAlphaComponent(0.7)
        backButton.strokeColor = .white
        backButton.lineWidth = 1
        backButton.position = CGPoint(x: 70, y: size.height - 50)
        backButton.zPosition = 1
        backButton.name = "backButton"
        addChild(backButton)
        
        let backLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        backLabel.text = "Back"
        backLabel.fontSize = 18
        backLabel.fontColor = .white
        backLabel.verticalAlignmentMode = .center
        backLabel.horizontalAlignmentMode = .center
        backLabel.position = CGPoint(x: 0, y: 0)
        backLabel.zPosition = 2
        backButton.addChild(backLabel)
        
        // Progress container
        let progressContainer = SKShapeNode(rectOf: CGSize(width: size.width - 100, height: size.height - 150), cornerRadius: 20)
        progressContainer.fillColor = UIColor.black.withAlphaComponent(0.3)
        progressContainer.strokeColor = .white
        progressContainer.lineWidth = 1
        progressContainer.position = CGPoint(x: size.width/2, y: size.height/2 - 25)
        progressContainer.zPosition = 0
        addChild(progressContainer)
        
        // Top stats
        setupStatCards(in: progressContainer)
        
        // Math skills
        setupMathSkills(in: progressContainer)
        
        // Continue button
        let continueButton = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 15)
        continueButton.fillColor = UIColor.blue.withAlphaComponent(0.7)
        continueButton.strokeColor = .white
        continueButton.lineWidth = 2
        continueButton.position = CGPoint(x: size.width/2, y: 100)
        continueButton.zPosition = 1
        continueButton.name = "continueButton"
        addChild(continueButton)
        
        let continueLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        continueLabel.text = "Continue Game"
        continueLabel.fontSize = 20
        continueLabel.fontColor = .white
        continueLabel.verticalAlignmentMode = .center
        continueLabel.horizontalAlignmentMode = .center
        continueLabel.position = CGPoint(x: 0, y: 0)
        continueLabel.zPosition = 2
        continueButton.addChild(continueLabel)
    }
    
    private func setupStatCards(in container: SKShapeNode) {
        let cardWidth: CGFloat = container.frame.width / 2 - 30
        let cardHeight: CGFloat = 80
        
        // Countries visited
        createStatCard(
            title: "Countries",
            value: "\(countriesVisited)/\(totalCountries)",
            position: CGPoint(x: -cardWidth/2 - 10, y: container.frame.height/2 - 70),
            size: CGSize(width: cardWidth, height: cardHeight),
            in: container
        )
        
        // Landmarks visited
        createStatCard(
            title: "Landmarks",
            value: "\(landmarksVisited)/\(totalLandmarks)",
            position: CGPoint(x: cardWidth/2 + 10, y: container.frame.height/2 - 70),
            size: CGSize(width: cardWidth, height: cardHeight),
            in: container
        )
        
        // Tickets earned
        createStatCard(
            title: "Tickets",
            value: "\(totalTickets)",
            position: CGPoint(x: -cardWidth/2 - 10, y: container.frame.height/2 - 160),
            size: CGSize(width: cardWidth, height: cardHeight),
            in: container
        )
        
        // Correct answers
        createStatCard(
            title: "Correct Answers",
            value: "\(correctAnswers)",
            position: CGPoint(x: cardWidth/2 + 10, y: container.frame.height/2 - 160),
            size: CGSize(width: cardWidth, height: cardHeight),
            in: container
        )
    }
    
    private func createStatCard(title: String, value: String, position: CGPoint, size: CGSize, in container: SKShapeNode) {
        let card = SKShapeNode(rectOf: size, cornerRadius: 10)
        card.fillColor = UIColor.blue.withAlphaComponent(0.1)
        card.strokeColor = .clear
        card.position = position
        card.zPosition = 1
        container.addChild(card)
        
        let titleLabel = SKLabelNode(fontNamed: "Helvetica")
        titleLabel.text = title
        titleLabel.fontSize = 16
        titleLabel.fontColor = .lightGray
        titleLabel.position = CGPoint(x: 0, y: 10)
        titleLabel.zPosition = 2
        card.addChild(titleLabel)
        
        let valueLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        valueLabel.text = value
        valueLabel.fontSize = 28
        valueLabel.fontColor = .white
        valueLabel.position = CGPoint(x: 0, y: -20)
        valueLabel.zPosition = 2
        card.addChild(valueLabel)
    }
    
    private func setupMathSkills(in container: SKShapeNode) {
        let sectionLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        sectionLabel.text = "Math Skills"
        sectionLabel.fontSize = 24
        sectionLabel.fontColor = .white
        sectionLabel.position = CGPoint(x: 0, y: container.frame.height/2 - 240)
        sectionLabel.zPosition = 1
        container.addChild(sectionLabel)
        
        // Sample math skills
        let skills: [(type: MathType, level: Int)] = [
            (.addition, 5),
            (.subtraction, 4),
            (.multiplication, 3),
            (.division, 2),
            (.fractions, 1)
        ]
        
        for (index, skill) in skills.enumerated() {
            createSkillRow(
                type: skill.type,
                level: skill.level,
                position: CGPoint(x: 0, y: container.frame.height/2 - 300 - CGFloat(index * 50)),
                width: container.frame.width - 100,
                in: container
            )
        }
    }
    
    private func createSkillRow(type: MathType, level: Int, position: CGPoint, width: CGFloat, in container: SKShapeNode) {
        // Skill name
        let nameLabel = SKLabelNode(fontNamed: "Helvetica")
        nameLabel.text = type.rawValue.capitalized
        nameLabel.fontSize = 18
        nameLabel.fontColor = .white
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.position = CGPoint(x: -width/2, y: position.y)
        nameLabel.zPosition = 1
        container.addChild(nameLabel)
        
        // Skill level indicator
        let levelWidth: CGFloat = 120
        let barHeight: CGFloat = 10
        let spacing: CGFloat = 2
        let barWidth: CGFloat = (levelWidth - (spacing * 4)) / 5
        
        for i in 1...5 {
            let barX = width/2 - levelWidth/2 + ((barWidth + spacing) * CGFloat(i - 1))
            let bar = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 2)
            bar.fillColor = i <= level ? .blue : UIColor.gray.withAlphaComponent(0.3)
            bar.strokeColor = .clear
            bar.position = CGPoint(x: barX, y: position.y)
            bar.zPosition = 1
            container.addChild(bar)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if let nodeName = node.name {
                switch nodeName {
                case "backButton":
                    gameView?.presentMainMenu()
                    return
                    
                case "continueButton":
                    gameView?.presentGameScene()
                    return
                    
                default:
                    break
                }
            }
        }
    }
}
