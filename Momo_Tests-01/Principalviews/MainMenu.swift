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
    // Helper struct to hold state for the preview
    struct PreviewWrapper: View {
        @State var previewPath = NavigationPath()
        @State var previewLevelManager = LevelManager()

        var body: some View {
            // Bind the NavigationStack to the path
            NavigationStack(path: $previewPath) {
                MainMenu(path: $previewPath)
                    // Add navigation destinations for the preview
                    .navigationDestination(for: NavigationTarget.self) { target in
                        // Display placeholder views for the destinations in the preview
                        switch target {
                        case .game:
                            Text("Preview: Navigated to Game View")
                                .navigationTitle("Game Preview")
                                .navigationBarBackButtonHidden(true) // Hide back button in preview destination
                        case .chapterMenu:
                            Text("Preview: Navigated to Chapter Menu")
                                .navigationTitle("Chapters Preview")
                        // Add cases for any other NavigationTarget values if needed
                        }
                    }
            }
            .environment(previewLevelManager)
        }
    }
    // Return an instance of the helper struct
    return PreviewWrapper()
}
