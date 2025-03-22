import Foundation
import SpriteKit

// MARK: - Country Model
struct Country: Identifiable, Codable {
    let id: String
    let name: String
    let flagEmoji: String  // Using emoji flags instead of images
    var landmarks: [String] // IDs of landmarks
    
    // For sorting countries by visit order
    var visitOrder: Int
}

// MARK: - Landmark Model
struct Landmark: Identifiable, Codable {
    var id: String
    var displayName: String
    var imageName: String
    var countryId: String
    var countryName: String      // ✅ Add this!
    var countryFlagEmoji: String // ✅ Add this!
    var funFact: String
}


// MARK: - Question Model
struct MathQuestion: Identifiable, Codable {
    let id: String
    let questionText: String
    let correctAnswer: String
    let hint: String
    
    // Properties for adaptive learning
    var difficulty: Int // 1-5 scale
    var mathType: MathType
    var lastAnsweredCorrectly: Bool?
    var timesAnswered: Int = 0
    var timesAnsweredCorrectly: Int = 0
    
    // Computed property for success rate
    var successRate: Double {
        guard timesAnswered > 0 else { return 0 }
        return Double(timesAnsweredCorrectly) / Double(timesAnswered)
    }
}

// MARK: - Math Type Enum
enum MathType: String, Codable {
    case addition
    case subtraction
    case multiplication
    case division
    case fractions
    case decimals
    case percentages
    case algebra
}

// MARK: - User Progress Model
struct UserProgress: Codable {
    var userId: String
    var currentCountryId: String
    var currentLandmarkId: String
    var completedLandmarks: [String: CompletionData]
    var earnedTickets: Int
    var skillLevels: [MathType: Int] // 1-5 scale for each math type
    var questionHistory: [String: QuestionData] // Question ID to data mapping
    
    // Tracking when landmarks were completed
    struct CompletionData: Codable {
        var completionDate: Date
        var score: Int // 1-5 stars
    }
    
    // Tracking question performance
    struct QuestionData: Codable {
        var lastAnswered: Date?
        var timesAnswered: Int
        var timesCorrect: Int
        var lastAnsweredCorrectly: Bool?
    }
}

// MARK: - Game Settings Model
struct GameSettings: Codable {
    var soundEnabled: Bool = true
    var musicEnabled: Bool = true
    var hintLevel: HintLevel = .medium
    var adaptiveDifficulty: Bool = true
    
    enum HintLevel: String, Codable, CaseIterable {
        case minimal
        case medium
        case detailed
    }
}
