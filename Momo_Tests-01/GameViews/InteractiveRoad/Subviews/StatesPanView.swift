//
//  StatesPanView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 02/05/25.
//

import SwiftUI

// State model to represent each state in our story
struct StoryState: Identifiable {
    var id = UUID()
    let offsetPercentage: Double
    let dialogueInfo: DialogueInfo?
    
    var hasDialogue: Bool { dialogueInfo != nil }
}

struct DialogueInfo {
    let elementIndex: Int
    let dialogueImageName: String
    let position: CGPoint
    let size: CGSize 
}


// A class to manage story state progression
@Observable
class StoryStateManager {
    
    // State properties
    var offsetPercentage: Double = 0.0
    var currentStateIndex: Int = 0
    var isAnimating: Bool = false
    var showingDialogue: Bool = false
    var canAdvanceAfterDialogue: Bool = false
    var dialogueElementIndex: Int? = nil
    
    // Story state definitions
    let states: [StoryState] = [
        // State 0: Initial state, no dialogue
        StoryState(offsetPercentage: 0.0, dialogueInfo: nil),
        
        // State 1: First position with dialogue from element 0
        StoryState(offsetPercentage: 0.25, dialogueInfo: DialogueInfo(
            elementIndex: 0,
            dialogueImageName: "Momo",
            position: CGPoint(x: 0.5, y: 0.4),
            size: CGSize(width: 280, height: 200)
        )),
        
        // State 2: Second position, no dialogue
        StoryState(offsetPercentage: 0.60, dialogueInfo: nil),
        
        // State 3: Final position with dialogue from element 2
        StoryState(offsetPercentage: 1.0, dialogueInfo: DialogueInfo(
            elementIndex: 2,
            dialogueImageName: "Momo",
            position: CGPoint(x: 0.5, y: 0.4),
            size: CGSize(width: 280, height: 200)
        ))
    ]
    
    // Animation constants
    let animationDuration: Double = 4.0
    private var dialogueTimer: Timer?
    
    // Returns the current state
    var currentState: StoryState {
        states[currentStateIndex]
    }
    
    // Determines if a specific element is interactive in the current state
    func isElementInteractive(_ elementIndex: Int) -> Bool {
        guard currentState.hasDialogue, !showingDialogue else { return false }
        return currentState.dialogueInfo?.elementIndex == elementIndex
    }
    
    // Handle background tap for state progression
    func handleBackgroundTap() {
        // If showing dialogue and can advance, hide it
        if showingDialogue && canAdvanceAfterDialogue {
            hideDialogue()
            return
        }
        
        // If showing dialogue but not ready to advance, do nothing
        if showingDialogue && !canAdvanceAfterDialogue {
            return
        }
        
        // Otherwise, try to advance to the next state
        if !isAnimating {
            advanceToNextState()
        } else {
            print("🚫 Animation in progress, tap ignored")
        }
    }
    
    // Handle element taps that might trigger dialogue
    func handleElementTap(elementIndex: Int) {
        // Only proceed if this element should trigger dialogue
        guard !showingDialogue &&
              currentState.hasDialogue &&
              currentState.dialogueInfo?.elementIndex == elementIndex else {
            return
        }
        
        showDialogue(elementIndex: elementIndex)
    }
    
    // Show dialogue with a timer for progression
    private func showDialogue(elementIndex: Int) {
        showingDialogue = true
        dialogueElementIndex = elementIndex
        canAdvanceAfterDialogue = false
        
        // Start timer to enable advancement after delay
        dialogueTimer?.invalidate()
        dialogueTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.canAdvanceAfterDialogue = true
            print("⏱️ Dialogue timer completed - ready to advance")
        }
    }
    
    // Hide dialogue and clean up
    private func hideDialogue() {
        dialogueTimer?.invalidate()
        dialogueTimer = nil
        showingDialogue = false
        dialogueElementIndex = nil
        canAdvanceAfterDialogue = false
    }
    
    // Advance to the next state with animation
    private func advanceToNextState() {
        let lastStateIndex = states.count - 1
        guard currentStateIndex < lastStateIndex else {
            print("🏁 Already at the last state")
            return
        }
        
        isAnimating = true
        let nextStateIndex = currentStateIndex + 1
        let targetState = states[nextStateIndex]
        
        print("⏩ Advancing to state \(nextStateIndex)")
        
        // Update state index first
        currentStateIndex = nextStateIndex
        
        // Start animation of the offset
        withAnimation(.easeInOut(duration: animationDuration)) {
            offsetPercentage = targetState.offsetPercentage
        }
        
        // Schedule the animation lock release
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            self?.isAnimating = false
            print("✅ Animation complete")
        }
    }
    
    // Clean up any resources when the manager is deinitialized
    deinit {
        dialogueTimer?.invalidate()
    }
}
