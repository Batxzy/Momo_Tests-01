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
                            // Then trigger scroll behavior directly
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                scrollPosition = "level-\(levelManager.currentChapterIndex)-\(nextIndex)"
                                // Give time for the scroll to start before updating the model
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
                .padding(40) // Increased padding for more space
                .background(Color.white)
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
                .padding(40) // Increased padding for more space
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

// LazyScrollView-based carousel component - fix Observable type
struct ScrollViewCarousel: View {
    // Remove @ObservedObject since we're using @Observable macro
    var levelManager: LevelManager
    let geometry: GeometryProxy
    @Binding var scrollPosition: String?
    @Binding var isScrolling: Bool
    var onLevelSelected: (Int) -> Void
    
    var body: some View {
        // Outer container to handle positioning
        ZStack {
            // Main carousel
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 40) {
                    // Add spacer at the beginning to center the first item
                    Spacer()
                        .frame(width: geometry.size.width * 0.1)
                    
                    // Generate all levels in the current chapter
                    ForEach(0..<levelManager.currentChapter.levels.count, id: \.self) { index in
                        let level = levelManager.currentChapter.levels[index]
                        let isCurrentLevel = index == levelManager.currentLevelIndex
                        
                        // Individual level view
                        level.content
                            .padding(20)
                            .background(Color.white)
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.9)
                            .id("level-\(levelManager.currentChapterIndex)-\(index)")
                            .scaleEffect(isCurrentLevel ? 1.0 : 0.9)
                            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isCurrentLevel)
                    }
                    
                    // Add spacer at the end to center the last item
                    Spacer()
                        .frame(width: geometry.size.width * 0.1)
                }
                .scrollTargetLayout()
            }
            .coordinateSpace(name: "scroll") // Important for scroll tracking
            .scrollPosition(id: $scrollPosition)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            // Track when user is scrolling vs. programmatic scrolling
            .onScrollViewDidScroll { _ in
                isScrolling = true
            }
            .onScrollViewDidEndDragging { point in
                // When user finishes scrolling, find which element they stopped on
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isScrolling = false
                    
                    // Figure out which level we're positioned at
                    if let positionId = scrollPosition,
                       positionId.hasPrefix("level-\(levelManager.currentChapterIndex)-") {
                        let components = positionId.components(separatedBy: "-")
                        if components.count >= 3, let index = Int(components[2]) {
                            onLevelSelected(index)
                        }
                    }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: scrollPosition)
        }
    }
}

// Extension for scrolling events
extension View {
    func onScrollViewDidScroll(_ action: @escaping (CGPoint) -> Void) -> some View {
        self.background(
            GeometryReader { geo in
                let offset = CGPoint(x: -geo.frame(in: .named("scroll")).minX,
                                     y: -geo.frame(in: .named("scroll")).minY)
                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: offset)
            }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            action(value)
        }
    }
    
    func onScrollViewDidEndDragging(_ action: @escaping (CGPoint) -> Void) -> some View {
        self.background(
            GeometryReader { geo in
                let offset = CGPoint(x: -geo.frame(in: .named("scroll")).minX,
                                     y: -geo.frame(in: .named("scroll")).minY)
                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: offset)
            }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            action(value)
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
