//
//  levelmanager.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 10/04/25.
//

import Foundation
import SwiftUI

@Observable
class LevelManager {
    var chapters: [Chapter]
    var currentChapterIndex: Int
    var currentLevelIndex: Int
    var isTransitioning: Bool = false
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
    
    // For debugging purposes - trigger transitions between views
    func debugTriggerTransition(_ type: LevelTransition) {
        print("DEBUG: Manually triggering \(type) transition between views")
        
        // Figure out which level to transition to
        let nextLevelIndex = (currentLevelIndex < currentChapter.levels.count - 1) ? 
                             currentLevelIndex + 1 : 0
        
        // Signal transition start
        isTransitioning = true
        transitionType = type
        updateCounter += 1
        
        // Short delay to allow transition to start visually
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Change to next level
            self.currentLevelIndex = nextLevelIndex
            self.updateCounter += 1
            
            // Short delay to finish transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isTransitioning = false
                self.transitionType = nil
                self.updateCounter += 1
            }
        }
    }
    
    // Regular level completion transitions
    func completeCurrentLevel() {
        lastActionLog = "Completing level: \(currentLevel.name)"
        print("Completing level: \(currentLevel.name)")

        guard currentLevelIndex < chapters[currentChapterIndex].levels.count else {
            return
        }
        
        chapters[currentChapterIndex].levels[currentLevelIndex].isCompleted = true
        let transitionStyle = currentLevel.transition
        
        // Signal transition start
        isTransitioning = true
        transitionType = transitionStyle
        updateCounter += 1
        
        // Delay to let transition animation start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Move to appropriate next level or chapter
            if self.hasNextLevelInCurrentChapter {
                self.currentLevelIndex += 1
            } else if self.hasNextChapter {
                self.chapters[self.currentChapterIndex + 1].isUnlocked = true
                self.currentChapterIndex += 1
                self.currentLevelIndex = 0
            } else {
                self.handleGameCompletion()
            }
            
            self.updateCounter += 1
            
            // Finish transition after content has changed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isTransitioning = false
                self.transitionType = nil
                self.updateCounter += 1
            }
        }
    }
    
    private func handleGameCompletion() {
        print("All chapters and levels completed!")
        lastActionLog = "Game completed!"
    }
    
    func checkWinCondition(scrollPosition: ScrollPosition? = nil, minigameCompleted: String? = nil) -> Bool {
        switch currentLevel.winCondition {
        case .completeMinigame(let id):
            return minigameCompleted == id
        case .custom(let condition):
            return condition()
        }
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
