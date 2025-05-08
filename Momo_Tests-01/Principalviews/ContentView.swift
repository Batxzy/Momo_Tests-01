import SwiftUI

struct ContentView: View {
//MARK: - Properties y funcion
    
    @Environment(LevelManager.self) private var levelManager
    @Binding var path: NavigationPath
    
    
    // para controlar el fade del final del nivel
    let fadeInDuration: Double = 2.0
    let holdDuration: Double = 0.3
    
    //propiedad computada para el id
    private var currentLevelIdentifier: String {
           "\(levelManager.currentChapterIndex)-\(levelManager.currentLevelIndex)"
       }
    
    //switch para ver que transciones va a usar
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
        case .cameraPanV:
            return .asymmetric(
                insertion: .move(edge: .bottom),
                removal: .move(edge: .top)
            )
            
        case .cameraPanNormalV:
            return .asymmetric(
                insertion: .move(edge: .bottom),
                removal: .move(edge: .leading)
            )
        }
    }
    
//MARK: -View
    var body: some View {
        ZStack {
            //llama al view del juego que le corresponde
            levelManager.currentLevel.content
                // usa la transicion del nivel actual
                .transition(getTransition(for: levelManager.currentLevel.transition))
                .id(currentLevelIdentifier)
            
            Color.white
                .opacity(levelManager.showChapterCompletionFade ? 1 : 0)
                .ignoresSafeArea()
            
            //** control de la curva de animacion **//
                .animation(.easeInOut(duration: fadeInDuration), value: levelManager.showChapterCompletionFade)
        }
        
        //llama al tipo de animacion que queremos para la transcion
        .animation(levelManager.currentLevel.animation, value: currentLevelIdentifier)
        
        //cuando se acaba el capitulo este bro maneja la transcion
        .onChange(of: levelManager.showChapterCompletionFade) { oldValue, newValue in
            if newValue == true {

                // Navega cuando la pantalla verde esta al maximo
                DispatchQueue.main.asyncAfter(deadline: .now() + fadeInDuration + holdDuration) {
                    path.append(NavigationTarget.chapterMenu)
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
             .onAppear {
                 // Set the chapter index when preview appears
                 previewLevelManager.currentChapterIndex = 1
             }
         }
     }
     return GameViewPreviewContainer()
}

