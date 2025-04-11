import SwiftUI

struct ContentView: View {
    @State private var levelManager: LevelManager
    @State private var minigameCompleted: String? = nil
    @State private var debugMessage: String = ""
    
    init() {
        _levelManager = State(initialValue: LevelManager(chapters: []))
        let chapters = createGameLevels()
        _levelManager = State(initialValue: LevelManager(chapters: chapters))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // The content area using state-driven transitions
                CarouselContentView(
                    levelManager: levelManager,
                    geometry: geometry
                )
                .zIndex(1)
                
                // Debug overlay
                debugOverlay
                    .zIndex(10)
            }
            .onChange(of: levelManager.updateCounter) { _, _ in
                // This will be triggered whenever the levels change
                print("Update counter changed to: \(levelManager.updateCounter)")
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
                        levelManager.completeCurrentLevel()
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
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
                })
                .padding(20)
                .background(Color.white)
            ),
            transition: .cameraPan, // Use cameraPan for all transitions for consistency
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
                .padding(20)
                .background(Color.white)
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

// Enhanced carousel component showing adjacent views
struct CarouselContentView: View {
    @ObservedObject var levelManager: LevelManager
    let geometry: GeometryProxy
    
    private var activeWidth: CGFloat {
        geometry.size.width * 0.85 // Main view takes 85% of screen width
    }
    
    private var previewWidth: CGFloat {
        geometry.size.width * 0.1 // Preview takes 10% of screen width
    }
    
    private var getAdjacentLevels: (previous: Level?, next: Level?) {
        // Get previous level if it exists
        let previous: Level?
        if levelManager.currentLevelIndex > 0 {
            previous = levelManager.currentChapter.levels[levelManager.currentLevelIndex - 1]
        } else if levelManager.currentChapterIndex > 0 {
            let prevChapter = levelManager.chapters[levelManager.currentChapterIndex - 1]
            previous = prevChapter.levels.last
        } else {
            previous = nil
        }
        
        // Get next level if it exists
        let next: Level?
        if levelManager.currentLevelIndex < levelManager.currentChapter.levels.count - 1 {
            next = levelManager.currentChapter.levels[levelManager.currentLevelIndex + 1]
        } else if levelManager.currentChapterIndex < levelManager.chapters.count - 1 {
            let nextChapter = levelManager.chapters[levelManager.currentChapterIndex + 1]
            next = nextChapter.levels.first
        } else {
            next = nil
        }
        
        return (previous, next)
    }
    
    var body: some View {
        ZStack {
            // Background for visibility
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            
            HStack(spacing: 0) {
                let adjacentLevels = getAdjacentLevels
                
                // Previous view preview (if exists)
                if let previousLevel = adjacentLevels.previous {
                    previousLevel.content
                        .frame(width: previewWidth, height: geometry.size.height * 0.7)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.trailing, 5)
                        .offset(x: -5)
                        .opacity(0.7)
                }
                
                // Current view (active)
                levelManager.currentLevel.content
                    .frame(width: activeWidth, height: geometry.size.height)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .id("level-\(levelManager.currentChapterIndex)-\(levelManager.currentLevelIndex)")
                    .transition(
                        AnyTransition.fromLevelTransition(
                            levelManager.currentLevel.transition,
                            direction: levelManager.transitionDirection
                        )
                    )
                    .animation(
                        .spring(response: 0.7, dampingFraction: 0.8), 
                        value: levelManager.currentLevelIndex
                    )
                
                // Next view preview (if exists)
                if let nextLevel = adjacentLevels.next {
                    nextLevel.content
                        .frame(width: previewWidth, height: geometry.size.height * 0.7)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.leading, 5)
                        .offset(x: 5)
                        .opacity(0.7)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
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
