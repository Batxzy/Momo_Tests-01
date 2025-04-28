//
//  Momo_Tests_01App.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 10/04/25.
//

import SwiftUI
import NavigationTransitions

@main

struct Momo_Tests_01App: App {

    @State private var levelManager = LevelManager()
    @State private var navigationPath = NavigationPath()
    
    var body: some Scene {
        WindowGroup {
            
            NavigationStack(path: $navigationPath) {
                
                MainMenu(path: $navigationPath)
                    
                    .navigationDestination(for: NavigationTarget.self) { target in
                        switch target {
                        case .chapterMenu:
                            ChapterMenu(path: $navigationPath)
                                .navigationBarBackButtonHidden()
                        case .game:
                            ContentView(path: $navigationPath)
                                .navigationBarBackButtonHidden()
                        }
                    }
            }
           
            .environment(levelManager)
            .navigationTransition(
                .fade(.out).animation(.easeInOut(duration: 0.8)))
            .onAppear {
               levelManager.onChapterCompleteNavigation = {
                   print("Navigation callback triggered.")
                   var updatedPath = navigationPath

                   if !updatedPath.isEmpty {
                        updatedPath.removeLast()
                   }

                   updatedPath.append(NavigationTarget.chapterMenu)
                   print("Navigating to ChapterMenu.")

                   navigationPath = updatedPath
               }
           }
        }
    }
}
