import Foundation
import Combine

class GameViewModel: ObservableObject {
    // Published properties for UI updates
    @Published var currentCountry: Country
    @Published var currentLandmark: Landmark
    @Published var currentQuestion: MathQuestion
    @Published var currentScore: Int = 0 // Current landmark score (0-5)
    @Published var totalTickets: Int = 0
    @Published var isLoading: Bool = false
    
    // Private properties
    public var countries: [Country] = []
    public var landmarks: [Landmark] = []
    public var questions: [MathQuestion] = []
    public var userProgress: UserProgress
    public var gameSettings: GameSettings
    public var questionGenerator: QuestionGeneratorService
    public var spacedRepetition: SpacedRepetitionService
    public var persistenceService: DataPersistenceService
    
    // For tracking consecutive correct/incorrect answers
    private var consecutiveCorrectAnswers: Int = 0
    private var consecutiveIncorrectAnswers: Int = 0
    
    // Initial placeholder data
    init() {
        // Default initialization with placeholder data
        self.currentCountry = Country(
            id: "placeholder",
            name: "Loading...",
            flagEmoji: "🏳️",
            landmarks: [],
            visitOrder: 0
        )
        
        self.currentLandmark = Landmark(
            id: "placeholder",
            displayName: "Loading...",
            imageName: "placeholder_image",
            countryId: "placeholder",
            funFact: "Loading fun facts..."
        )
        
        self.currentQuestion = MathQuestion(
            id: "placeholder",
            questionText: "Loading question...",
            correctAnswer: "",
            hint: "Loading hint...",
            difficulty: 1,
            mathType: .addition
        )
        
        self.userProgress = UserProgress(
            userId: UUID().uuidString,
            currentCountryId: "",
            currentLandmarkId: "",
            completedLandmarks: [:],
            earnedTickets: 0,
            skillLevels: [:],
            questionHistory: [:]
        )
        
        self.gameSettings = GameSettings()
        self.questionGenerator = QuestionGeneratorService()
        self.spacedRepetition = SpacedRepetitionService()
        self.persistenceService = DataPersistenceService()
    }
    
    // Load initial game content
    func loadInitialContent() {
        isLoading = true
        
        // Load saved game state if available
        if let savedProgress = persistenceService.loadUserProgress() {
            self.userProgress = savedProgress
            self.totalTickets = savedProgress.earnedTickets
        }
        
        // Load game settings
        if let savedSettings = persistenceService.loadGameSettings() {
            self.gameSettings = savedSettings
        }
        
        // Load content (would typically come from a JSON file or network)
        loadCountries()
        loadLandmarks()
        loadQuestions()
        
        // Set initial country and landmark based on user progress
        initializeGameState()
        
        // Generate first question
        generateQuestion()
        
        isLoading = false
    }
    
    // Check if the user's answer is correct
    func checkAnswer(_ userAnswer: String) -> Bool {
        guard !userAnswer.isEmpty else { return false }
        
        let isCorrect = userAnswer == currentQuestion.correctAnswer
        
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
    
    // Move to the next landmark after correct answer
    func moveToNextLandmark() {
        // Save current landmark completion
        saveCurrentLandmarkProgress()
        
        // Get next landmark
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
            
            // Generate new question
            generateQuestion()
        } else {
            // Handle game completion
            // This could trigger a game completion screen
            print("Game completed!")
        }
        
        // Save progress
        saveProgress()
    }
    
    // MARK: - Private Helper Methods
    
    private func loadCountries() {
        // In a real app, this would load from a JSON file or API
        // For now, using placeholder implementation
        countries = [
            Country(id: "france", name: "France", flagEmoji: "flag_france", landmarks: ["eiffel_tower", "louvre"], visitOrder: 1),
            Country(id: "italy", name: "Italy", flagEmoji: "flag_italy", landmarks: ["colosseum", "venice"], visitOrder: 2),
            // More countries would be added here
        ]
    }
    
    private func loadLandmarks() {
        // In a real app, this would load from a JSON file or API
        landmarks = [
            Landmark(
                id: "eiffel_tower",
                displayName: "Eiffel Tower",
                imageName: "eiffel_tower",
                countryId: "france",
                funFact: "The Eiffel Tower was built for the 1889 World's Fair and was initially criticized by many French artists and intellectuals."
            ),
            Landmark(
                id: "louvre",
                displayName: "Louvre Museum",
                imageName: "louvre",
                countryId: "france",
                funFact: "The Louvre is the world's largest art museum and houses the Mona Lisa."
            ),
            // More landmarks would be added here
        ]
    }
    
    private func loadQuestions() {
        // In a real app, this would load questions from a database
        // For now, we'll use the question generator service
        questions = questionGenerator.generateInitialQuestionSet()
    }
    
    private func initializeGameState() {
        // If user has progress, load it
        if !userProgress.currentCountryId.isEmpty, !userProgress.currentLandmarkId.isEmpty {
            if let country = countries.first(where: { $0.id == userProgress.currentCountryId }) {
                currentCountry = country
            } else {
                currentCountry = countries.first!
            }
            
            if let landmark = landmarks.first(where: { $0.id == userProgress.currentLandmarkId }) {
                currentLandmark = landmark
            } else {
                currentLandmark = getFirstLandmarkForCountry(currentCountry.id)
            }
        } else {
            // Start with the first country and landmark
            currentCountry = countries.sorted(by: { $0.visitOrder < $1.visitOrder }).first!
            currentLandmark = getFirstLandmarkForCountry(currentCountry.id)
            
            // Update user progress
            userProgress.currentCountryId = currentCountry.id
            userProgress.currentLandmarkId = currentLandmark.id
        }
    }
    
    private func getFirstLandmarkForCountry(_ countryId: String) -> Landmark {
        if let landmark = landmarks.first(where: { $0.countryId == countryId }) {
            return landmark
        }
        return landmarks.first!
    }
    
    private func getNextLandmark() -> Landmark? {
        // First check if there are more landmarks in the current country
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
                return getFirstLandmarkForCountry(nextCountry.id)
            }
        }
        
        // If we've gone through all countries, return nil
        return nil
    }
    
    private func generateQuestion() {
        // First, check if there are questions for review (spaced repetition)
        if let reviewQuestion = spacedRepetition.getNextQuestionForReview(
            from: questions,
            userHistory: userProgress.questionHistory
        ) {
            currentQuestion = reviewQuestion
            return
        }
        
        // If no review questions, generate a new question based on user's skill level
        let mathTypes = determineAppropriateQuestionTypes()
        let difficulty = determineAppropriateDifficulty()
        
        if let newQuestion = questionGenerator.generateQuestion(
            mathTypes: mathTypes,
            difficulty: difficulty
        ) {
            currentQuestion = newQuestion
        } else {
            // Fallback to a random question if generation fails
            currentQuestion = questions.randomElement() ?? currentQuestion
        }
    }
    
    private func determineAppropriateQuestionTypes() -> [MathType] {
        // Based on user's skill levels, determine appropriate math types
        var appropriateTypes: [MathType] = []
        
        // Add math types based on user's current skill level
        for (mathType, level) in userProgress.skillLevels {
            if level > 0 {
                appropriateTypes.append(mathType)
            }
        }
        
        // If no specific types, start with basics
        if appropriateTypes.isEmpty {
            appropriateTypes = [.addition, .subtraction]
        }
        
        return appropriateTypes
    }
    
    private func determineAppropriateDifficulty() -> Int {
        // If adaptive difficulty is disabled, return a fixed level
        if !gameSettings.adaptiveDifficulty {
            return 2 // Medium difficulty
        }
        
        // Calculate appropriate difficulty based on recent performance
        if consecutiveCorrectAnswers >= 3 {
            return min(5, (userProgress.skillLevels[currentQuestion.mathType] ?? 1) + 1)
        } else if consecutiveIncorrectAnswers >= 2 {
            return max(1, (userProgress.skillLevels[currentQuestion.mathType] ?? 1) - 1)
        }
        
        // Default to current skill level
        return userProgress.skillLevels[currentQuestion.mathType] ?? 1
    }
    
    private func handleCorrectAnswer() {
        // Update consecutive counters
        consecutiveCorrectAnswers += 1
        consecutiveIncorrectAnswers = 0
        
        // Increase score for current landmark
        currentScore = min(5, currentScore + 1)
        
        // Award tickets
        totalTickets += 1
        userProgress.earnedTickets = totalTickets
        
        // Update skill level if appropriate
        if consecutiveCorrectAnswers >= 3 {
            let currentLevel = userProgress.skillLevels[currentQuestion.mathType] ?? 1
            userProgress.skillLevels[currentQuestion.mathType] = min(5, currentLevel + 1)
        }
    }
    
    private func handleIncorrectAnswer() {
        // Update consecutive counters
        consecutiveCorrectAnswers = 0
        consecutiveIncorrectAnswers += 1
        
        // Decrease skill level if struggling consistently
        if consecutiveIncorrectAnswers >= 3 {
            let currentLevel = userProgress.skillLevels[currentQuestion.mathType] ?? 1
            userProgress.skillLevels[currentQuestion.mathType] = max(1, currentLevel - 1)
            
            // Reset counter to avoid continual decrease
            consecutiveIncorrectAnswers = 0
        }
        
        // Add question to spaced repetition for review
        spacedRepetition.scheduleForReview(questionId: currentQuestion.id)
    }
    
    private func updateQuestionHistory(questionId: String, isCorrect: Bool) {
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
    
    private func saveCurrentLandmarkProgress() {
        // Save completion data for the current landmark
        let completionData = UserProgress.CompletionData(
            completionDate: Date(),
            score: currentScore
        )
        
        userProgress.completedLandmarks[currentLandmark.id] = completionData
    }
    
    private func saveProgress() {
        // Update current position
        userProgress.currentCountryId = currentCountry.id
        userProgress.currentLandmarkId = currentLandmark.id
        
        // Save to persistence
        persistenceService.saveUserProgress(userProgress)
        persistenceService.saveGameSettings(gameSettings)
    }
}
