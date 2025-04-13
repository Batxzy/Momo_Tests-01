import SwiftUI

private struct LevelManagerKey: EnvironmentKey {
    static let defaultValue: LevelManager = LevelManager(chapters: [])
}

extension EnvironmentValues {
    var levelManager: LevelManager {
        get { self[LevelManagerKey.self] }
        set { self[LevelManagerKey.self] = newValue }
    }
}

struct GameContainer: View {
    @State private var levelManager = LevelManager(chapters: [])
    
    
    init() {
        // Define sample chapters and levels
        let sampleChapters = [
            Chapter(
                id: UUID(),
                title: "Chapter 1",
                levels: [
                    Level(
                        id: UUID(),
                        name: "Tap Game",
                        content: AnyView(TapProgressView()),
                        transition: .cameraPan,
                        winCondition: .custom({ false }),
                        isCompleted: false
                    ),
                    Level(
                        id: UUID(),
                        name: "Dust Remover",
                        content: AnyView(DustRemoverView2(
                            backgroundImage: Image("rectangle33"),
                            foregroundImage: Image("rectangle35"),
                            completionThreshold: 90.0)
                        ),
                        transition: .cameraPan,
                        winCondition: .custom({ false }),
                        isCompleted: false
                    ),
                    Level(
                        id: UUID(),
                        name: "Drag Game",
                        content: AnyView(DragProgressView(swipeSensitivity: 8.0)),
                        transition: .fade,
                        winCondition: .custom({ false }),
                        isCompleted: false
                    )
                ],
                isUnlocked: true
            )
        ]
        
        // Initialize with sample data
        _levelManager = State(initialValue: LevelManager(chapters: sampleChapters))
        
        
    }
    
    private func getTransition(for type: LevelTransition) -> AnyTransition {
        switch type {
        case .fade:
            return .opacity
        case .cameraPan:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        }
    }
    
    
    var body: some View {
        ZStack {
            // Current level content
            levelManager.currentLevel.content
                .transition(getTransition(for: levelManager.currentLevel.transition))
            // este le sirve a swift para darse que index ha usado  swift ui
                .id("\(levelManager.currentChapterIndex)-\(levelManager.currentLevelIndex)-\(levelManager.updateCounter)")
            

        }
        .environment(\.levelManager, levelManager)
        .animation(.easeInOut(duration: levelManager.currentLevel.transition.duration), value: levelManager.updateCounter)
    }
}

// Environment key for level manager

#Preview {
    GameContainer()
}

