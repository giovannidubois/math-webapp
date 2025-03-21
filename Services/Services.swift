import Foundation
import SpriteKit

// MARK: - Data Persistence Service
class DataPersistenceService {
    private let userDefaultsKey = "com.mathtraveladventure.userProgress"
    private let settingsDefaultsKey = "com.mathtraveladventure.gameSettings"
    
    // MARK: User Progress
    
    func saveUserProgress(_ progress: UserProgress) {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func loadUserProgress() -> UserProgress? {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedProgress = try? JSONDecoder().decode(UserProgress.self, from: savedData) {
            return decodedProgress
        }
        return nil
    }
    
    // MARK: Game Settings
    
    func saveGameSettings(_ settings: GameSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsDefaultsKey)
        }
    }
    
    func loadGameSettings() -> GameSettings? {
        if let savedData = UserDefaults.standard.data(forKey: settingsDefaultsKey),
           let decodedSettings = try? JSONDecoder().decode(GameSettings.self, from: savedData) {
            return decodedSettings
        }
        return nil
    }
}

// MARK: - Question Generator Service
class QuestionGeneratorService {
    // Generate an initial set of questions across different types and difficulties
    func generateInitialQuestionSet() -> [MathQuestion] {
        var questions: [MathQuestion] = []
        
        // Generate a variety of questions for each math type and difficulty level
        for mathType in [MathType.addition, .subtraction, .multiplication, .division, .fractions] {
            for difficulty in 1...5 {
                // Generate multiple questions per difficulty/type combination
                for _ in 1...5 {
                    if let question = generateQuestion(mathTypes: [mathType], difficulty: difficulty) {
                        questions.append(question)
                    }
                }
            }
        }
        
        return questions
    }
    
    // Generate a random question of specified types and difficulty
    func generateQuestion(mathTypes: [MathType], difficulty: Int) -> MathQuestion? {
        guard !mathTypes.isEmpty, difficulty >= 1 && difficulty <= 5 else { return nil }
        
        // Randomly select a math type from the provided options
        guard let mathType = mathTypes.randomElement() else { return nil }
        
        // Generate question based on type and difficulty
        switch mathType {
        case .addition:
            return generateAdditionQuestion(difficulty: difficulty)
        case .subtraction:
            return generateSubtractionQuestion(difficulty: difficulty)
        case .multiplication:
            return generateMultiplicationQuestion(difficulty: difficulty)
        case .division:
            return generateDivisionQuestion(difficulty: difficulty)
        case .fractions:
            return generateFractionQuestion(difficulty: difficulty)
        default:
            // Placeholder for other math types
            return generateAdditionQuestion(difficulty: difficulty)
        }
    }
    
    // MARK: - Question Generation Helpers
    
    private func generateAdditionQuestion(difficulty: Int) -> MathQuestion {
        let maxNumber: Int
        
        switch difficulty {
        case 1:
            maxNumber = 10
        case 2:
            maxNumber = 20
        case 3:
            maxNumber = 50
        case 4:
            maxNumber = 100
        case 5:
            maxNumber = 1000
        default:
            maxNumber = 10
        }
        
        let a = Int.random(in: 1...maxNumber)
        let b = Int.random(in: 1...maxNumber)
        let answer = a + b
        
        return MathQuestion(
            id: UUID().uuidString,
            questionText: "\(a) + \(b) = ?",
            correctAnswer: "\(answer)",
            hint: "Add \(a) and \(b) together.",
            difficulty: difficulty,
            mathType: .addition
        )
    }
    
    private func generateSubtractionQuestion(difficulty: Int) -> MathQuestion {
        let maxNumber: Int
        
        switch difficulty {
        case 1:
            maxNumber = 10
        case 2:
            maxNumber = 20
        case 3:
            maxNumber = 50
        case 4:
            maxNumber = 100
        case 5:
            maxNumber = 1000
        default:
            maxNumber = 10
        }
        
        // Make sure result is positive
        let b = Int.random(in: 1...maxNumber)
        let a = Int.random(in: b...maxNumber + b)
        let answer = a - b
        
        return MathQuestion(
            id: UUID().uuidString,
            questionText: "\(a) - \(b) = ?",
            correctAnswer: "\(answer)",
            hint: "Subtract \(b) from \(a).",
            difficulty: difficulty,
            mathType: .subtraction
        )
    }
    
    private func generateMultiplicationQuestion(difficulty: Int) -> MathQuestion {
        let maxNumber: Int
        
        switch difficulty {
        case 1:
            maxNumber = 5
        case 2:
            maxNumber = 10
        case 3:
            maxNumber = 12
        case 4:
            maxNumber = 15
        case 5:
            maxNumber = 20
        default:
            maxNumber = 5
        }
        
        let a = Int.random(in: 1...maxNumber)
        let b = Int.random(in: 1...maxNumber)
        let answer = a * b
        
        return MathQuestion(
            id: UUID().uuidString,
            questionText: "\(a) × \(b) = ?",
            correctAnswer: "\(answer)",
            hint: "Multiply \(a) by \(b).",
            difficulty: difficulty,
            mathType: .multiplication
        )
    }
    
    private func generateDivisionQuestion(difficulty: Int) -> MathQuestion {
        let maxNumber: Int
        
        switch difficulty {
        case 1:
            maxNumber = 5
        case 2:
            maxNumber = 10
        case 3:
            maxNumber = 12
        case 4:
            maxNumber = 15
        case 5:
            maxNumber = 20
        default:
            maxNumber = 5
        }
        
        // Create division with no remainder for simplicity
        let b = Int.random(in: 1...maxNumber)
        let answer = Int.random(in: 1...maxNumber)
        let a = b * answer
        
        return MathQuestion(
            id: UUID().uuidString,
            questionText: "\(a) ÷ \(b) = ?",
            correctAnswer: "\(answer)",
            hint: "Divide \(a) by \(b).",
            difficulty: difficulty,
            mathType: .division
        )
    }
    
    private func generateFractionQuestion(difficulty: Int) -> MathQuestion {
        // Simplified fraction question for demonstration
        // In a real app, would have more complex fraction problems at higher difficulties
        
        let denominators = [2, 4, 5, 10]
        let denominator = denominators.randomElement() ?? 2
        let numerator = Int.random(in: 1..<denominator)
        
        return MathQuestion(
            id: UUID().uuidString,
            questionText: "What is \(numerator)/\(denominator) as a decimal?",
            correctAnswer: String(format: "%.2f", Double(numerator) / Double(denominator)),
            hint: "Divide \(numerator) by \(denominator).",
            difficulty: difficulty,
            mathType: .fractions
        )
    }
}

// MARK: - Spaced Repetition Service
class SpacedRepetitionService {
    // Queue of questions to review
    private var reviewQueue: [String] = []
    
    // Schedule a question for review
    func scheduleForReview(questionId: String) {
        // If already in queue, don't add again
        if !reviewQueue.contains(questionId) {
            reviewQueue.append(questionId)
        }
    }
    
    // Get the next question that needs review
    func getNextQuestionForReview(
        from questions: [MathQuestion],
        userHistory: [String: UserProgress.QuestionData]
    ) -> MathQuestion? {
        guard !reviewQueue.isEmpty else { return nil }
        
        // Get the ID of the next question to review
        let nextId = reviewQueue.removeFirst()
        
        // Find the question in the question list
        return questions.first { $0.id == nextId }
    }
}
