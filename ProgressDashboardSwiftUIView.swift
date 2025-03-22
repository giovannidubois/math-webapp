import SwiftUI

// Simple Progress Dashboard View
struct ProgressDashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProgressViewModel()
    
    var body: some View {
        NavigationView {
            ProgressDashboardContent(
                viewModel: viewModel,
                onBackToMainMenu: { appState.returnToMainMenu() }
            )
            .navigationTitle("Your Progress")
            .onAppear {
                viewModel.loadUserProgress()
            }
        }
    }
}

// Separated content to reduce complexity
struct ProgressDashboardContent: View {
    @ObservedObject var viewModel: ProgressViewModel
    var onBackToMainMenu: () -> Void
    
    var body: some View {
        List {
            // Top stats
            ProgressStatsSection(
                countriesVisited: viewModel.countriesVisited,
                totalCountries: viewModel.totalCountries,
                landmarksVisited: viewModel.landmarksVisited,
                totalLandmarks: viewModel.totalLandmarks,
                totalTickets: viewModel.totalTickets,
                correctAnswers: viewModel.correctAnswers
            )
            
            // Math skills breakdown
            MathSkillsSection(skills: viewModel.mathSkills)
            
           
            // Back to main menu button
            Section {
                Button("Back to Main Menu") {
                    onBackToMainMenu()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.blue)
            }
        }
    }
}

// Section for progress stats
struct ProgressStatsSection: View {
    let countriesVisited: Int
    let totalCountries: Int
    let landmarksVisited: Int
    let totalLandmarks: Int
    let totalTickets: Int
    let correctAnswers: Int
    
    var body: some View {
        Section(header: Text("Your Progress")) {
            HStack {
                ProgressStatCard(
                    title: "Countries",
                    value: "\(countriesVisited)/\(totalCountries)"
                )
                ProgressStatCard(
                    title: "Landmarks",
                    value: "\(landmarksVisited)/\(totalLandmarks)"
                )
            }
            
            HStack {
                ProgressStatCard(title: "Tickets", value: "\(totalTickets)")
                ProgressStatCard(title: "Correct Answers", value: "\(correctAnswers)")
            }
        }
    }
}

// Section for math skills
struct MathSkillsSection: View {
    let skills: [ProgressViewModel.MathSkill]
    
    var body: some View {
        Section(header: Text("Math Skills")) {
            ForEach(skills, id: \.id) { skill in
                HStack {
                    Text(skill.mathType.rawValue.capitalized)
                    Spacer()
                    SkillLevelView(level: skill.level)
                }
            }
        }
    }
}



// Helper view for progress stats
struct ProgressStatCard: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

// Helper view for skill levels
struct SkillLevelView: View {
    var level: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Rectangle()
                    .fill(i <= level ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 15, height: 10)
                    .cornerRadius(2)
            }
        }
    }
}

// ProgressViewModel
class ProgressViewModel: ObservableObject {
    @Published var countriesVisited: Int = 0
    @Published var totalCountries: Int = 0
    @Published var landmarksVisited: Int = 0
    @Published var totalLandmarks: Int = 0
    @Published var totalTickets: Int = 0
    @Published var correctAnswers: Int = 0
    @Published var mathSkills: [MathSkill] = []
    @Published var topLandmarks: [Landmark] = []
    
    private let persistenceService = DataPersistenceService()
    
    struct MathSkill: Identifiable {
        var id: String { mathType.rawValue }
        let mathType: MathType
        let level: Int
    }
    
    func loadUserProgress() {
        // Load countries and landmarks from JSON
        let countries = JSONLoader.loadCountries()
        let landmarks = JSONLoader.loadLandmarks()
        
        // Set total counts
        totalCountries = countries.count
        totalLandmarks = landmarks.count
        
        // For now, using sample data
        countriesVisited = 3
        landmarksVisited = 7
        totalTickets = 42
        correctAnswers = 57
        
        mathSkills = [
            MathSkill(mathType: .addition, level: 5),
            MathSkill(mathType: .subtraction, level: 4),
            MathSkill(mathType: .multiplication, level: 3),
            MathSkill(mathType: .division, level: 2),
            MathSkill(mathType: .fractions, level: 1)
        ]
        
        topLandmarks = [
            Landmark(id: "eiffel_tower", displayName: "Eiffel Tower", imageName: "eiffel_tower", countryId: "france", countryName: "France", countryFlagEmoji: "🇫🇷", funFact: ""),
            Landmark(id: "colosseum", displayName: "Colosseum", imageName: "colosseum", countryId: "italy", countryName: "Italy", countryFlagEmoji: "🇮🇹", funFact: ""),
            Landmark(id: "pyramids", displayName: "Pyramids of Giza", imageName: "pyramids", countryId: "egypt", countryName: "Egypt", countryFlagEmoji: "🇪🇬", funFact: "")
        ]
    }
}
