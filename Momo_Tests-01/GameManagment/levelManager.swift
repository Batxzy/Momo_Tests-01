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
    
    // Add state for transitions between views
    var previousLevelContent: AnyView? = nil
    var showPreviousView: Bool = false
    
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
    
    // For debugging purposes - test transitions between views
    func debugTriggerTransition(_ type: LevelTransition) {
        print("DEBUG: Manually triggering \(type) transition between views")
        
        // Store current view before transition
        let currentView = currentLevel.content
        
        // Figure out which level to transition to
        let nextLevelIndex = (currentLevelIndex < currentChapter.levels.count - 1) ? 
                             currentLevelIndex + 1 : 0
        
        DispatchQueue.main.async {
            // Set up for transition
            self.previousLevelContent = currentView
            self.showPreviousView = true
            self.transitionType = type
            self.isTransitioning = true
            self.updateCounter += 1
            
            print("DEBUG TRANSITION: Started \(type) between views")
            
            // First phase - fade to black
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                // Change to next level in middle of transition
                self.showPreviousView = false
                self.currentLevelIndex = nextLevelIndex
                self.updateCounter += 1
                
                // Second phase - fade from black to new view
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    // Complete transition
                    self.isTransitioning = false
                    self.transitionType = nil
                    self.previousLevelContent = nil
                    self.updateCounter += 1
                    
                    print("DEBUG TRANSITION: Completed to level \(nextLevelIndex)")
                }
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
        
        // Store current view before changing
        let currentView = currentLevel.content
        
        // Figure out where we're going
        if hasNextLevelInCurrentChapter {
            let transitionStyle = currentChapter.levels[currentLevelIndex].transition
            performViewTransition(from: currentView, 
                                 using: transitionStyle) {
                self.currentLevelIndex += 1
            }
        } else if hasNextChapter {
            let transitionStyle = currentChapter.levels.last?.transition ?? .fade
            performViewTransition(from: currentView, 
                                 using: transitionStyle) {
                self.currentChapterIndex += 1
                self.currentLevelIndex = 0
            }
        } else {
            handleGameCompletion()
        }
    }
    
    private func handleGameCompletion() {
        print("All chapters and levels completed!")
        lastActionLog = "Game completed!"
    }
    
    private func performViewTransition(from previousView: AnyView, 
                                      using transition: LevelTransition, 
                                      completion: @escaping () -> Void) {
        print("⭐ Starting view transition with \(transition)")
        
        DispatchQueue.main.async {
            // Set up transition
            self.previousLevelContent = previousView
            self.showPreviousView = true
            self.transitionType = transition
            self.isTransitioning = true
            self.updateCounter += 1
            
            // First phase - fade to transition (black)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                // Apply level change at transition midpoint
                self.showPreviousView = false
                completion()
                self.updateCounter += 1
                
                // Second phase - fade from transition to new view
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    // Complete transition
                    self.isTransitioning = false
                    self.transitionType = nil
                    self.previousLevelContent = nil
                    self.updateCounter += 1
                }
            }
        }
    }
    
    // Remove unused methods that don't handle view transitions properly
    func moveToNextLevel() {
        guard currentLevelIndex + 1 < currentChapter.levels.count else { return }
        
        let transitionStyle = currentChapter.levels[currentLevelIndex].transition
        let currentView = currentLevel.content
        
        performViewTransition(from: currentView, using: transitionStyle) {
            self.currentLevelIndex += 1
        }
    }
    
    func moveToNextChapter() {
        guard currentChapterIndex + 1 < chapters.count else { return }
        chapters[currentChapterIndex + 1].isUnlocked = true
        
        let transitionStyle = currentChapter.levels.last?.transition ?? .fade
        let currentView = currentLevel.content
        
        performViewTransition(from: currentView, using: transitionStyle) {
            self.currentChapterIndex += 1
            self.currentLevelIndex = 0
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
