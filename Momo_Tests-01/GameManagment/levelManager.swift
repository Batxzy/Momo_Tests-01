//
//  levelmanager.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 10/04/25.
//

import Foundation
import SwiftUI

@Observable class LevelManager {
    var chapters: [Chapter]
    var currentChapterIndex: Int
    var currentLevelIndex: Int
    var transitionType: LevelTransition?
    
    
    // For update tracking
    var lastActionLog: String = ""
    var updateCounter: Int = 0
    
    var currentChapter: Chapter {
        chapters[currentChapterIndex]
    }
    
    var currentLevel: Level {
        currentChapter.levels[currentLevelIndex]
    }
    
    private var hasNextLevelInCurrentChapter: Bool {
        currentLevelIndex + 1 < currentChapter.levels.count
    }
    
    private var hasNextChapter: Bool {
        currentChapterIndex + 1 < chapters.count
    }
    
    var onChapterCompleteNavigation: (() -> Void)?
    
    
    // Regular level completion transitions
    func completeLevel() {

        guard chapters.indices.contains(currentChapterIndex),
              chapters[currentChapterIndex].levels.indices.contains(currentLevelIndex) else {
            print("Error: Invalid state in completeLevel")
            return
        }

        chapters[currentChapterIndex].levels[currentLevelIndex].isCompleted = true
        print("Completed Level: Chapter \(currentChapterIndex + 1), Level \(currentLevelIndex + 1)")

        if hasNextLevelInCurrentChapter {
            currentLevelIndex += 1
            updateCounter += 1
            lastActionLog = "Advanced to Level \(currentLevelIndex + 1) in Chapter \(currentChapterIndex + 1)"
            print(lastActionLog)
            // No callback needed here, just advancing level
        } else {
            // --- Chapter Finished ---
            lastActionLog = "Completed Chapter \(currentChapterIndex + 1)"
            print(lastActionLog)

            if hasNextChapter {
                chapters[currentChapterIndex + 1].isUnlocked = true
                print("Unlocked Chapter \(currentChapterIndex + 2)")
                // Don't return yet, we need to trigger navigation
            } else {
                handleGameCompletion()
                // Don't return yet, trigger navigation even if game is fully complete
            }

            updateCounter += 1
            // --- Trigger the navigation callback AFTER handling chapter completion logic ---
            onChapterCompleteNavigation?()
        }
    }
        
        private func handleGameCompletion() {
            print("All chapters and levels completed!")
            lastActionLog = "Game completed!"
        }
        
        func startGame(chapterIndex: Int) {
            currentChapterIndex = chapterIndex
            currentLevelIndex = 0
        }
        
        // Updated initializer with mock data
        init() {
            // --- Sample Data ---
            let chapter1Levels = [
                Level(
                    id: UUID(),
                    name: "Tap Game",
                    content: AnyView(TapProgressView(
                        illustration: Image("rectangle33"))
                    ),
                    transition: .cameraPan,
                    isCompleted: false
                ),
                Level(id: UUID(),
                      name: "1_1",
                      content: AnyView(ImageScrollView(images: Scroll_1_1)),
                      transition: .cameraPan,
                      isCompleted: false
                     ),
                Level(
                    id: UUID(),
                    name: "Dust Remover",
                    content: AnyView(DustRemoverView2(
                        backgroundImage: Image("rectangle33"),
                        foregroundImage: Image("rectangle35"),
                        completionThreshold: 90.0)
                    ),
                    transition: .cameraPan,
                    isCompleted: false
                ),
                Level(
                    id: UUID(),
                    name: "Swipe Game",
                    content: AnyView(ImageTap(
                        iulstration: Image("rectangle33"))
                    ),
                    transition: .cameraPan,
                    isCompleted: false
                ),
                Level(id: UUID(),
                      name: "test_dialogue",
                      content: AnyView(DialogueView(
                        dialogueImage: Image("rectangle33"),
                        ilustration: Image("Reason"))
                      ),
                      transition: .cameraPan,
                      isCompleted: false),
                Level(
                    id: UUID(),
                    name: "Drag Game",
                    content: AnyView(DragProgressView(
                        swipeSensitivity: 8.0)
                    ),
                    transition: .cameraPan,
                    isCompleted: false
                ),
                Level(
                    id: UUID(),
                    name: "Tapping",
                    content: AnyView(CirclesView(ilustration:Image("Reason" ))),
                    transition: .cameraPan,
                    isCompleted: false
                )
            ]
            
            let chapter2Levels = [
                Level(id: UUID(), name: "2_1", content: AnyView(Text("Chapter 2 - Level 1 Placeholder")), transition: .fade),
                Level(id: UUID(), name: "2_2", content: AnyView(Text("Chapter 2 - Level 2 Placeholder")), transition: .fade),
            ]
            
            let chapter3Levels = [
                Level(id: UUID(), name: "3_1", content: AnyView(Text("Chapter 3 - Level 1 Placeholder")), transition: .cameraPanF),
                Level(id: UUID(), name: "3_2", content: AnyView(Text("Chapter 3 - Level 2 Placeholder")), transition: .cameraPanF),
            ]
            
            self.chapters = [
                Chapter(id: UUID(), title: "Chapter 1", levels: chapter1Levels, isUnlocked: true), // First chapter starts unlocked
                Chapter(id: UUID(), title: "Chapter 2", levels: chapter2Levels, isUnlocked: false),
                Chapter(id: UUID(), title: "Chapter 3", levels: chapter3Levels, isUnlocked: false)
            ]
            // --- End Sample Data ---
            
            self.currentChapterIndex = 0 // Default start
            self.currentLevelIndex = 0   // Default start
            
            // Ensure first chapter is marked unlocked explicitly if needed
            if !chapters.isEmpty && !chapters[0].isUnlocked {
                self.chapters[0].isUnlocked = true
            }
            print("LevelManager initialized with \(chapters.count) chapters.")
        }
    }
