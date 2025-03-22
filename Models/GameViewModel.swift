import Foundation
import Combine

class GameViewModel: ObservableObject {
    
    // Published properties for UI updates
    @Published var currentCountry: Country
    @Published var currentLandmark: Landmark
    @Published var currentQuestion: MathQuestion
    @Published var currentScore: Int = 0
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
    
    private var consecutiveCorrectAnswers: Int = 0
    private var consecutiveIncorrectAnswers: Int = 0
    
    // MARK: - Initializer
    
    init() {
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
            countryName: "Loading...",
            countryFlagEmoji: "🏳️",
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
    
    // MARK: - Initial Game Content Load
    
    func loadInitialContent() {
        isLoading = true
        
        if let savedProgress = persistenceService.loadUserProgress() {
            self.userProgress = savedProgress
            self.totalTickets = savedProgress.earnedTickets
        }
        
        if let savedSettings = persistenceService.loadGameSettings() {
            self.gameSettings = savedSettings
        }
        
        // ✅ Load from JSON files
        loadCountries()
        loadLandmarks()
        loadQuestions()
        
        initializeGameState()
        generateQuestion()
        
        isLoading = false
    }
    
    // MARK: - Check Answers
    
    func checkAnswer(_ userAnswer: String) -> Bool {
        guard !userAnswer.isEmpty else { return false }
        
        let isCorrect = userAnswer == currentQuestion.correctAnswer
        updateQuestionHistory(questionId: currentQuestion.id, isCorrect: isCorrect)
        
        if isCorrect {
            handleCorrectAnswer()
        } else {
            handleIncorrectAnswer()
        }
        
        return isCorrect
    }
    
    func moveToNextLandmark() {
        saveCurrentLandmarkProgress()
        
        if let nextLandmark = getNextLandmark() {
            currentLandmark = nextLandmark
            
            if nextLandmark.countryId != currentCountry.id,
               let newCountry = countries.first(where: { $0.id == nextLandmark.countryId }) {
                currentCountry = newCountry
            }
            
            currentScore = 0
            generateQuestion()
        } else {
            print("🎉 Game completed!")
        }
        
        saveProgress()
    }
    
    // MARK: - Private Loading Methods
    
    private func loadCountries() {
        countries = JSONLoader.loadCountries()
        
        if countries.isEmpty {
            print("❌ No countries loaded from JSON!")
        } else {
            print("✅ Loaded \(countries.count) countries from JSON.")
        }
    }
    
    private func loadLandmarks() {
        landmarks = JSONLoader.loadLandmarks()
        
        if landmarks.isEmpty {
            print("❌ No landmarks loaded from JSON!")
        } else {
            print("✅ Loaded \(landmarks.count) landmarks from JSON.")
        }
    }
    
    private func loadQuestions() {
        questions = questionGenerator.generateInitialQuestionSet()
    }
    
    // MARK: - Game State Initialization
    
    private func initializeGameState() {
        if !userProgress.currentCountryId.isEmpty,
           !userProgress.currentLandmarkId.isEmpty {
            
            if let savedCountry = countries.first(where: { $0.id == userProgress.currentCountryId }) {
                currentCountry = savedCountry
            } else {
                currentCountry = countries.first!
            }
            
            if let savedLandmark = landmarks.first(where: { $0.id == userProgress.currentLandmarkId }) {
                currentLandmark = savedLandmark
            } else {
                currentLandmark = getFirstLandmarkForCountry(currentCountry.id)
            }
        } else {
            currentCountry = countries.sorted(by: { $0.visitOrder < $1.visitOrder }).first!
            currentLandmark = getFirstLandmarkForCountry(currentCountry.id)
            
            userProgress.currentCountryId = currentCountry.id
            userProgress.currentLandmarkId = currentLandmark.id
        }
    }
    
    private func getFirstLandmarkForCountry(_ countryId: String) -> Landmark {
        return landmarks.first(where: { $0.countryId == countryId }) ?? landmarks.first!
    }
    
    private func getNextLandmark() -> Landmark? {
        let landmarksInCountry = landmarks.filter { $0.countryId == currentCountry.id }
        
        if let currentIndex = landmarksInCountry.firstIndex(where: { $0.id == currentLandmark.id }),
           currentIndex + 1 < landmarksInCountry.count {
            return landmarksInCountry[currentIndex + 1]
        }
        
        let sortedCountries = countries.sorted(by: { $0.visitOrder < $1.visitOrder })
        
        if let currentCountryIndex = sortedCountries.firstIndex(where: { $0.id == currentCountry.id }),
           currentCountryIndex + 1 < sortedCountries.count {
            let nextCountry = sortedCountries[currentCountryIndex + 1]
            return getFirstLandmarkForCountry(nextCountry.id)
        }
        
        return nil
    }
    
    // MARK: - Question Handling
    
    private func generateQuestion() {
        if let reviewQuestion = spacedRepetition.getNextQuestionForReview(
            from: questions,
            userHistory: userProgress.questionHistory
        ) {
            currentQuestion = reviewQuestion
            return
        }
        
        let mathTypes = determineAppropriateQuestionTypes()
        let difficulty = determineAppropriateDifficulty()
        
        if let newQuestion = questionGenerator.generateQuestion(
            mathTypes: mathTypes,
            difficulty: difficulty
        ) {
            currentQuestion = newQuestion
        } else {
            currentQuestion = questions.randomElement() ?? currentQuestion
        }
    }
    
    private func determineAppropriateQuestionTypes() -> [MathType] {
        let types = userProgress.skillLevels.filter { $0.value > 0 }.map { $0.key }
        return types.isEmpty ? [.addition, .subtraction] : types
    }
    
    private func determineAppropriateDifficulty() -> Int {
        if !gameSettings.adaptiveDifficulty {
            return 2
        }
        
        let currentLevel = userProgress.skillLevels[currentQuestion.mathType] ?? 1
        
        if consecutiveCorrectAnswers >= 3 {
            return min(5, currentLevel + 1)
        } else if consecutiveIncorrectAnswers >= 2 {
            return max(1, currentLevel - 1)
        }
        
        return currentLevel
    }
    
    private func handleCorrectAnswer() {
        consecutiveCorrectAnswers += 1
        consecutiveIncorrectAnswers = 0
        
        currentScore = min(5, currentScore + 1)
        
        totalTickets += 1
        userProgress.earnedTickets = totalTickets
        
        if consecutiveCorrectAnswers >= 3 {
            let currentLevel = userProgress.skillLevels[currentQuestion.mathType] ?? 1
            userProgress.skillLevels[currentQuestion.mathType] = min(5, currentLevel + 1)
        }
    }
    
    private func handleIncorrectAnswer() {
        consecutiveCorrectAnswers = 0
        consecutiveIncorrectAnswers += 1
        
        if consecutiveIncorrectAnswers >= 3 {
            let currentLevel = userProgress.skillLevels[currentQuestion.mathType] ?? 1
            userProgress.skillLevels[currentQuestion.mathType] = max(1, currentLevel - 1)
            consecutiveIncorrectAnswers = 0
        }
        
        spacedRepetition.scheduleForReview(questionId: currentQuestion.id)
    }
    
    private func updateQuestionHistory(questionId: String, isCorrect: Bool) {
        var history = userProgress.questionHistory[questionId] ?? UserProgress.QuestionData(
            lastAnswered: nil,
            timesAnswered: 0,
            timesCorrect: 0,
            lastAnsweredCorrectly: nil
        )
        
        history.lastAnswered = Date()
        history.timesAnswered += 1
        
        if isCorrect {
            history.timesCorrect += 1
        }
        
        history.lastAnsweredCorrectly = isCorrect
        userProgress.questionHistory[questionId] = history
    }
    
    private func saveCurrentLandmarkProgress() {
        let completion = UserProgress.CompletionData(
            completionDate: Date(),
            score: currentScore
        )
        
        userProgress.completedLandmarks[currentLandmark.id] = completion
    }
    
    private func saveProgress() {
        userProgress.currentCountryId = currentCountry.id
        userProgress.currentLandmarkId = currentLandmark.id
        
        persistenceService.saveUserProgress(userProgress)
        persistenceService.saveGameSettings(gameSettings)
    }
}
