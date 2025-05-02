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


import SwiftUI

@Observable
class StoryStateManager {
    // MARK: - State Properties
    var offsetPercentage: Double = 0.0
    var currentStateIndex: Int = 0 {
        didSet {
            // Keep print statement for debugging state transitions
            if currentStateIndex != oldValue {
                printStateTransition(from: oldValue, to: currentStateIndex)
            }
        }
    }

    var isAnimating: Bool = false // True during state transition animation

    // New state flags for interaction modes
    var isWaitingForElementTap: Bool = false // True if current state requires an element tap
    var isDisplayingDialogue: Bool = false // True if the dialogue overlay is currently visible
    var currentDialogueInfo: DialogueInfo? = nil // Holds info for the view when dialogue is active

    // MARK: - Configuration
    let animationDuration: Double = 4.0 // Duration of the panning animation
    let dialogueAdvanceDelay: Double = 3.0 // How long dialogue stays visible (changed from 5 to use existing var)
    private var dialogueTimer: Timer?
    
    // MARK: - Story States
    let states: [StoryState] = [
       // State 0: Initial state, no dialogue
       StoryState(offsetPercentage: 0.0, dialogueInfo: nil),

       // State 1: Needs tap on element 0 to show dialogue image in top area
       StoryState(offsetPercentage: 0.25, dialogueInfo: DialogueInfo(
           elementIndex: 0, // Tap element with index 0
           dialogueImageName: "Reason" // Image for top area
           // No position/size needed here
       )),

       // State 2: Second position, no dialogue
       StoryState(offsetPercentage: 0.60, dialogueInfo: nil),

       // State 3: Needs tap on element 2 to show dialogue image in top area
       StoryState(offsetPercentage: 1.0, dialogueInfo: DialogueInfo(
           elementIndex: 2, // Tap element with index 2
           dialogueImageName: "Reason" // Image for top area
           // No position/size needed here
       ))
       ]
    
    // MARK: - Initialization
        init() {
            print("🔄 StoryStateManager initialized at state \(currentStateIndex)")
            // Check if the initial state requires an element tap
            setupInteractionForCurrentState()
        }

        // MARK: - Computed Properties
        var currentState: StoryState {
            // Ensure index is valid, default to first state if not
            guard states.indices.contains(currentStateIndex) else { return states[0] }
            return states[currentStateIndex]
        }

        // MARK: - Interaction Logic

        /// Determines if a specific element should visually indicate interactivity.
        func isElementInteractive(_ elementIndex: Int) -> Bool {
            // Element is interactive ONLY if we are waiting for a tap AND it's the correct element
            return isWaitingForElementTap && currentState.dialogueInfo?.elementIndex == elementIndex
        }

        /// Called when an interactive element in the scene is tapped.
        func handleElementTap(elementIndex: Int) {
            print("👆 Element \(elementIndex) tapped")

            // Only handle tap if we are waiting for one and it's the correct element
            guard isWaitingForElementTap,
                  let dialogueInfo = currentState.dialogueInfo,
                  dialogueInfo.elementIndex == elementIndex else {
                print("🚫 Tap ignored (not waiting for this element or not waiting at all)")
                return
            }

            print("🎯 Element \(elementIndex) triggered dialogue")
            isWaitingForElementTap = false // No longer waiting for the tap for *this* state
            showDialogue(info: dialogueInfo)
        }

        /// Called when the background (e.g., a TapOverlayView) is tapped.
        func handleBackgroundTap() {
            print("🌍 Background tapped")

            // Ignore taps if animating
            if isAnimating {
                print("🚫 Animation in progress - background tap ignored")
                return
            }
            // Ignore taps if waiting for a specific element tap
            if isWaitingForElementTap {
                print("🚫 Waiting for element tap - background tap ignored. Please tap the interactive element.")
                // Optionally provide user feedback here (e.g., highlight element)
                return
            }
            // Ignore taps if a dialogue is currently being displayed
            if isDisplayingDialogue {
                print("🚫 Dialogue showing - background tap ignored")
                return
            }

            // If none of the above conditions are met, it's safe to advance state
            print("✅ Background tap accepted. Advancing state.")
            advanceToNextState()
        }

        // MARK: - Dialogue Handling

        /// Shows the dialogue overlay and starts the timer.
        private func showDialogue(info: DialogueInfo) {
            isDisplayingDialogue = true
            currentDialogueInfo = info // Make info available for the DialogueView
            print("🗨️ Showing dialogue for element \(info.elementIndex)")

            // Invalidate any existing timer and start a new one
            dialogueTimer?.invalidate()
            dialogueTimer = Timer.scheduledTimer(withTimeInterval: dialogueAdvanceDelay, repeats: false) { [weak self] _ in
                // When timer fires, hide the dialogue
                self?.hideDialogue()
            }
        }

        /// Hides the dialogue overlay and allows background taps again.
        private func hideDialogue() {
            dialogueTimer?.invalidate() // Ensure timer is stopped
            dialogueTimer = nil
            isDisplayingDialogue = false
            currentDialogueInfo = nil // Clear info
            print("🗨️ Dialogue finished. Ready for background tap to advance.")
            // The state is now ready for the next background tap because
            // isWaitingForElementTap is false (set in handleElementTap)
            // and isDisplayingDialogue is now false.
        }

        // MARK: - State Advancement

        /// Advances the story to the next state if possible.
        private func advanceToNextState() {
            let lastStateIndex = states.count - 1
            guard currentStateIndex < lastStateIndex else {
                print("🏁 Already at last state (\(lastStateIndex))")
                return
            }
            // Prevent advancing if already animating (safety check)
            guard !isAnimating else {
                 print("🚫 Already animating - advanceToNextState call ignored")
                 return
            }


            // --- Animation Start ---
            isAnimating = true
            let nextStateIndex = currentStateIndex + 1

            // Update state index *before* animation starts
            // The didSet observer will print the transition message
            currentStateIndex = nextStateIndex

            // Perform the visual animation (e.g., panning)
            withAnimation(.easeInOut(duration: animationDuration)) {
                offsetPercentage = currentState.offsetPercentage // Use the new state's offset
            }

            // --- Animation End Callback ---
            // Schedule actions to happen *after* the animation visually completes
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) { [weak self] in
                guard let self = self else { return }

                self.isAnimating = false // Mark animation as complete
                print("✅ Animation to state \(self.currentStateIndex) completed")

                // Setup interaction logic for the *new* state we just arrived at
                self.setupInteractionForCurrentState()
            }
        }

        /// Sets up the interaction mode based on the current state's properties.
        /// Call this after initialization and after each state transition animation completes.
        private func setupInteractionForCurrentState() {
            if currentState.hasDialogue {
                // This new state requires an element tap before advancing again
                isWaitingForElementTap = true
                isDisplayingDialogue = false // Ensure dialogue isn't shown yet
                currentDialogueInfo = nil // Ensure no stale dialogue info
                print("⏳ State \(currentStateIndex) requires element \(currentState.dialogueInfo?.elementIndex ?? -1) tap.")
            } else {
                // This new state allows direct background tap to advance
                isWaitingForElementTap = false
                isDisplayingDialogue = false
                currentDialogueInfo = nil
                print("✅ State \(currentStateIndex) allows background tap to advance.")
            }
        }


        // MARK: - Simple Debug Functions

        /// Print a clear state transition message
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

        deinit {
            dialogueTimer?.invalidate() // Clean up timer if the manager is destroyed
            print("🗑️ StoryStateManager deinitialized")
        }
}
