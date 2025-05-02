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


import SwiftUI

@Observable
class StoryStateManager {
    // MARK: - State Properties
    var offsetPercentage: Double = 0.0
    var currentStateIndex: Int = 0 {
        didSet {
            if currentStateIndex != oldValue {
                printStateTransition(from: oldValue, to: currentStateIndex)
            }
        }
    }
    
    var isAnimating: Bool = false
    
    var showingDialogue: Bool = false
    var canAdvanceAfterDialogue: Bool = false
    var dialogueElementIndex: Int? = nil
    
    // MARK: - Configuration
    let animationDuration: Double = 4.0
    let dialogueAdvanceDelay: Double = 3.0
    private var dialogueTimer: Timer?
    
    // MARK: - Story States
    let states: [StoryState] = [
        // State 0: Initial state, no dialogue
        StoryState(offsetPercentage: 0.0, dialogueInfo: nil),
        
        // State 1: First position with dialogue from element 0
        StoryState(offsetPercentage: 0.25, dialogueInfo: nil),
        
        // State 2: Second position, no dialogue
        StoryState(offsetPercentage: 0.60, dialogueInfo: nil),
        
        // State 3: Final position with dialogue from element 2
        StoryState(offsetPercentage: 1.0, dialogueInfo: nil)
    ]
    
    // MARK: - Initialization
    init() {
        print("🔄 StoryStateManager initialized at state \(currentStateIndex)")
    }
    
    // MARK: - Computed Properties
    var currentState: StoryState {
        states[currentStateIndex]
    }
    
    // MARK: - Interaction Logic
    func isElementInteractive(_ elementIndex: Int) -> Bool {
        guard currentState.hasDialogue, !showingDialogue else { return false }
        return currentState.dialogueInfo?.elementIndex == elementIndex
    }
    
    func handleElementTap(elementIndex: Int) {
        print("👆 Element \(elementIndex) tapped")
        
        guard !showingDialogue &&
              currentState.hasDialogue &&
              currentState.dialogueInfo?.elementIndex == elementIndex else {
            return
        }
        
        print("🎯 Element \(elementIndex) triggered dialogue")
        showDialogue(elementIndex: elementIndex)
    }
    
    func handleBackgroundTap() {
        if showingDialogue && canAdvanceAfterDialogue {
            hideDialogue()
            
            if !currentState.hasDialogue {
                tryAdvanceToNextState()
            }
            return
        }
        
        if showingDialogue && !canAdvanceAfterDialogue {
            print("⏳ Please wait...")
            return
        }
        
        if currentState.hasDialogue && !showingDialogue {
            print("👆 Please tap a highlighted element first")
            return
        }
        
        tryAdvanceToNextState()
    }
    
    private func tryAdvanceToNextState() {
        if !isAnimating {
            advanceToNextState()
        } else {
            print("🚫 Animation in progress - tap ignored")
        }
    }
    
    private func showDialogue(elementIndex: Int) {
        showingDialogue = true
        dialogueElementIndex = elementIndex
        canAdvanceAfterDialogue = false
        
        print("🗨️ Showing dialogue for element \(elementIndex)")
        
        dialogueTimer?.invalidate()
        dialogueTimer = Timer.scheduledTimer(withTimeInterval: dialogueAdvanceDelay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            self.canAdvanceAfterDialogue = true
            print("⏱️ Ready for next tap")
        }
    }
    
    private func hideDialogue() {
        dialogueTimer?.invalidate()
        dialogueTimer = nil
        showingDialogue = false
        dialogueElementIndex = nil
        canAdvanceAfterDialogue = false
        
        print("🗨️ Dialogue dismissed")
    }
    
    private func advanceToNextState() {
        let lastStateIndex = states.count - 1
        guard currentStateIndex < lastStateIndex else {
            print("🏁 Already at last state (\(lastStateIndex))")
            return
        }
        
        isAnimating = true
        let nextStateIndex = currentStateIndex + 1
        let targetState = states[nextStateIndex]
        
        currentStateIndex = nextStateIndex
        
        withAnimation(.easeInOut(duration: animationDuration)) {
            offsetPercentage = targetState.offsetPercentage
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            guard let self = self else { return }
            
            self.isAnimating = false
            print("✅ Animation for state \(self.currentStateIndex) completed")
        }
    }
    
    // MARK: - Simple Debug Functions
    
    /// Print a clear state transition message
    private func printStateTransition(from oldState: Int, to newState: Int) {
        print("------------------------")
        print("🔀 STATE CHANGE: \(oldState) → \(newState)")
        print("📊 State \(newState) of \(states.count-1)")
        print("🔢 Offset: \(states[newState].offsetPercentage)")
        print("------------------------")
    }
    
    deinit {
        dialogueTimer?.invalidate()
    }
}
