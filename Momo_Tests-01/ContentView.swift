import SwiftUI

struct ContentView: View {
    // Fix the initialization error by separating level creation from init
    @State private var levelManager: LevelManager
    @State private var minigameCompleted: String? = nil
    
    init() {
        // Create a temporary empty array for initialization
        _levelManager = State(initialValue: LevelManager(chapters: []))
        
        // Then set up the real levels after initialization
        let chapters = createGameLevels()
        _levelManager = State(initialValue: LevelManager(chapters: chapters))
    }
    
    var body: some View {
        ZStack {
            // Display the current level content
            levelManager.currentLevel.content
                .edgesIgnoringSafeArea(.all)
            
            // Transition overlay
            if levelManager.isTransitioning {
                transitionView
            }
        }
        .onChange(of: minigameCompleted) { old, newValue in
            print("Minigame completion changed: \(String(describing: old)) -> \(String(describing: newValue))")
            
            if let completedId = newValue {
                print("Checking win condition for: \(completedId)")
                let isWinConditionMet = levelManager.checkWinCondition(minigameCompleted: completedId)
                print("Win condition met: \(isWinConditionMet)")
                
                if isWinConditionMet {
                    print("Completing current level")
                    levelManager.completeCurrentLevel()
                    // Reset after a slight delay to ensure animations complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        minigameCompleted = nil
                    }
                }
            }
        }
    }
    
    private var transitionView: some View {
        Group {
            switch levelManager.transitionType {
            case .fade:
                FadeTransition(isActive: true)
            case .cameraPan:
                CameraPanTransition(isActive: true, direction: .trailing)
            case .none:
                EmptyView()
            }
        }
    }
    
    // Create the game levels - static function to avoid 'self' reference
    private func createGameLevels() -> [Chapter] {
        let circlesLevel = Level(
            id: UUID(),
            name: "Circle Tapping Game",
            content: AnyView(
                CirclesView(onGameComplete: {
                    print("Circles game completed!")
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
                        print("Dust removal threshold reached!")
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

#Preview {
    ContentView()
}
