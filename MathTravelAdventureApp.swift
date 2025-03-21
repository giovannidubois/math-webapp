import SwiftUI

@main
struct MathTravelAdventureApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// Central app state to manage navigation and shared data
class AppState: ObservableObject {
    @Published var currentScreen: AppScreen = .mainMenu
    @Published var isGameInProgress: Bool = false
    @Published var showingSettings: Bool = false
    @Published var showingProfile: Bool = false
    
    // Navigation actions
    func navigateTo(_ screen: AppScreen) {
        currentScreen = screen
    }
    
    func startNewGame() {
        isGameInProgress = true
        currentScreen = .game
    }
    
    func continueGame() {
        isGameInProgress = true
        currentScreen = .game
    }
    
    func returnToMainMenu() {
        currentScreen = .mainMenu
    }
}

// App screens for navigation
enum AppScreen {
    case mainMenu
    case game
    case progress
    case settings
    case profile
}

// Main ContentView that handles navigation between screens
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.teal.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // App content based on current screen
            switch appState.currentScreen {
            case .mainMenu:
                MainMenuView()
            case .game:
                GameView()
            case .progress:
                ProgressDashboardView()
            case .settings:
                SettingsView()
            case .profile:
                ProfileView()
            }
        }
        .sheet(isPresented: $appState.showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $appState.showingProfile) {
            ProfileView()
        }
    }
}

// Main menu view
struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingIntro = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // App title
            Text("Math Travel Adventure")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .shadow(radius: 2)
            
            // App subtitle
            Text("Learn math as you explore the world!")
                .font(.title2)
                .foregroundColor(.white)
                .padding(.bottom, 50)
                .shadow(radius: 1)
            
            // Action buttons
            VStack(spacing: 20) {
                MainMenuButton(title: "Start New Game", action: appState.startNewGame)
                
                MainMenuButton(title: "Continue", action: appState.continueGame)
                
                MainMenuButton(title: "Progress", action: {
                    appState.navigateTo(.progress)
                })
                
                MainMenuButton(title: "Settings", action: {
                    appState.showingSettings = true
                })
                
                MainMenuButton(title: "Profile", action: {
                    appState.showingProfile = true
                })
            }
            .padding()
            
            Spacer()
        }
        .background(
            Image("world_map_background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.3)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

// Styled button for main menu
struct MainMenuButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.7))
                        .shadow(radius: 5)
                )
        }
        .padding(.horizontal, 20)
    }
}

// Settings View
struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sound Options")) {
                    Toggle("Music", isOn: $viewModel.musicEnabled)
                    Toggle("Sound Effects", isOn: $viewModel.soundEnabled)
                }
                
                Section(header: Text("Game Options")) {
                    Toggle("Adaptive Difficulty", isOn: $viewModel.adaptiveDifficultyEnabled)
                    
                    Picker("Hint Level", selection: $viewModel.hintLevel) {
                        ForEach(GameSettings.HintLevel.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    Button("Save Settings") {
                        viewModel.saveSettings()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// Settings ViewModel
class SettingsViewModel: ObservableObject {
    @Published var musicEnabled: Bool = true
    @Published var soundEnabled: Bool = true
    @Published var adaptiveDifficultyEnabled: Bool = true
    @Published var hintLevel: GameSettings.HintLevel = .medium
    
    private let persistenceService = DataPersistenceService()
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        if let settings = persistenceService.loadGameSettings() {
            musicEnabled = settings.musicEnabled
            soundEnabled = settings.soundEnabled
            adaptiveDifficultyEnabled = settings.adaptiveDifficulty
            hintLevel = settings.hintLevel
        }
    }
    
    func saveSettings() {
        let settings = GameSettings(
            soundEnabled: soundEnabled,
            musicEnabled: musicEnabled,
            hintLevel: hintLevel,
            adaptiveDifficulty: adaptiveDifficultyEnabled
        )
        persistenceService.saveGameSettings(settings)
    }
}

// Simple Progress Dashboard View
struct ProgressDashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProgressViewModel()
    
    var body: some View {
        NavigationView {
            List {
                // Top stats
                Section(header: Text("Your Progress")) {
                    HStack {
                        ProgressStatCard(title: "Countries", value: "\(viewModel.countriesVisited)/\(viewModel.totalCountries)")
                        ProgressStatCard(title: "Landmarks", value: "\(viewModel.landmarksVisited)/\(viewModel.totalLandmarks)")
                    }
                    
                    HStack {
                        ProgressStatCard(title: "Tickets", value: "\(viewModel.totalTickets)")
                        ProgressStatCard(title: "Correct Answers", value: "\(viewModel.correctAnswers)")
                    }
                }
                
                // Math skills breakdown
                Section(header: Text("Math Skills")) {
                    ForEach(viewModel.mathSkills.sorted(by: { $0.level > $1.level }), id: \.mathType) { skill in
                        HStack {
                            Text(skill.mathType.rawValue.capitalized)
                            Spacer()
                            SkillLevelView(level: skill.level)
                        }
                    }
                }
                
                // Most visited landmarks
                Section(header: Text("Top Landmarks")) {
                    ForEach(viewModel.topLandmarks, id: \.id) { landmark in
                        HStack {
                            Text(landmark.name)
                            Spacer()
                            Text("\(landmark.visitCount) visits")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Back to main menu button
                Section {
                    Button("Back to Main Menu") {
                        appState.returnToMainMenu()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Your Progress")
            .onAppear {
                viewModel.loadUserProgress()
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
        // This would load from your data service
        // For now, using sample data
        countriesVisited = 3
        totalCountries = 40
        landmarksVisited = 7
        totalLandmarks = 120
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
            Landmark(id: "eiffel_tower", name: "Eiffel Tower", imageName: "eiffel_tower", countryId: "france", funFact: "", visitCount: 3),
            Landmark(id: "colosseum", name: "Colosseum", imageName: "colosseum", countryId: "italy", funFact: "", visitCount: 2),
            Landmark(id: "pyramids", name: "Pyramids of Giza", imageName: "pyramids", countryId: "egypt", funFact: "", visitCount: 1)
        ]
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

// Simple Profile View
struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = "Math Explorer"
    @State private var age: String = ""
    @State private var grade: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Information")) {
                    TextField("Username", text: $username)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Grade", text: $grade)
                }
                
                Section {
                    Button("Save Profile") {
                        // Save profile information
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Your Profile")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
