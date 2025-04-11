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
        // Trigger completion animation or navigate to end-game screen
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
    
    func completeCurrentLevel() {

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
       
        startTransition(transition: transitionStyle) {
                self.currentChapterIndex += 1
                self.currentLevelIndex = 0
            }
    }
    
    private func startTransition(transition: LevelTransition, completion: @escaping () -> Void) {
        isTransitioning = true
        transitionType = transition
        
        // Schedule the completion to happen after the transition duration
        Task {
            // Phase 1: Wait for transition entrance animation to finish
            try? await Task.sleep(for: .seconds(transition.duration * 0.5))
            
            await MainActor.run {
                // Phase 2: Apply state changes at transition midpoint
                completion()
                
                // Phase 3: Finish transition with slight delay
                Task {
                    // Give more time for the exit animation
                    try? await Task.sleep(for: .seconds(transition.duration * 0.6))
                    
                    await MainActor.run {
                        // Reset transition state
                        isTransitioning = false
                        transitionType = nil
                    }
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
