import SwiftUI

struct ContentView: View {
    @State private var levelManager: LevelManager
    @State private var minigameCompleted: String? = nil
    
    // Add debug state to track what's happening
    @State private var debugMessage: String = ""
    
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
            
            // Transition overlay - must be always in view hierarchy for state changes to work
            Group {
                if levelManager.isTransitioning {
                    transitionOverlay
                }
            }
            
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
        .onChange(of: minigameCompleted) { old, newValue in
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
                    }
                }
            }
        }
    }
    
    private var transitionOverlay: some View {
        Group {
            switch levelManager.transitionType {
            case .fade:
                FadeTransition(isActive: true)
                    .zIndex(100) // Ensure it's above everything else
            case .cameraPan:
                CameraPanTransition(isActive: true, direction: .trailing)
                    .zIndex(100) // Ensure it's above everything else
            case .none:
                Color.clear // Empty but still in hierarchy
            }
        }
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
