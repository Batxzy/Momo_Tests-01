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

// LazyScrollView-based carousel component that completely blocks scrolling
struct ScrollViewCarousel: View {
    var levelManager: LevelManager
    let geometry: GeometryProxy
    @Binding var scrollPosition: String?
    @Binding var isScrolling: Bool
    var onLevelSelected: (Int) -> Void
    
    // Disable ScrollView pan gesture completely
    private class NoOpScrollViewDelegate: NSObject, UIScrollViewDelegate {tions but no scrolling
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {owsIndicators: false) {
            scrollView.isScrollEnabled = false
            DispatchQueue.main.async {       ForEach(0..<levelManager.currentChapter.levels.count, id: \.self) { index in
                scrollView.isScrollEnabled = true               let level = levelManager.currentChapter.levels[index]
            }                   
        }                    // Individual level view - full screen
    }evel.content
    ame(width: geometry.size.width, height: geometry.size.height)
    var body: some View {            .id("level-\(levelManager.currentChapterIndex)-\(index)")
        // Full-screen carousel
        ZStack {
            // Main carousel
            ScrollViewReader { scrollReader in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        // Generate all levels in the current chapter as full-screen views
                        ForEach(0..<levelManager.currentChapter.levels.count, id: \.self) { index in
                            let level = levelManager.currentChapter.levels[index]locks gestures
                            h content below
                            // Individual level view - full screen
                            level.content
                                .frame(width: geometry.size.width, height: geometry.size.height) geometry.size.height)
                                .id("level-\(levelManager.currentChapterIndex)-\(index)")hape(Rectangle())
                                .contentShape(Rectangle())is captures and consumes all drag events
                        }gesture(
                    }
                }hanged { _ in }
                // Apply UIKit delegate to disable scrolling}
                .background(
                    ScrollViewDisabler()
                )
                .onAppear {
                    // Ensure initial position is correct
                    withAnimation(.none) {lling events
                        scrollPosition = "level-\(levelManager.currentChapterIndex)-\(levelManager.currentLevelIndex)"
                    } -> Void) -> some View {
                }
                .onChange(of: scrollPosition) { _, newPos in
                    if let pos = newPos {ffset = CGPoint(x: -geo.frame(in: .named("scroll")).minX,
                        scrollReader.scrollTo(pos, anchor: .center)                    y: -geo.frame(in: .named("scroll")).minY)
                    }   Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: offset)
                }
            }
            .scrollDisabled(true) // Native SwiftUI way to disable scrolling
            e)
            // Catch-all gesture blocker overlay - passes touches to content but blocks scrolling
            Color.clear
                .frame(width: geometry.size.width, height: geometry.size.height)
                .contentShape(Rectangle()) action: @escaping (CGPoint) -> Void) -> some View {
                // This high-priority gesture prevents any ScrollView gestures
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0)geo.frame(in: .named("scroll")).minX,
                        .onChanged { _ in }                    y: -geo.frame(in: .named("scroll")).minY)
                        .onEnded { _ in }ue: offset)
                )   }
                .allowsHitTesting(false) // Let touches pass through to content   )
        }       .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
    }            action(value)
}

// UIKit delegate to completely disable scrolling behavior
struct ScrollViewDisabler: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {or tracking scroll position
        let view = UIView()t ScrollOffsetPreferenceKey: PreferenceKey {
        return viewstatic var defaultValue: CGPoint = .zero
    }
    ) {
    func updateUIView(_ uiView: UIView, context: Context) {
        // Find the parent ScrollView and disable its scroll behavior
        DispatchQueue.main.async {
            var parentResponder: UIResponder? = uiView
            while parentResponder != nil {
                parentResponder = parentResponder?.next
                if let scrollView = parentResponder as? UIScrollView {
                    scrollView.isScrollEnabled = false
                    // For safety, also set non-interactive
                    scrollView.bounces = false
                    scrollView.alwaysBounceHorizontal = false
                    scrollView.alwaysBounceVertical = false
                    scrollView.panGestureRecognizer.isEnabled = false
                    break                }            }        }    }}// Extension for scrolling eventsextension View {    func onScrollViewDidScroll(_ action: @escaping (CGPoint) -> Void) -> some View {        self.background(            GeometryReader { geo in                let offset = CGPoint(x: -geo.frame(in: .named("scroll")).minX,                                     y: -geo.frame(in: .named("scroll")).minY)                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: offset)            }        )        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in            action(value)        }    }        func onScrollViewDidEndDragging(_ action: @escaping (CGPoint) -> Void) -> some View {        self.background(            GeometryReader { geo in                let offset = CGPoint(x: -geo.frame(in: .named("scroll")).minX,                                     y: -geo.frame(in: .named("scroll")).minY)                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: offset)            }        )        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in            action(value)        }    }}// Preference key for tracking scroll positionstruct ScrollOffsetPreferenceKey: PreferenceKey {    static var defaultValue: CGPoint = .zero        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {        value = nextValue()    }}// Helper extensionextension LevelTransition {    var debugDescription: String {        switch self {        case .fade: return "fade"        case .cameraPan: return "cameraPan"        }    }
}
