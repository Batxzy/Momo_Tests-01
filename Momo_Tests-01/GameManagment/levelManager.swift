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
    
    enum TransitionDirection {
        case next, previous
    }
    
    // Get the next logical level index for transitions
    func getNextLevelIndex() -> Int {
        let totalLevels = currentChapter.levels.count
        if totalLevels < 2 { return currentLevelIndex } // No change if fewer than 2 levels
        
        let nextLevelIndex: Int
        if transitionDirection == .next {
            // Going forward
            nextLevelIndex = (currentLevelIndex < totalLevels - 1) ? currentLevelIndex + 1 : 0
        } else {
            // Going backward
            nextLevelIndex = (currentLevelIndex > 0) ? currentLevelIndex - 1 : totalLevels - 1
        }
        
        // Toggle direction for next time
        transitionDirection = transitionDirection == .next ? .previous : .next
        
        return nextLevelIndex
    }
    
    // For debugging purposes - trigger transitions between views
    func debugTriggerTransition(_ type: LevelTransition) {
        print("DEBUG: Manually triggering \(type) transition between views")
        
        // Just use the fade transition directly
        if type == .fade {
            // Set transition type and start transitioning
            transitionType = type
            isTransitioning = true
            
            // Change level immediately
            currentLevelIndex = getNextLevelIndex()
            updateCounter += 1
        }
        // Camera pan transitions are now handled via ScrollView in ContentView
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
