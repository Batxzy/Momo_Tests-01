import SwiftUI

struct ContentView: View {
    @State private var levelManager: LevelManager
    @State private var minigameCompleted: String? = nil
    @State private var debugMessage: String = ""
    @State private var forceRefresh: Bool = false
    
    // States for handling view transitions
    @State private var isTransitioning: Bool = false
    @State private var transitionId = UUID()
    
    init() {
        _levelManager = State(initialValue: LevelManager(chapters: []))
        let chapters = createGameLevels()
        _levelManager = State(initialValue: LevelManager(chapters: chapters))
    }
    
    var body: some View {
        ZStack {
            // Current level content - always present but conditionally visible
            currentLevelView
                .zIndex(1)
            
            // Debug overlay
            debugOverlay
                .zIndex(10) // Always on top
        }
        .onChange(of: levelManager.updateCounter) { _, _ in
            forceRefresh.toggle()
        }
        .onChange(of: levelManager.isTransitioning) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                isTransitioning = newValue
            }
            
            // Force SwiftUI to rerender the transition by changing its ID
            if newValue {
                transitionId = UUID()
            }
        }
        .onChange(of: minigameCompleted) { _, newValue in
            if let completedId = newValue {
                debugMessage = "Checking: \(completedId)"
                
                let isWinConditionMet = levelManager.checkWinCondition(minigameCompleted: completedId)
                debugMessage += " | Win: \(isWinConditionMet)"
                
                if isWinConditionMet {
                    debugMessage += " | Completing level"
                    print("⭐ COMPLETING LEVEL FOR \(completedId)")
                    
                    minigameCompleted = nil
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        levelManager.completeCurrentLevel()
                    }
                }
            }
        }
    }
    
    private var currentLevelView: some View {
        levelManager.currentLevel.content
            .id("\(levelManager.currentChapterIndex)-\(levelManager.currentLevelIndex)")
            .transition(
                AnyTransition.fromLevelTransition(
                    levelManager.currentLevel.transition
                )
            )
            .animation(.easeInOut(duration: 0.6), value: levelManager.currentLevelIndex)
            .animation(.easeInOut(duration: 0.8), value: levelManager.currentChapterIndex)
    }
    
    private var debugOverlay: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Debug: \(debugMessage)")
                        .font(.caption)
                    Text("Transitioning: \(levelManager.isTransitioning ? "YES" : "NO")")
                        .font(.caption)
                    Text("Type: \(levelManager.currentLevel.transition.debugDescription)")
                        .font(.caption)
                    Text("Level: \(levelManager.currentLevelIndex)")
                        .font(.caption)
                    
                    // Add buttons to test transitions directly
                    HStack {
                        Button("Test Fade") {
                            print("Fade button pressed")
                            levelManager.debugTriggerTransition(.fade)
                        }
                        .padding(4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                        
                        Button("Test Pan") {
                            print("Pan button pressed")
                            levelManager.debugTriggerTransition(.cameraPan)
                        }
                        .padding(4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(8)
                Spacer()
            }
            Spacer()
        }
        .padding(.top, 40)
    }
    
    // Create the game levels - static function to avoid 'self' reference
    private func createGameLevels() -> [Chapter] {
        let circlesLevel = Level(
            id: UUID(),
            name: "Circle Tapping Game",
            content: AnyView(
                CirclesView(onGameComplete: {
                    debugMessage = "Circles completed!"
                    print("⭐ CIRCLES GAME COMPLETED!")
                    minigameCompleted = "circles"
                    forceRefresh.toggle() // Force refresh
                })
            ),
            transition: .fade,
            winCondition: .completeMinigame("circles")
        )
        
        let dustRemoverLevel = Level(
            id: UUID(),
            name: "Dust Removal Game",
            content: AnyView(
                DustRemoverView2(
                    backgroundImage: Image("rectangle33"),
                    foregroundImage: Image("rectangle35"),
                    completionThreshold: 80,
                    onThresholdReached: {
                        debugMessage = "Dust threshold reached!"
                        print("⭐ DUST REMOVAL THRESHOLD REACHED!")
                        minigameCompleted = "dust"
                        forceRefresh.toggle() // Force refresh
                    }
                )
            ),
            transition: .cameraPan,
            winCondition: .completeMinigame("dust")
        )
        
        let chapter1 = Chapter(
            id: UUID(),
            title: "Chapter 1",
            levels: [dustRemoverLevel, circlesLevel],
            isUnlocked: true
        )
        
        return [chapter1]
    }
}

// Helper extension for LevelTransition debugging
extension LevelTransition {
    var debugDescription: String {
        switch self {
        case .fade: return "fade"
        case .cameraPan: return "cameraPan"
        }
    }
}
