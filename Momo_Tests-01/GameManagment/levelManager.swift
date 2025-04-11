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
        
        // Important: First set the transition type BEFORE setting isTransitioning
        transitionType = type
        updateCounter += 1
        
        // Add a longer delay to ensure everything is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                // Signal transition start
                self.isTransitioning = true
                self.updateCounter += 1
                
                // Change level immediately after starting transition
                self.currentLevelIndex = nextLevelIndex
            }
            
            // Allow more time for the spring animation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
        
        // Retain current transition style before changing state
        let transitionStyle = currentLevel.transition
        // Set transition type first
        self.transitionType = transitionStyle
        self.updateCounter += 1
        
        // Use the same improved timing for regular transitions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                // Start transition
                self.isTransitioning = true
                
                // Determine destination during the transition
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
            }
            
            // Allow more time for the spring animation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
