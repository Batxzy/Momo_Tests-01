import SwiftUI

struct ContentView: View {
//MARK: - Properties y funcion
    @Environment(LevelManager.self) private var levelManager
    @Binding var path: NavigationPath // To pop back
    
    let fadeInDuration: Double = 2.0
    let holdDuration: Double = 0.3
    let fadeOutDuration: Double = 1.8
    
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
            //llama al view del juego que le corresponde
            levelManager.currentLevel.content
                // usa la trancion del nivel actual
                .transition(getTransition(for: levelManager.currentLevel.transition))
                .id("\(levelManager.currentChapterIndex)-\(levelManager.currentLevelIndex)-\(levelManager.updateCounter)")
            
            // vemos si funciona
            Color.white
                .opacity(levelManager.showChapterCompletionFade ? 1 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.8), value: levelManager.showChapterCompletionFade)
        }
        //animacion que se le aplica a la transcion
        .animation(.spring(duration: levelManager.currentLevel.transition.duration), value: levelManager.updateCounter)
        
        .onChange(of: levelManager.showChapterCompletionFade) { oldValue, newValue in
            if newValue == true {
                // Start fade-in animation
                withAnimation(.easeIn(duration: fadeInDuration)) {
                    // Set to true (already happening in your code)
                }
                
                // Navigate during peak opacity
                DispatchQueue.main.asyncAfter(deadline: .now() + fadeInDuration + holdDuration) {
                    path.append(NavigationTarget.chapterMenu)
                    
                    // Start fade-out animation after navigation
                    withAnimation(.easeOut(duration: fadeOutDuration)) {
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

