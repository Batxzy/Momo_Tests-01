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
                Button {
                    //inicia el nivel y te manda a la pantalla de capitulos
                    levelManager.startGame(chapterIndex: 0)
                    path.append(NavigationTarget.game)
                } label: {
                    Text("Nueva partida")
                        .font(.system(size: 32, weight: .medium))
                }
                
                // te manda a la pestaña de capitulos
                Button {
                    // Added: Action to navigate to chapters
                    path.append(NavigationTarget.chapterMenu) // Navigate to ChapterMenu
                } label: {
                    Text("Capitulos")
                        .font(.system(size: 32, weight: .medium))
                }

                Text("Configuracion")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.gray)

                Text("Galeria")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.gray)
            }
        .navigationBarHidden(true)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var previewPath = NavigationPath()
        @State var previewLevelManager = LevelManager()

        var body: some View {
            NavigationStack(path: $previewPath) {
                MainMenu(path: $previewPath)
                    .navigationDestination(for: NavigationTarget.self) { target in
                        switch target {
                        case .game:
                            Text("Preview: Navigated to Game View")
                                .navigationTitle("Game Preview")
                                .navigationBarBackButtonHidden(true) // Hide back button in preview destination
                        case .chapterMenu:
                            Text("Preview: Navigated to Chapter Menu")
                                .navigationTitle("Chapters Preview")
                        }
                    }
            }
            .environment(previewLevelManager)
        }
    }
    return PreviewWrapper()
}
