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
}



// MARK: - State Manager

@Observable
class StoryStateManager {
    // MARK: - State Properties
    var offsetPercentage: Double = 0.0
    var currentStateIndex: Int = 0 {
        didSet { if currentStateIndex != oldValue { logStateTransition(from: oldValue) } }
    }
    
    // Interactive states with clear access levels
    private(set) var isAnimating = false
    private(set) var isWaitingForElementTap = false
    private(set) var isDisplayingDialogue = false
    private(set) var currentDialogueInfo: DialogueInfo? = nil
    
    // MARK: - Timing Configuration
    private let animationDuration: Double = 4.0
    private let dialogueDelay: Double = 3.0
    private let completionDelay: Double = 3.0
    
    // Completion callback
    var completionCallback: (() -> Void)?
    
    // MARK: - Timers
    private var dialogueTimer: Timer?
    private var completionTimer: Timer?
    
    // MARK: - Story Configuration
    
    /// Defines the progression of story states and their associated interactions
    let states: [StoryState] = [
        StoryState(offsetPercentage: 0.0, dialogueInfo: nil),
        StoryState(offsetPercentage: 0.25, dialogueInfo: DialogueInfo(elementIndex: 0, dialogueImageName: "Reason")),
        StoryState(offsetPercentage: 0.60, dialogueInfo: nil),
        StoryState(offsetPercentage: 1.0, dialogueInfo: DialogueInfo(elementIndex: 2, dialogueImageName: "Reason"))
    ]
    
    // MARK: - Computed Properties
    
    /// The current state in the story progression
    var currentState: StoryState {
        guard states.indices.contains(currentStateIndex) else { return states[0] }
        return states[currentStateIndex]
    }
    
    /// Whether we're at the final state of the story
    var isLastState: Bool {
        currentStateIndex == states.count - 1
    }
    
    // MARK: - Initialization
    
    init() {
        print("🔄 StoryStateManager initialized at state \(currentStateIndex)")
        setupInteractionForCurrentState()
    }
    
    // MARK: - Public Interface
    
    /// Determines if a specific element should be interactive in the current state
    func isElementInteractive(_ elementIndex: Int) -> Bool {
        isWaitingForElementTap && currentState.dialogueInfo?.elementIndex == elementIndex
    }
    
    /// Handles a tap on an interactive element
    func handleElementTap(elementIndex: Int) {
        print("👆 Element \(elementIndex) tapped")
        
        guard isWaitingForElementTap,
              let dialogueInfo = currentState.dialogueInfo,
              dialogueInfo.elementIndex == elementIndex else {
            print("🚫 Element tap ignored - not expecting this interaction")
            return
        }
        
        print("✅ Element \(elementIndex) tap accepted")
        isWaitingForElementTap = false
        showDialogue(info: dialogueInfo)
    }
    
    /// Handles a tap on the background
    func handleBackgroundTap() {
        print("🌍 Background tapped")
        
        guard !isAnimating && !isWaitingForElementTap && !isDisplayingDialogue else {
            print("🚫 Background tap ignored - not in correct state")
            return
        }
        
        print("✅ Background tap accepted")
        advanceToNextState()
    }
    
    // MARK: - Private Implementation
    
    /// Sets up the expected interaction for the current state
    private func setupInteractionForCurrentState() {
        // Reset state
        isWaitingForElementTap = false
        isDisplayingDialogue = false
        currentDialogueInfo = nil
        
        // Configure for current state
        if let dialogueInfo = currentState.dialogueInfo {
            isWaitingForElementTap = true
            print("⏳ Waiting for element \(dialogueInfo.elementIndex) tap")
        } else {
            print("⏳ Waiting for background tap")
        }
    }
    
    /// Advances to the next story state with animation
    private func advanceToNextState() {
        guard !isLastState else {
            print("🏁 Already at final state")
            return
        }
        
        isAnimating = true
        currentStateIndex += 1
        
        withAnimation(.easeInOut(duration: animationDuration)) {
            offsetPercentage = currentState.offsetPercentage
        }
        
        // Schedule state completion after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            guard let self = self else { return }
            self.isAnimating = false
            print("✅ Animation to state \(self.currentStateIndex) completed")
            self.setupInteractionForCurrentState()
            
            // Check for story completion if no element interaction is required
            if !self.isWaitingForElementTap {
                self.checkForCompletion()
            }
        }
    }
    
    /// Displays dialogue associated with an element
    private func showDialogue(info: DialogueInfo) {
        currentDialogueInfo = info
        
        withAnimation(.easeInOut) {
            isDisplayingDialogue = true
        }
        
        print("💬 Showing dialogue for element \(info.elementIndex)")
        
        // Schedule dialogue dismissal
        dialogueTimer?.invalidate()
        dialogueTimer = Timer.scheduledTimer(withTimeInterval: dialogueDelay, repeats: false) { [weak self] _ in
            self?.hideDialogue()
        }
    }
    
    /// Hides the current dialogue with animation
    private func hideDialogue() {
        dialogueTimer?.invalidate()
        dialogueTimer = nil
        
        guard isDisplayingDialogue else { return }
        
        withAnimation(.easeInOut) {
            isDisplayingDialogue = false
        }
        
        print("💬 Hiding dialogue")
        currentDialogueInfo = nil
        
        // Check for story completion after dialogue is dismissed
        checkForCompletion()
    }
    
    /// Checks if the story is complete and triggers the completion callback
    private func checkForCompletion() {
        guard isLastState && !isAnimating && !isDisplayingDialogue && !isWaitingForElementTap else {
            return
        }
        
        guard completionTimer == nil || !(completionTimer?.isValid ?? false) else {
            print("⏱️ Completion already scheduled")
            return
        }
        
        print("🏁 Story complete - scheduling completion callback in \(completionDelay)s")
        
        completionTimer = Timer.scheduledTimer(withTimeInterval: completionDelay, repeats: false) { [weak self] _ in
            print("✅ Executing completion callback")
            self?.completionCallback?()
        }
    }
    
    /// Logs state transitions for debugging
    private func logStateTransition(from oldState: Int) {
        print("🔄 State transition: \(oldState) → \(currentStateIndex)")
        print("   Offset: \(currentState.offsetPercentage)")
        print("   Has dialogue: \(currentState.hasDialogue)")
        
        if let info = currentState.dialogueInfo {
            print("   Dialogue element: \(info.elementIndex)")
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        dialogueTimer?.invalidate()
        completionTimer?.invalidate()
        print("🗑️ StoryStateManager released")
    }
}
