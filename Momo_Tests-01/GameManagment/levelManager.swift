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
    
    // Add debug state to track what's happening
    var lastActionLog: String = ""
    
    // Add a direct trigger for UI updates
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
    
    // For debugging purposes - directly trigger transitions
    func debugTriggerTransition(_ type: LevelTransition) {
        print("DEBUG: Manually triggering \(type) transition")
        startTransition(transition: type) {
            // Do nothing in completion
            print("DEBUG: Transition midpoint reached")
        }
    }
    
    func completeCurrentLevel() {
        lastActionLog = "Completing level: \(currentLevel.name)"
        print("Completing level: \(currentLevel.name)")

        guard currentLevelIndex < chapters[currentChapterIndex].levels.count else {
            return
        }
        
        chapters[currentChapterIndex].levels[currentLevelIndex].isCompleted = true
        
        if hasNextLevelInCurrentChapter {
            moveToNextLevel()
        } else if hasNextChapter {
            moveToNextChapter()
        } else {
            handleGameCompletion()
        }
    }
    
    func moveToNextLevel() {
        // Safety check: ensure next level exists
        guard currentLevelIndex + 1 < currentChapter.levels.count else {
            return
        }
        
        // Capture the transition style from the current level
        let transitionStyle = currentChapter.levels[currentLevelIndex].transition
        lastActionLog = "Moving to next level with \(transitionStyle) transition"
        print("Moving to next level with \(transitionStyle) transition")
        
        // Apply transition animation and update level
        startTransition(transition: transitionStyle) {
            self.currentLevelIndex += 1
        }
    }
    
    func moveToNextChapter() {
        guard currentChapterIndex + 1 < chapters.count else {
            return
        }
        chapters[currentChapterIndex + 1].isUnlocked = true
        
        let transitionStyle = currentChapter.levels.last?.transition ?? .fade
        lastActionLog = "Moving to next chapter with \(transitionStyle) transition"
        print("Moving to next chapter with \(transitionStyle) transition")
       
        startTransition(transition: transitionStyle) {
            self.currentChapterIndex += 1
            self.currentLevelIndex = 0
        }
    }
    
    private func startTransition(transition: LevelTransition, completion: @escaping () -> Void) {
        print("⭐ STARTING TRANSITION: \(transition)")
        
        // Force update on main thread
        DispatchQueue.main.async {
            // First update the state
            self.isTransitioning = true
            self.transitionType = transition
            self.updateCounter += 1 // Force refresh of observers
            
            print("Set transition state: TRUE, type: \(String(describing: self.transitionType))")
            
            // Handle transition timing
            let duration = transition.duration
            
            // Phase 2: Midpoint - apply the completion callback
            DispatchQueue.main.asyncAfter(deadline: .now() + (duration * 0.5)) {
                // Apply state changes at transition midpoint
                completion()
                self.updateCounter += 1 // Force refresh
                print("Transition midpoint reached, applying completion")
                
                // Phase 3: Finish transition
                DispatchQueue.main.asyncAfter(deadline: .now() + (duration * 0.6)) {
                    // Reset transition state
                    self.isTransitioning = false
                    self.transitionType = nil
                    self.updateCounter += 1 // Force refresh
                    print("Transition complete, resetting state")
                }
            }
        }
    }
    
    func checkWinCondition(scrollPosition: ScrollPosition? = nil, minigameCompleted: String? = nil) -> Bool {
        switch currentLevel.winCondition {
        case .completeMinigame(let id):
            return minigameCompleted == id
        case .custom(let condition):
            return condition()
        }
    }
}
