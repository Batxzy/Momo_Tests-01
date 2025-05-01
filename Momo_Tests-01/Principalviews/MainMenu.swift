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
        
        VStack(spacing: 36){
            
            Image("Reason")
                .resizable()
                .scaledToFill()
                .frame(width:280,height: 420 )
                .clipped()
            
            

            VStack(spacing: 8) {
                Button {
                    //inicia el nivel y te manda a la pantalla de capitulos
                    levelManager.startGame(chapterIndex: 0)
                    path.append(NavigationTarget.game)
                } label: {
                    Text("Nueva partida")
                        .font(.Patrick32)
                        .foregroundColor(.black)

                }
                .padding(12)
                
                // te manda a la pestaña de capitulos
                Button {
                    // Added: Action to navigate to chapters
                    path.append(NavigationTarget.chapterMenu) // Navigate to ChapterMenu
                } label: {
                    Text("Capitulos")
                        .font(.Patrick32)
                        .foregroundColor(.black)
                }
                .padding(12)
                
                Text("Configuracion")
                    .font(.Patrick32)
                    .padding(12)
                
                Text("Galeria")
                    .font(.Patrick32)
                    .padding(12)
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
