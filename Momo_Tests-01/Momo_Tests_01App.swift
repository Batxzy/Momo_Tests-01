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
                        case .gallery:
                            // Navigate to Galleryview, passing the main path
                            Galleryview(path: $navigationPath)
                                .navigationBarBackButtonHidden() // You might want this hidden or not
                        // Add destination for the image detail
                        case .imageDetail(let allNames, let selectedName, let namespace):
                            ImageGalleryView(
                                allImageNames: allNames,
                                selectedImageName: selectedName,
                                namespace: namespace
                            )
                            .navigationTransition(
                                .zoom(sourceID: selectedName, in: namespace)
                            )
                            .navigationBarBackButtonHidden(true)
                            .toolbar(.hidden, for: .navigationBar)                       }
                    }
            }
           
            .environment(levelManager)
            .navigationTransition(
                .fade(.out).animation(.easeInOut(duration: 0.8)))
            .onAppear {
                           levelManager.onChapterCompleteNavigation = {
                               print("Navigation callback triggered.")
                               
                               // Clear the entire navigation stack and start fresh
                               navigationPath = NavigationPath()
                               
                               // Add only the chapter menu
                               navigationPath.append(NavigationTarget.chapterMenu)
                               print("Navigating to ChapterMenu with a fresh stack.")
                           }
                       }
        }
    }
}
