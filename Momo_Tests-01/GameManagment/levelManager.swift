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
    var transitionDirection: TransitionDirection = .next
    var itemSpacing: CGFloat = 40 // Space between carousel items
    
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
    
    enum TransitionDirection {
        case next, previous
    }
    
    // For debugging purposes - trigger transitions between views
    func debugTriggerTransition(_ type: LevelTransition) {
        print("DEBUG: Manually triggering \(type) transition between views")
        
        // Figure out which level to transition to
        let nextLevelIndex = (currentLevelIndex < currentChapter.levels.count - 1) ? 
                            currentLevelIndex + 1 : 0
                            
        // First set the transition direction 
        transitionDirection = nextLevelIndex > currentLevelIndex ? .next : .previous
        
        // Set transition type and start transitioning - animation handled by SwiftUI
        transitionType = type
        isTransitioning = true
        
        // Change level immediately - transition is handled by SwiftUI
        self.currentLevelIndex = nextLevelIndex
        updateCounter += 1
    }
    
    // Regular level completion transitions
    func completeCurrentLevel() {
        lastActionLog = "Completing level: \(currentLevel.name)"
        print("Completing level: \(currentLevel.name)")

        guard currentLevelIndex < chapters[currentChapterIndex].levels.count else {
            return
        }
        
        chapters[currentChapterIndex].levels[currentLevelIndex].isCompleted = true
        
        // Retain current transition style before changing state
        let transitionStyle = currentLevel.transition
        transitionType = transitionStyle
        transitionDirection = .next // Always move forward on completion
        isTransitioning = true
                
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
