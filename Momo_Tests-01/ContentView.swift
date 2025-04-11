import SwiftUI

struct ContentView: View {
    @State private var levelManager: LevelManager
    @State private var minigameCompleted: String? = nil
    @State private var debugMessage: String = ""
    @State private var forceRefresh: Bool = false
    
    init() {
        _levelManager = State(initialValue: LevelManager(chapters: []))
        let chapters = createGameLevels()
        _levelManager = State(initialValue: LevelManager(chapters: chapters))
    }
    
    var body: some View {
        ZStack {
            // Show previous level content during transition if available
            if levelManager.isTransitioning && levelManager.showPreviousView, 
               let previousContent = levelManager.previousLevelContent {
                previousContent
                    .edgesIgnoringSafeArea(.all)
            }
            // Otherwise show current level content
            else {
                levelManager.currentLevel.content
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Apply transition overlay
            if levelManager.isTransitioning {
                transitionOverlay
            }
            
            // Debug overlay
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Debug: \(debugMessage)")
                            .font(.caption)
                        Text("Transitioning: \(levelManager.isTransitioning ? "YES" : "NO")")
                            .font(.caption)
                        Text("Type: \(levelManager.transitionType?.debugDescription ?? "none")")
                            .font(.caption)
                        Text("Level: \(levelManager.currentLevelIndex)")
                            .font(.caption)
                        
                        // Add buttons to test transitions directly
                        HStack {
                            Button("Test Fade") {
                                print("Fade button pressed")
                                levelManager.debugTriggerTransition(.fade)
                                forceRefresh.toggle()
                            }
                            .padding(4)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            
                            Button("Test Pan") {
                                print("Pan button pressed")
                                levelManager.debugTriggerTransition(.cameraPan)
                                forceRefresh.toggle()
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
            .zIndex(200) // Keep debug controls on top
        }
        .id(forceRefresh) // Force full refresh when this changes
        .onChange(of: levelManager.updateCounter) { _, _ in
            forceRefresh.toggle()
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
                        forceRefresh.toggle()
                    }
                }
            }
        }
    }
    
    // A single transition overlay that adapts to the current transition type
    private var transitionOverlay: some View {
        Group {
            if let type = levelManager.transitionType {
                switch type {
                case .fade:
                    Color.black
                        .opacity(levelManager.showPreviousView ? 0 : 1.0) // Fade in
                        .animation(.easeInOut(duration: 0.75), value: levelManager.showPreviousView)
                        .zIndex(100)
                case .cameraPan:
                    Color.black
                        .opacity(levelManager.showPreviousView ? 0 : 1.0) // Fade in
                        .animation(.easeInOut(duration: 0.75), value: levelManager.showPreviousView)
                        .zIndex(100)
                }
            }
        }
        .ignoresSafeArea()
    }
    
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

#Preview {
    ContentView()
}
