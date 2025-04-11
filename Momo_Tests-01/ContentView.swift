import SwiftUI

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
                        transition: .fade,
                        winCondition: .custom({ false }),
                        isCompleted: false
                    ),
                    Level(
                        id: UUID(),
                        name: "Dust Remover",
                        content: AnyView(DustRemoverView2(
                            backgroundImage: Image("rectangle33"),
                            foregroundImage: Image("rectangle35"),
                            completionThreshold: 0.9)
                        ),
                        transition: .cameraPan,
                        winCondition: .custom({ false }),
                        isCompleted: false
                    ),
                    Level(
                        id: UUID(),
                        name: "Drag Game",
                        content: AnyView(DragProgressView()),
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
    
    var body: some View {
        ZStack {
            // Current level content
            levelManager.currentLevel.content
                .id("\(levelManager.currentChapterIndex)-\(levelManager.currentLevelIndex)-\(levelManager.updateCounter)")
                .transition(getTransition(for: levelManager.currentLevel.transition))
            
            // Debug controls (optional - remove for production)
            VStack {
                Spacer()
                HStack {
                    Button("Next Level") {
                        withAnimation(.easeInOut(duration: levelManager.currentLevel.transition.duration)) {
                            levelManager.completeCurrentLevel()
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.bottom, 20)
            }
        }
        .environment(\.levelManager, levelManager)
        .animation(.easeInOut(duration: levelManager.currentLevel.transition.duration), value: levelManager.updateCounter)
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
}

// Environment key for level manager
private struct LevelManagerKey: EnvironmentKey {
    static let defaultValue: LevelManager = LevelManager(chapters: [])
}

extension EnvironmentValues {
    var levelManager: LevelManager {
        get { self[LevelManagerKey.self] }
        set { self[LevelManagerKey.self] = newValue }
    }
}

#Preview {
    GameContainer()
}

