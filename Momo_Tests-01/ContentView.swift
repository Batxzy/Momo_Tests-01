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
        .onChange(of: minigameCompleted) { _, newValue in
            if let completedId = newValue,
               levelManager.checkWinCondition(minigameCompleted: completedId) {
                levelManager.completeCurrentLevel()
                minigameCompleted = nil
            }
        }
    }
    
    private var transitionView: some View {
        Group {
            switch levelManager.transitionType {
            case .fade:
                FadeTransition(isActive: true)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: levelManager.isTransitioning)
            case .cameraPan:
                CameraPanTransition(isActive: true, direction: .trailing)
                    .transition(.move(edge: .trailing))
                    .animation(.easeInOut(duration: 0.8), value: levelManager.isTransitioning)
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
            levels: [dustRemoverLevel,circlesLevel],
            isUnlocked: true
        )
        
        return [chapter1]
    }
}

#Preview {
    ContentView()
}
