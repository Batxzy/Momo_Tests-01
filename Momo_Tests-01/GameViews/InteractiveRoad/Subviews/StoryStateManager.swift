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



@Observable
class StoryStateManager {
    // MARK: - State Properties
    var offsetPercentage: Double = 0.0
    var currentStateIndex: Int = 0 {
            didSet { if currentStateIndex != oldValue { logStateTransition(from: oldValue) } }
        }
    var isAnimating: Bool = false
    var isWaitingForElementTap: Bool = false
    var isDisplayingDialogue: Bool = false
    var currentDialogueInfo: DialogueInfo? = nil

    // MARK: - Configuration
    let animationDuration: Double = 4.0
    let dialogueAdvanceDelay: Double = 3.0
    let completionDelay: Double = 3.0 // Delay before calling levelManager.complete()

    // MARK: - Timers
    private var dialogueTimer: Timer?
    private var completionTimer: Timer? // Timer for final completion delay

    // MARK: - Story States (Example - use your actual states)
    let states: [StoryState] = [
        StoryState(offsetPercentage: 0.0, dialogueInfo: nil),
        StoryState(offsetPercentage: 0.25, dialogueInfo: DialogueInfo(elementIndex: 0, dialogueImageName: "Reason")),
        StoryState(offsetPercentage: 0.60, dialogueInfo: nil),
        StoryState(offsetPercentage: 1.0, dialogueInfo: DialogueInfo(elementIndex: 2, dialogueImageName: "Reason")) // Last state has dialogue
        // Example: If last state had no dialogue:
        // StoryState(offsetPercentage: 1.0, dialogueInfo: nil)
    ]

    // MARK: - Initialization
    init() {
            print("🔄 StoryStateManager initialized at state \(currentStateIndex)")
            setupInteractionForCurrentState()
        }
    
    var completionCallback: (() -> Void)?


    // MARK: - Computed Properties
    var currentState: StoryState {
        guard states.indices.contains(currentStateIndex) else { return states[0] }
        return states[currentStateIndex]
    }

    var isLastState: Bool {
        currentStateIndex == states.count - 1
    }

    // MARK: - Interaction Logic
    func isElementInteractive(_ elementIndex: Int) -> Bool {
        return isWaitingForElementTap && currentState.dialogueInfo?.elementIndex == elementIndex
    }
    
    func handleElementTap(elementIndex: Int) {
        print("👆 Element \(elementIndex) tapped")
        guard isWaitingForElementTap,
              let dialogueInfo = currentState.dialogueInfo,
              dialogueInfo.elementIndex == elementIndex else {
            print("🚫 Tap ignored (not waiting for this element or not waiting at all)")
            return
        }
        print("🎯 Element \(elementIndex) triggered dialogue")
        isWaitingForElementTap = false
        showDialogue(info: dialogueInfo)
    }
    
    func handleBackgroundTap() {
        print("🌍 Background tapped")
        if isAnimating { print("🚫 Animation in progress - background tap ignored"); return }
        if isWaitingForElementTap { print("🚫 Waiting for element tap - background tap ignored."); return }
        if isDisplayingDialogue { print("🚫 Dialogue showing - background tap ignored"); return }
        
        print("✅ Background tap accepted. Advancing state.")
        advanceToNextState()
    }
    
    // MARK: - Dialogue Handling
    private func showDialogue(info: DialogueInfo) {

        self.currentDialogueInfo = info
            print("🗨️ Preparing to show dialogue for element \(info.elementIndex)")

            withAnimation(.easeInOut) {
                self.isDisplayingDialogue = true
            }
            print("🗨️ Dialogue show animation triggered (isDisplayingDialogue = true).")

            dialogueTimer?.invalidate()
            dialogueTimer = Timer.scheduledTimer(withTimeInterval: dialogueAdvanceDelay, repeats: false) { [weak self] _ in
                 print("⏱️ Dialogue timer finished.")
                self?.hideDialogue()
            }
             print("⏱️ Dialogue auto-hide timer started (\(dialogueAdvanceDelay)s).")
        }
    
    private func hideDialogue() {
            // 1. Invalidate timer if it's still running (e.g., manual dismissal if implemented)
            dialogueTimer?.invalidate()
            dialogueTimer = nil

            // 2. Check if already hidden or hiding to prevent redundant animations/logic
            guard isDisplayingDialogue else {
                print("🚫 Dialogue already hidden or hiding. Ignoring hideDialogue call.")
                return
            }
             print("🗨️ Starting hide dialogue process...")

            // 3. Trigger the hide animation by changing the flag
            //    The view associated with `isDisplayingDialogue` will use its transition.
            withAnimation(.easeInOut) { // Consistent animation
                self.isDisplayingDialogue = false
            }
            print("🗨️ Dialogue hide animation triggered (isDisplayingDialogue = false).")

            // 4. Clean up the data state *after* initiating the animation.
            //    This ensures the DialogueViewWide still has access to `currentDialogueInfo`
            //    during its fade-out transition if the transition needs it.
            //    A slight delay might sometimes be needed if the transition relies heavily
            //    on the data *during* the animation, but often just setting it after `withAnimation` works.
            //    Let's try without delay first.
            // DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in // Optional small delay
                 self.currentDialogueInfo = nil
                 print("🧹 Dialogue data cleaned up (currentDialogueInfo = nil).")
            // }

            // 5. Check for completion now that the dialogue interaction is finished.
            checkAndTriggerCompletion()
        }
    
    // MARK: - State Advancement
    private func advanceToNextState() {
        guard !isLastState else { print("🏁 Already at last state (\(currentStateIndex))"); return }
        guard !isAnimating else { print("🚫 Already animating - advanceToNextState call ignored"); return }
        
        isAnimating = true
        let nextStateIndex = currentStateIndex + 1
        currentStateIndex = nextStateIndex
        
        withAnimation(.easeInOut(duration: animationDuration)) {
            offsetPercentage = currentState.offsetPercentage
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
            guard let self = self else { return }
            self.isAnimating = false
            print("✅ Animation to state \(self.currentStateIndex) completed")
            self.setupInteractionForCurrentState()
            
            if !self.isWaitingForElementTap {
                self.checkAndTriggerCompletion()
            }
        }
    }
    
    /// Sets up the interaction mode for the current state.
    private func setupInteractionForCurrentState() {
        if currentState.hasDialogue {
            isWaitingForElementTap = true
            isDisplayingDialogue = false
            currentDialogueInfo = nil
            print("⏳ State \(currentStateIndex) requires element \(currentState.dialogueInfo?.elementIndex ?? -1) tap.")
        } else {
            isWaitingForElementTap = false
            isDisplayingDialogue = false
            currentDialogueInfo = nil
            print("✅ State \(currentStateIndex) allows background tap to advance.")
        }
    }
    
    // MARK: - Completion Logic
    private func checkAndTriggerCompletion() {
        guard isLastState else { return }
        
        guard !isAnimating && !isDisplayingDialogue && !isWaitingForElementTap else {
            print("🏁 On last state, but waiting for pending actions.")
            return
        }
        
        guard completionTimer == nil || !(completionTimer?.isValid ?? false) else {
            print("🏁 Completion already scheduled.")
            return
        }
        
        print("🏁 Final state (\(currentStateIndex)) reached and actions complete. Scheduling level completion in \(completionDelay)s.")
        
        completionTimer = Timer.scheduledTimer(withTimeInterval: completionDelay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            print("⏱️ Completion delay finished. Calling completion callback.")
            self.completionCallback?() // Call the callback instead of directly invoking levelManager.completeLevel()
        }
    }
    
    // MARK: - Debug Functions
    private func printStateTransition(from oldState: Int, to newState: Int) {
         guard states.indices.contains(newState) else { return }
         print("------------------------")
         print("🔀 STATE CHANGE: \(oldState) → \(newState)")
         print("📊 State \(newState) of \(states.count - 1)")
         print("🔢 Offset: \(states[newState].offsetPercentage)")
         print("💬 Has Dialogue: \(states[newState].hasDialogue)")
         if let info = states[newState].dialogueInfo {
             print("  > Element Index: \(info.elementIndex)")
         }
         print("------------------------")
    }
    
    // MARK: - Cleanup
    deinit {
        dialogueTimer?.invalidate()
        completionTimer?.invalidate()
        print("🗑️ StoryStateManager deinitialized")
    }
}
