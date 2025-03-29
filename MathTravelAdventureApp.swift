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
                SpriteGameView()
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
