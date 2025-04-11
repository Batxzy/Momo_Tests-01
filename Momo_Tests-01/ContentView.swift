import SwiftUI

struct ContentView: View {
    @State private var levelManager: LevelManager
    @State private var minigameCompleted: String? = nil
    @State private var debugMessage: String = ""
    @State private var scrollPosition: String? = nil
    @State private var isUserScrolling: Bool = false
    
    init() {
        _levelManager = State(initialValue: LevelManager(chapters: []))
        let chapters = createGameLevels()
        _levelManager = State(initialValue: LevelManager(chapters: chapters))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Scrollable carousel with previews
                ScrollViewCarousel(
                    levelManager: levelManager,
                    geometry: geometry,
                    scrollPosition: $scrollPosition,
                    isScrolling: $isUserScrolling,
                    onLevelSelected: { index in
                        if index != levelManager.currentLevelIndex {
                            // User scrolled to a different level
                            levelManager.transitionDirection = index > levelManager.currentLevelIndex ? .next : .previous
                            levelManager.currentLevelIndex = index
                            levelManager.updateCounter += 1
                        }
                    }
                )
                .zIndex(1)
                
                // Debug overlay
                debugOverlay
                    .zIndex(10)
            }
            .onChange(of: levelManager.currentLevelIndex) { _, newIndex in
                // When level changes programmatically, scroll to that position
                if !isUserScrolling {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        scrollPosition = "level-\(levelManager.currentChapterIndex)-\(newIndex)"
                    }
                }
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
                            // First determine destination index
                            let nextIndex = levelManager.getNextLevelIndex()
                            
                            // Then animate to the next position with properly timed animation
                            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                                scrollPosition = "level-\(levelManager.currentChapterIndex)-\(nextIndex)"
                                
                                // Update model after a brief delay to match animation timing
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    levelManager.currentLevelIndex = nextIndex
                                    levelManager.updateCounter += 1
                                }
                            }
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
    
    // Create the game levels
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
                // No padding or background to allow full screen usage
            ),
            transition: .cameraPan,
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
                // No padding or background to allow full screen usage
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

// Fixed ScrollViewCarousel implementation
struct ScrollViewCarousel: View {
    var levelManager: LevelManager
    let geometry: GeometryProxy
    @Binding var scrollPosition: String?
    @Binding var isScrolling: Bool
    var onLevelSelected: (Int) -> Void
    
    var body: some View {
        ZStack {
            // Main ScrollView for programmatic scrolling only
            ScrollViewReader { scrollReader in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(0..<levelManager.currentChapter.levels.count, id: \.self) { index in
                            let level = levelManager.currentChapter.levels[index]
                            
                            level.content
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .id("level-\(levelManager.currentChapterIndex)-\(index)")
                        }
                    }
                    .scrollTargetLayout()
                }
                .coordinateSpace(name: "scroll")
                .scrollPosition(id: $scrollPosition)
                .scrollTargetBehavior(.paging)
                .scrollIndicators(.hidden)
                .onAppear {
                    // Initialize to current level position
                    scrollPosition = "level-\(levelManager.currentChapterIndex)-\(levelManager.currentLevelIndex)"
                }
                .onChange(of: scrollPosition) { _, newPosition in
                    if let pos = newPosition {
                        scrollReader.scrollTo(pos, anchor: .center)
                    }
                }
            }
            
            // Overlay to block scrolling but allow tap interactions
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .gesture(
                    // Block drag gestures to prevent scrolling
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in }
                )
                .allowsHitTesting(true) // Capture gestures
        }
    }
}

// Preference key for tracking scroll position
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

// Helper extension
extension LevelTransition {
    var debugDescription: String {
        switch self {
        case .fade: return "fade"
        case .cameraPan: return "cameraPan"
        }
    }
}
