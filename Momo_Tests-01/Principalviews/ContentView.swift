import SwiftUI

struct ContentView: View {
    @Environment(LevelManager.self) private var levelManager
    @Binding var path: NavigationPath // To pop back
    
    
    private func getTransition(for type: LevelTransition) -> AnyTransition {
        switch type {
        case .fade:
            return .opacity
        case .cameraPanF:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .opacity
                )
        case .cameraPan:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        }
    }
    
    
    var body: some View {
        ZStack {
            // Display current level content from LevelManager
            levelManager.currentLevel.content
                .transition(getTransition(for: levelManager.currentLevel.transition))
                .id("\(levelManager.currentChapterIndex)-\(levelManager.currentLevelIndex)-\(levelManager.updateCounter)")
            
            // Added: White overlay for chapter completion fade
            Color.white
                .opacity(levelManager.showChapterCompletionFade ? 1 : 0)
                .ignoresSafeArea()
                // Use a specific animation for the fade overlay
                .animation(.easeInOut(duration: 1.1), value: levelManager.showChapterCompletionFade)
        }

        .animation(.spring(duration: levelManager.currentLevel.transition.duration), value: levelManager.updateCounter)
        // Handle chapter completion state change
        .onChange(of: levelManager.showChapterCompletionFade) { oldValue, newValue in
            if newValue == true {
                // Trigger navigation immediately when the fade starts
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { // Delay slightly longer than animation
                                    levelManager.onChapterCompleteNavigation?() // Trigger the navigation callback
                                    // Reset the flag after navigation is triggered
                                    // Ensure this runs even if the view disappears immediately
                                    Task { @MainActor in
                                         levelManager.showChapterCompletionFade = false
                                    }
                                }
            }
        }
    }
}

#Preview {
    struct GameViewPreviewContainer: View {
         @State var previewPath = NavigationPath()
         @State var previewLevelManager = LevelManager()

         var body: some View {
             NavigationStack(path: $previewPath) {
                 ContentView(path: $previewPath)
                     .navigationDestination(for: NavigationTarget.self) { target in
                         Text("Preview Destination: \(String(describing: target))")
                     }
             }
             .environment(previewLevelManager)
         }
     }
     return GameViewPreviewContainer()
}

