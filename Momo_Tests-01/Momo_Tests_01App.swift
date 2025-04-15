//
//  Momo_Tests_01App.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 10/04/25.
//

import SwiftUI

@main

struct Momo_Tests_01App: App {

    @State private var levelManager = LevelManager()
    // Added: State variable for NavigationPath
    @State private var navigationPath = NavigationPath()

    var body: some Scene {
        WindowGroup {
            // Changed: Replaced Test_Transition() with NavigationStack
            NavigationStack(path: $navigationPath) {
                // Changed: Start with MainMenu, passing the path
                MainMenu(path: $navigationPath)
                    // Added: Define destinations for NavigationTarget enum cases
                    .navigationDestination(for: NavigationTarget.self) { target in
                        switch target {
                        case .chapterMenu:
                            ChapterMenu(path: $navigationPath) // Pass path
                        case .game:
                            ContentView(path: $navigationPath)    // Pass path
                        }
                    }
            }
            // Added: Provide LevelManager to the environment
            .environment(levelManager)
        }
    }
}
