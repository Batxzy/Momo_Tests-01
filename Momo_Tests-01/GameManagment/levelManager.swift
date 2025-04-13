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
    var itemSpacing: CGFloat = 40 // Spacing between carousel items
    
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
    
    
    
    // Regular level completion transitions
    func completeLevel() {
            
            if currentChapterIndex < chapters.count && currentLevelIndex < chapters[currentChapterIndex].levels.count {
                
                 chapters[currentChapterIndex].levels[currentLevelIndex].isCompleted = true
            }


            if currentLevelIndex + 1 < chapters[currentChapterIndex].levels.count {
                currentLevelIndex += 1
            } else if currentChapterIndex + 1 < chapters.count {
               
                currentChapterIndex += 1
                currentLevelIndex = 0
                 if currentChapterIndex < chapters.count {
                     chapters[currentChapterIndex].isUnlocked = true
                 }
            } else {
              
                print("All levels completed!")
                // You might want to add state here to indicate game completion
                return // Stop further updates if the game is over
            }

            // Increment the counter to trigger the transition in GameContainer
            updateCounter += 1
            print("Level completed. New state: Chapter \(currentChapterIndex), Level \(currentLevelIndex), UpdateCounter: \(updateCounter)")
        }
    
    private func handleGameCompletion() {
        print("All chapters and levels completed!")
        lastActionLog = "Game completed!"
    }
    
    
    init(chapters: [Chapter]) {
        self.chapters = chapters
        self.currentChapterIndex = 0
        self.currentLevelIndex = 0
        
        // Make first chapter unlocked by default
        if !chapters.isEmpty {
            var updatedChapters = chapters
            updatedChapters[0].isUnlocked = true
            self.chapters = updatedChapters
        }
    }
}
