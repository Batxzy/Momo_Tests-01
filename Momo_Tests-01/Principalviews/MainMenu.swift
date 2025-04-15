//
//  MainMenu.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI

struct MainMenu: View {
    @Environment(LevelManager.self) private var levelManager
    @Binding var path: NavigationPath
    
    var body: some View {
        
        VStack(spacing: 15){
            
            Image("Reason")
                .resizable()
                .scaledToFill()
                .frame(width:280,height: 420 )
                .clipped()
            
            

            VStack(spacing: 32) {
                // Changed: Text wrapped in a Button
                Button {
                    // Added: Action to start game and navigate
                    levelManager.startGame(chapterIndex: 0) // Start Chapter 1
                    path.append(NavigationTarget.game)     // Navigate to GameView
                } label: {
                    Text("Nueva partida")
                        .font(.system(size: 32, weight: .medium))
                }

                // Changed: Text wrapped in a Button
                Button {
                    // Added: Action to navigate to chapters
                    path.append(NavigationTarget.chapterMenu) // Navigate to ChapterMenu
                } label: {
                    Text("Capitulos")
                        .font(.system(size: 32, weight: .medium))
                }

                // Other options remain Text for now, aded gray color
                Text("Configuracion")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.gray) // Example: Disable visually

                Text("Galeria")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.gray) // Example: Disable visually    
            }
        .navigationBarHidden(true)
        }
    }
}

#Preview {
    @State var previewPath = NavigationPath()
    @State var previewLevelManager = LevelManager()

    return NavigationStack {
         MainMenu(path: $previewPath)
     }
     .environment(previewLevelManager)
}
