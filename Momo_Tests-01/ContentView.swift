import SwiftUI

struct ContentView: View {
    @State private var levelManager: LevelManager
    @State private var minigameCompleted: String? = nil
    @State private var debugMessage: String = ""
    
    // Force view updates when transitions change
    @State private var forceRefresh: Bool = false 
    
    init() {
        _levelManager = State(initialValue: LevelManager(chapters: []))
        let chapters = createGameLevels()
        _levelManager = State(initialValue: LevelManager(chapters: chapters))
    }
    
    var body: some View {
        ZStack {
            // Display the current level content
            levelManager.currentLevel.content
                .edgesIgnoringSafeArea(.all)
            
            // Always render the transition overlay but control its visibility
            transitionOverlay
            
            // Debug overlay in top corner - can be removed in production
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Debug: \(debugMessage)")
                            .font(.caption)
                        Text("Transitioning: \(levelManager.isTransitioning ? "YES" : "NO")")
                            .font(.caption)
                        Text("Type: \(levelManager.transitionType?.debugDescription ?? "none")")
                            .font(.caption)
                        Text("Update counter: \(levelManager.updateCounter)")
                            .font(.caption)
                        
                        // Add buttons to test transitions directly
                        HStack {
                            Button("Test Fade") {
                                print("Fade button pressed")
                                levelManager.debugTriggerTransition(.fade)
                                forceRefresh.toggle() // Force view update
                            }
                            .padding(4)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            
                            Button("Test Pan") {
                                print("Pan button pressed")
                                levelManager.debugTriggerTransition(.cameraPan)
                                forceRefresh.toggle() // Force view update
                            }
                            .padding(4)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            
                            Button("Force Refresh") {
                                forceRefresh.toggle() // Force view update
                            }
                            .padding(4)
                            .background(Color.orange)
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
            // Force refresh when the levelManager indicates it's needed
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
                    
                    // Immediately mark as nil to avoid repeated triggers
                    minigameCompleted = nil
                    
                    // Small delay to ensure UI updates properly
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        levelManager.completeCurrentLevel()
                        forceRefresh.toggle() // Force refresh
                    }
                }
            }
        }
    }
    
    private var transitionOverlay: some View {
        ZStack {
            // Only show one transition at a time based on the current transition type
            if let type = levelManager.transitionType {
                switch type {
                case .fade:
                    FadeTransition(isActive: levelManager.isTransitioning)
                        .zIndex(100)
                case .cameraPan:
                    CameraPanTransition(isActive: levelManager.isTransitioning, direction: .trailing)
                        .zIndex(100)
                }
            }
        }
        .zIndex(levelManager.isTransitioning ? 150 : 0)  // Only bring to front when active
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
