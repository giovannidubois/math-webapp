import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Reference to game controller
    weak var gameViewController: GameViewController?
    
    // Game model properties
    var currentCountry: Country!
    var currentLandmark: Landmark!
    var currentQuestion: MathQuestion!
    var currentScore: Int = 0
    var totalTickets: Int = 0
    
    // Services
    let dataService = DataPersistenceService()
    let questionGenerator = QuestionGeneratorService()
    let spacedRepetition = SpacedRepetitionService()
    
    // UI Elements
    private var backgroundNode: SKSpriteNode!
    private var countryNameLabel: SKLabelNode!
    private var countryFlagLabel: SKLabelNode!
    private var landmarkNameLabel: SKLabelNode!
    private var questionLabel: SKLabelNode!
    private var userAnswerLabel: SKLabelNode!
    private var hintLabel: SKLabelNode!
    private var scoreNodes: [SKSpriteNode] = []
    private var ticketsLabel: SKLabelNode!
    
    // Keyboard elements
    private var keyboardButtons: [SKNode] = []
    private var enteredAnswer: String = ""
    private var showingHint: Bool = false
    
    // Game state
    var countries: [Country] = []
    var landmarks: [Landmark] = []
    var questions: [MathQuestion] = []
    var userProgress: UserProgress!
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    // MARK: - Scene Setup
    
    private func setupScene() {
        // Setup the background
        backgroundColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        
        // Setup game elements
        setupBackground()
        setupHeader()
        setupMathProblem()
        setupKeyboard()
        
        // Generate first question if needed
        if currentQuestion == nil {
            generateQuestion()
        }
        
        // Update UI with current data
        updateUI()
    }
    
    private func setupBackground() {
        // Create a background based on current landmark
        if currentLandmark != nil {
            // Use the proper path for the landmark image based on country and landmark
            let imagePath = "\(currentLandmark.countryId)/\(currentLandmark.imageName)"
            backgroundNode = SKSpriteNode(imageNamed: imagePath)
            backgroundNode.position = CGPoint(x: size.width/2, y: size.height/2)
            backgroundNode.size = size
            backgroundNode.zPosition = -10
            addChild(backgroundNode)
            
            // Add a semi-transparent overlay for better text contrast
            let overlay = SKSpriteNode(color: .black, size: size)
            overlay.alpha = 0.3
            overlay.position = CGPoint(x: size.width/2, y: size.height/2)
            overlay.zPosition = -5
            addChild(overlay)
        }
    }
    
    private func setupHeader() {
        // Country and flag display
        let headerY = size.height - 80
        
        // Create a container for country info
        let countryContainer = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 15)
        countryContainer.position = CGPoint(x: 120, y: headerY)
        countryContainer.fillColor = UIColor.black.withAlphaComponent(0.6)
        countryContainer.strokeColor = .clear
        countryContainer.zPosition = 1
        addChild(countryContainer)
        
        // Country name
        countryNameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        countryNameLabel.text = currentCountry?.name ?? "Country"
        countryNameLabel.fontSize = 20
        countryNameLabel.fontColor = .white
        countryNameLabel.position = CGPoint(x: -20, y: -7) // Adjusted position for layout with emoji
        countryNameLabel.zPosition = 2
        countryContainer.addChild(countryNameLabel)
        
        // Country flag emoji
        if let currentCountry = currentCountry {
            countryFlagLabel = SKLabelNode(fontNamed: "AppleColorEmoji")
            countryFlagLabel.text = currentCountry.flagEmoji
            countryFlagLabel.fontSize = 24
            countryFlagLabel.verticalAlignmentMode = .center
            countryFlagLabel.position = CGPoint(x: 70, y: -7)
            countryFlagLabel.zPosition = 2
            countryContainer.addChild(countryFlagLabel)
        }
        
        // Score display
        let scoreContainer = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 15)
        scoreContainer.position = CGPoint(x: size.width - 120, y: headerY)
        scoreContainer.fillColor = UIColor.black.withAlphaComponent(0.6)
        scoreContainer.strokeColor = .clear
        scoreContainer.zPosition = 1
        addChild(scoreContainer)
        
        // Star score indicators
        for i in 0..<5 {
            let starNode = SKSpriteNode(imageNamed: "star_empty")
            starNode.size = CGSize(width: 25, height: 25)
            starNode.position = CGPoint(x: -80 + CGFloat(i * 30), y: -5)
            starNode.zPosition = 2
            scoreContainer.addChild(starNode)
            scoreNodes.append(starNode)
        }
        
        // Tickets counter
        ticketsLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        ticketsLabel.text = "\(totalTickets)"
        ticketsLabel.fontSize = 20
        ticketsLabel.fontColor = .white
        ticketsLabel.position = CGPoint(x: 70, y: -7)
        ticketsLabel.zPosition = 2
        scoreContainer.addChild(ticketsLabel)
    }
    
    private func setupMathProblem() {
        // Landmark name
        landmarkNameLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        landmarkNameLabel.text = currentLandmark?.displayName ?? "Landmark"
        landmarkNameLabel.fontSize = 32
        landmarkNameLabel.fontColor = .white
        landmarkNameLabel.position = CGPoint(x: size.width/2, y: size.height - 150)
        landmarkNameLabel.zPosition = 5
        addChild(landmarkNameLabel)
        
        // Question background
        let questionBackground = SKShapeNode(rectOf: CGSize(width: 300, height: 60), cornerRadius: 15)
        questionBackground.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
        questionBackground.fillColor = UIColor.black.withAlphaComponent(0.6)
        questionBackground.strokeColor = .clear
        questionBackground.zPosition = 5
        addChild(questionBackground)
        
        // Question text
        questionLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        questionLabel.text = currentQuestion?.questionText ?? "9 + 5 = ?"
        questionLabel.fontSize = 24
        questionLabel.fontColor = .white
        questionLabel.position = CGPoint(x: 0, y: -10)
        questionLabel.zPosition = 6
        questionBackground.addChild(questionLabel)
        
        // Answer input field
        let answerBackground = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        answerBackground.position = CGPoint(x: size.width/2, y: size.height/2 - 20)
        answerBackground.fillColor = UIColor.white.withAlphaComponent(0.8)
        answerBackground.strokeColor = .gray
        answerBackground.zPosition = 5
        addChild(answerBackground)
        
        // Answer text
        userAnswerLabel = SKLabelNode(fontNamed: "Helvetica")
        userAnswerLabel.text = ""
        userAnswerLabel.fontSize = 24
        userAnswerLabel.fontColor = .black
        userAnswerLabel.position = CGPoint(x: 0, y: -8)
        userAnswerLabel.zPosition = 6
        answerBackground.addChild(userAnswerLabel)
        
        // Hint label (initially hidden)
        let hintBackground = SKShapeNode(rectOf: CGSize(width: 350, height: 60), cornerRadius: 10)
        hintBackground.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        hintBackground.fillColor = UIColor.blue.withAlphaComponent(0.7)
        hintBackground.strokeColor = .clear
        hintBackground.zPosition = 5
        hintBackground.alpha = 0 // Initially hidden
        addChild(hintBackground)
        
        hintLabel = SKLabelNode(fontNamed: "Helvetica")
        hintLabel.text = currentQuestion?.hint ?? "Hint will appear here"
        hintLabel.fontSize = 18
        hintLabel.fontColor = .white
        hintLabel.position = CGPoint(x: 0, y: -8)
        hintLabel.zPosition = 6
        hintBackground.addChild(hintLabel)
        
        // Store reference to hint background
        hintBackground.name = "hintBackground"
    }
    
    private func setupKeyboard() {
        let keyboardWidth: CGFloat = 300
        let buttonSize: CGFloat = 70
        let spacing: CGFloat = 10
        let keyboardY = 150
        
        // Create keyboard background
        let keyboardBackground = SKShapeNode(rectOf: CGSize(width: keyboardWidth + 40, height: 320), cornerRadius: 16)
        keyboardBackground.position = CGPoint(x: size.width/2, y: CGFloat(keyboardY))
        keyboardBackground.fillColor = UIColor.black.withAlphaComponent(0.6)
        keyboardBackground.strokeColor = .clear
        keyboardBackground.zPosition = 10
        addChild(keyboardBackground)
        
        // Create number buttons (1-9, 0)
        let keys = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["-", "0", "DEL"]
        ]
        
        for (row, rowKeys) in keys.enumerated() {
            for (col, key) in rowKeys.enumerated() {
                let buttonX = CGFloat(col) * (buttonSize + spacing) - keyboardWidth/2 + buttonSize/2 + 15
                let buttonY = 120 - CGFloat(row) * (buttonSize + spacing)
                
                let button = createKeyboardButton(key: key, size: CGSize(width: buttonSize, height: buttonSize))
                button.position = CGPoint(x: buttonX, y: buttonY)
                keyboardBackground.addChild(button)
                keyboardButtons.append(button)
            }
        }
        
        // Create submit button
        let submitButton = SKShapeNode(rectOf: CGSize(width: keyboardWidth - 20, height: 50), cornerRadius: 10)
        submitButton.position = CGPoint(x: 0, y: -100)
        submitButton.fillColor = UIColor.gray.withAlphaComponent(0.8)
        submitButton.strokeColor = .clear
        submitButton.zPosition = 11
        submitButton.name = "submitButton"
        keyboardBackground.addChild(submitButton)
        
        let submitLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        submitLabel.text = "SUBMIT"
        submitLabel.fontSize = 20
        submitLabel.fontColor = .white
        submitLabel.position = CGPoint(x: 0, y: -7)
        submitLabel.zPosition = 12
        submitButton.addChild(submitLabel)
        
        keyboardButtons.append(submitButton)
    }
    
    private func createKeyboardButton(key: String, size: CGSize) -> SKNode {
        let button = SKShapeNode(rectOf: size, cornerRadius: 8)
        button.fillColor = UIColor.gray.withAlphaComponent(0.8)
        button.strokeColor = .clear
        button.zPosition = 11
        button.name = key
        
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = key
        label.fontSize = 24
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: -8)
        label.zPosition = 12
        button.addChild(label)
        
        return button
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            // Handle keyboard input
            if let name = node.name, keyboardButtons.contains(node) {
                handleKeyboardInput(key: name)
                break
            }
        }
    }
    
    private func handleKeyboardInput(key: String) {
        switch key {
        case "submitButton":
            submitAnswer()
        case "DEL":
            if !enteredAnswer.isEmpty {
                enteredAnswer.removeLast()
            }
        default:
            if enteredAnswer.count < 10 { // Limit answer length
                enteredAnswer.append(key)
            }
        }
        
        // Update the answer label
        userAnswerLabel.text = enteredAnswer
    }
    
    // MARK: - Game Logic
    
    func initializeWithProgress(_ progress: UserProgress) {
        self.userProgress = progress
        self.totalTickets = progress.earnedTickets
        
        // Load game content
        loadGameContent()
        
        // Set current country and landmark from progress
        if let country = countries.first(where: { $0.id == progress.currentCountryId }) {
            self.currentCountry = country
        } else {
            self.currentCountry = countries.first!
        }
        
        if let landmark = landmarks.first(where: { $0.id == progress.currentLandmarkId }) {
            self.currentLandmark = landmark
        } else {
            self.currentLandmark = landmarks.first(where: { $0.countryId == currentCountry.id })
        }
    }
    
    func initializeWithLandmark(countryId: String, landmarkId: String) {
        // Create default progress
        self.userProgress = UserProgress(
            userId: UUID().uuidString,
            currentCountryId: countryId,
            currentLandmarkId: landmarkId,
            completedLandmarks: [:],
            earnedTickets: 0,
            skillLevels: [:],
            questionHistory: [:]
        )
        
        // Load game content
        loadGameContent()
        
        // Set current country and landmark
        if let country = countries.first(where: { $0.id == countryId }) {
            self.currentCountry = country
        } else {
            self.currentCountry = countries.first!
        }
        
        if let landmark = landmarks.first(where: { $0.id == landmarkId }) {
            self.currentLandmark = landmark
        } else {
            self.currentLandmark = landmarks.first(where: { $0.countryId == currentCountry.id })
        }
    }
    
    func initializeNewGame() {
        // Load game content
        loadGameContent()
        
        // Start with first country and landmark
        self.currentCountry = countries.sorted(by: { $0.visitOrder < $1.visitOrder }).first!
        self.currentLandmark = landmarks.first(where: { $0.countryId == currentCountry.id })!
        
        // Create new progress
        self.userProgress = UserProgress(
            userId: UUID().uuidString,
            currentCountryId: currentCountry.id,
            currentLandmarkId: currentLandmark.id,
            completedLandmarks: [:],
            earnedTickets: 0,
            skillLevels: [:],
            questionHistory: [:]
        )
    }
    
    private func loadGameContent() {
        // In a real app, this would load from JSON or a database
        // Loading countries with emoji flags
        countries = [
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
        
        // Load landmarks based on the folder structure
        landmarks = [
            // France landmarks
            Landmark(id: "eiffel-tower", displayName: "Eiffel Tower", imageName: "eiffel-tower.png", 
                    countryId: "france", 
                    funFact: "The Eiffel Tower was built for the 1889 World's Fair and was initially criticized by many French artists."),
            Landmark(id: "louvre-museum", displayName: "Louvre Museum", imageName: "louvre-museum.png", 
                    countryId: "france", 
                    funFact: "The Louvre is the world's largest art museum and houses the Mona Lisa."),
            Landmark(id: "mont-saint-michel", displayName: "Mont Saint-Michel", imageName: "mont-saint-michel.png", 
                    countryId: "france", 
                    funFact: "Mont Saint-Michel is a tidal island that becomes completely surrounded by water during high tides."),
            Landmark(id: "notre-dame", displayName: "Notre-Dame Cathedral", imageName: "notre-dame.png", 
                    countryId: "france", 
                    funFact: "Notre-Dame's iconic rose windows contain much of the original 13th-century glass."),
            Landmark(id: "palace-of-versailles", displayName: "Palace of Versailles", imageName: "palace-of-versailles.png", 
                    countryId: "france", 
                    funFact: "The Palace of Versailles has 700 rooms, 2,000 windows, and 67 staircases."),
            
            // Spain landmarks
            Landmark(id: "alhambra", displayName: "Alhambra", imageName: "alhambra.png", 
                    countryId: "spain", 
                    funFact: "The Alhambra's name comes from Arabic meaning 'red castle' due to its reddish walls."),
            Landmark(id: "park-gell", displayName: "Park Güell", imageName: "park-gell.png", 
                    countryId: "spain", 
                    funFact: "Park Güell was designed by architect Antoni Gaudí and features his unique mosaic work."),
            Landmark(id: "plaza-mayor", displayName: "Plaza Mayor", imageName: "plaza-mayor.png", 
                    countryId: "spain", 
                    funFact: "Plaza Mayor in Madrid has hosted bullfights, markets, and even public executions in its history."),
            Landmark(id: "sagrada-familia", displayName: "Sagrada Familia", imageName: "sagrada-familia.png", 
                    countryId: "spain", 
                    funFact: "The Sagrada Familia has been under construction since 1882 and is expected to be completed in 2026."),
            Landmark(id: "seville-cathedral", displayName: "Seville Cathedral", imageName: "seville-cathedral.png", 
                    countryId: "spain", 
                    funFact: "Seville Cathedral is the largest Gothic cathedral in the world and contains Columbus's tomb."),
            
            // USA landmarks
            Landmark(id: "golden-gate-bridge", displayName: "Golden Gate Bridge", imageName: "golden-gate-bridge.png", 
                    countryId: "usa", 
                    funFact: "The Golden Gate Bridge's distinctive color is called 'International Orange' and was chosen for visibility in fog."),
            Landmark(id: "grand-canyon", displayName: "Grand Canyon", imageName: "grand-canyon.png", 
                    countryId: "usa", 
                    funFact: "The Grand Canyon is 277 miles long, up to 18 miles wide, and over a mile deep."),
            Landmark(id: "statue-of-liberty", displayName: "Statue of Liberty", imageName: "statue-of-liberty.png", 
                    countryId: "usa", 
                    funFact: "The Statue of Liberty was a gift from France to the United States in 1886."),
            Landmark(id: "times-square", displayName: "Times Square", imageName: "times-square.png", 
                    countryId: "usa", 
                    funFact: "Times Square is named after The New York Times, which moved its headquarters there in 1904."),
            Landmark(id: "yellowstone-national-park", displayName: "Yellowstone National Park", imageName: "yellowstone-national-park.png", 
                    countryId: "usa", 
                    funFact: "Yellowstone was the world's first national park, established in 1872."),
            
            // China landmarks
            Landmark(id: "great-wall", displayName: "Great Wall of China", imageName: "great-wall.png", 
                    countryId: "china", 
                    funFact: "The Great Wall of China stretches over 13,000 miles and took over 2,000 years to build.")
        ]
        
        // Generate initial questions
        questions = questionGenerator.generateInitialQuestionSet()
    }
    
    func generateQuestion() {
        // First check for review questions
        if let reviewQuestion = spacedRepetition.getNextQuestionForReview(
            from: questions, 
            userHistory: userProgress.questionHistory
        ) {
            currentQuestion = reviewQuestion
        } else {
            // Generate a new question based on user's skill level
            let mathTypes = getMathTypesForUser()
            let difficulty = getDifficultyLevelForUser()
            
            if let newQuestion = questionGenerator.generateQuestion(
                mathTypes: mathTypes,
                difficulty: difficulty
            ) {
                currentQuestion = newQuestion
            } else {
                // Fallback to random question
                currentQuestion = questions.randomElement()
            }
        }
    }
    
    func getMathTypesForUser() -> [MathType] {
        // Based on user's skill levels
        var types: [MathType] = []
        
        for (mathType, level) in userProgress.skillLevels {
            if level > 0 {
                types.append(mathType)
            }
        }
        
        // Default to basic types if none available
        if types.isEmpty {
            types = [.addition, .subtraction]
        }
        
        return types
    }
    
    private func getDifficultyLevelForUser() -> Int {
        // Get appropriate difficulty based on user's current performance
        // This is a simplified version - you can make this more sophisticated
        if let mathType = currentQuestion?.mathType {
            return userProgress.skillLevels[mathType] ?? 1
        }
        return 1
    }
    
    public func submitAnswer() {
        guard !enteredAnswer.isEmpty else { return }
        
        let isCorrect = enteredAnswer == currentQuestion.correctAnswer
        
        // Update question history
        updateQuestionHistory(questionId: currentQuestion.id, isCorrect: isCorrect)
        
        if isCorrect {
            handleCorrectAnswer()
        } else {
            handleIncorrectAnswer()
        }
        
        // Clear the answer field
        enteredAnswer = ""
        userAnswerLabel.text = ""
    }
    
    public func handleCorrectAnswer() {
        // Increase score
        currentScore = min(5, currentScore + 1)
        updateScoreDisplay()
        
        // Award tickets
        totalTickets += 1
        userProgress.earnedTickets = totalTickets
        ticketsLabel.text = "\(totalTickets)"
        
        // Save progress
        saveProgress()
        
        // Show transition to next landmark
        if let gameViewController = gameViewController {
            gameViewController.presentLandmarkTransition(landmark: currentLandmark) {
                // This is called when the transition is complete
                self.moveToNextLandmark()
            }
        }
    }
    
    public func handleIncorrectAnswer() {
        // Show hint
        showHint()
        
        // Add to spaced repetition for review
        spacedRepetition.scheduleForReview(questionId: currentQuestion.id)
    }
    
    private func showHint() {
        showingHint = true
        
        if let hintBackground = childNode(withName: "//hintBackground") {
            // Fade in the hint
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            hintBackground.run(fadeIn)
        }
    }
    
    private func hideHint() {
        showingHint = false
        
        if let hintBackground = childNode(withName: "//hintBackground") {
            // Fade out the hint
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            hintBackground.run(fadeOut)
        }
    }
    
    func moveToNextLandmark() {
        // Save completion data
        let completionData = UserProgress.CompletionData(
            completionDate: Date(),
            score: currentScore
        )
        userProgress.completedLandmarks[currentLandmark.id] = completionData
        
        // Find next landmark
        if let nextLandmark = getNextLandmark() {
            currentLandmark = nextLandmark
            
            // Update country if needed
            if nextLandmark.countryId != currentCountry.id {
                if let country = countries.first(where: { $0.id == nextLandmark.countryId }) {
                    currentCountry = country
                }
            }
            
            // Reset score for new landmark
            currentScore = 0
            
            // Update user progress
            userProgress.currentCountryId = currentCountry.id
            userProgress.currentLandmarkId = currentLandmark.id
            
            // Generate new question
            generateQuestion()
            
            // Save progress
            saveProgress()
            
            // Reload the scene to update all visuals
            if let gameViewController = gameViewController {
                gameViewController.presentGameScene()
            }
        } else {
            // Game completed - show main menu or completion screen
            if let gameViewController = gameViewController {
                gameViewController.presentMainMenu()
            }
        }
    }
    
    func getNextLandmark() -> Landmark? {
        // Check if there are more landmarks in the current country
        let countryLandmarks = landmarks.filter { $0.countryId == currentCountry.id }
        if let currentIndex = countryLandmarks.firstIndex(where: { $0.id == currentLandmark.id }) {
            if currentIndex + 1 < countryLandmarks.count {
                return countryLandmarks[currentIndex + 1]
            }
        }
        
        // If not, move to the next country
        let sortedCountries = countries.sorted(by: { $0.visitOrder < $1.visitOrder })
        if let currentCountryIndex = sortedCountries.firstIndex(where: { $0.id == currentCountry.id }) {
            if currentCountryIndex + 1 < sortedCountries.count {
                let nextCountry = sortedCountries[currentCountryIndex + 1]
                return landmarks.first(where: { $0.countryId == nextCountry.id })
            }
        }
        
        // If we've gone through all countries, return nil
        return nil
    }
    
    public func updateQuestionHistory(questionId: String, isCorrect: Bool) {
        var questionData = userProgress.questionHistory[questionId] ?? UserProgress.QuestionData(
            lastAnswered: nil,
            timesAnswered: 0,
            timesCorrect: 0,
            lastAnsweredCorrectly: nil
        )
        
        questionData.lastAnswered = Date()
        questionData.timesAnswered += 1
        
        if isCorrect {
            questionData.timesCorrect += 1
        }
        
        questionData.lastAnsweredCorrectly = isCorrect
        userProgress.questionHistory[questionId] = questionData
    }
    
    func saveProgress() {
        dataService.saveUserProgress(userProgress)
    }
    
    private func updateUI() {
        // Update country and landmark info
        countryNameLabel.text = currentCountry.name
        landmarkNameLabel.text = currentLandmark.displayName
        
        // Update flag emoji
        if let flagLabel = countryFlagLabel {
            flagLabel.text = currentCountry.flagEmoji
        }
        
        // Update background image - use the proper path based on country folder
        if let bgNode = backgroundNode {
            let imagePath = "\(currentLandmark.countryId)/\(currentLandmark.imageName)"
            bgNode.texture = SKTexture(imageNamed: imagePath)
        }
        
        // Update question
        questionLabel.text = currentQuestion.questionText
        
        // Update hint
        hintLabel.text = currentQuestion.hint
        
        // Update score display
        updateScoreDisplay()
        
        // Update tickets count
        ticketsLabel.text = "\(totalTickets)"
    }
    
    private func updateScoreDisplay() {
        // Update the star display based on current score
        for i in 0..<scoreNodes.count {
            let imageName = i < currentScore ? "star_filled" : "star_empty"
            scoreNodes[i].texture = SKTexture(imageNamed: imageName)
        }
    }
}
