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
    func completeCurrentLevel() {
        lastActionLog = "Completing level: \(currentLevel.name)"
        print("Completing level: \(currentLevel.name)")

        //para si el index ta mal
        guard currentLevelIndex < chapters[currentChapterIndex].levels.count else {
            return
        }
        
        // completa el nivel
        chapters[currentChapterIndex].levels[currentLevelIndex].isCompleted = true
        
        // Update level/chapter immediately - transition is handled by SwiftUI 
        if hasNextLevelInCurrentChapter {
            currentLevelIndex += 1
        } else if hasNextChapter {
            chapters[currentChapterIndex + 1].isUnlocked = true
            currentChapterIndex += 1
            currentLevelIndex = 0
        } else {
            handleGameCompletion()
        }
        
        updateCounter += 1
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
