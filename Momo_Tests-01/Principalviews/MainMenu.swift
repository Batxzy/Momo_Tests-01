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
        
        VStack(spacing: 30){
            
            Image("Reason")
                .resizable()
                .scaledToFill()
                .frame(width:288,height: 420 )
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
                
                Button {
                    path.append(NavigationTarget.gallery)
                } label: {
                    Text("Galeria")
                        .font(.Patrick32)
                        .foregroundColor(.black)
                }
                .padding(12)
                
                Text("Configuracion")
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
                                                case .gallery:
                                                     // Show the actual Galleryview in preview if possible
                                                     Galleryview(path: $previewPath)
                                                        .navigationTitle("Gallery Preview")
                                                case .imageDetail(let names, let selected, _):
                                                     // Show a representation of the image detail view
                                                     Text("Preview: Image Detail for \(selected) (\(names.count) total)")
                                                        .navigationTitle("Image Detail Preview")
                        }
                    }
            }
            .environment(previewLevelManager)
        }
    }
    return PreviewWrapper()
}
