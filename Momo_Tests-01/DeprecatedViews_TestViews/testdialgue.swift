//
//  testdialgue.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 02/05/25.
//

import SwiftUI

class ImageHiderController: ObservableObject {
    // State to track if the image should be fully opaque (visible) or transparent (faded out)
    @Published var isImageOpaque: Bool = true
    @Published var showCompletionMessage: Bool = false
    // State to track if the hiding process is active (timer running)
    @Published var isHidingProcessActive: Bool = false

    private var hideTimer: Timer?

    // Method to start the timer to fade out the image
    func startHidingProcess() {
        // Only start if not already hiding and the image is still opaque
        guard !isHidingProcessActive && isImageOpaque else {
            print("Hiding process already active or image already faded.")
            return
        }

        // Invalidate any existing timer before starting a new one
        hideTimer?.invalidate()
        isHidingProcessActive = true // Mark process as active
        showCompletionMessage = false // Ensure completion message is hidden initially
        print("Starting timer to fade out image...")

        // Start a 2-second timer (adjust duration as needed)
        hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            // Ensure UI updates are on the main thread
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isImageOpaque = false       // Trigger fade-out by changing state
                self.showCompletionMessage = true // Show completion message
                self.isHidingProcessActive = false // Mark process as inactive
                print("Timer finished. Image Faded Out. Completion message shown.")
            }
        }
    }

    // Clean up the timer when the object is deinitialized
    deinit {
        hideTimer?.invalidate()
        print("ImageHiderController deinitialized, timer invalidated.")
    }
}


struct ContentView6: View {
    // Create and observe the state managed by ImageHiderController
    @StateObject private var imageHiderController = ImageHiderController()

    var body: some View {
        VStack(spacing: 20) {
            // Button to trigger the hide logic
            Button {
                imageHiderController.startHidingProcess()
            } label: {
                Text("Fade Out Image (after 2s delay)")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            // Disable the button while the timer is running or if image is already faded
            .disabled(imageHiderController.isHidingProcessActive || !imageHiderController.isImageOpaque)
            // Visually indicate disabled state
            .opacity(imageHiderController.isHidingProcessActive || !imageHiderController.isImageOpaque ? 0.5 : 1.0)
            // Add animation specifically to the opacity change of the button's disabled state
            .animation(.easeInOut, value: imageHiderController.isHidingProcessActive || !imageHiderController.isImageOpaque)


            // Image is always present, but its opacity changes
            Image(systemName: "photo.fill") // Using a system image for example
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.orange)
                 // Control opacity based on the state variable
                .opacity(imageHiderController.isImageOpaque ? 1.0 : 0.0)
                 // Animate the change in opacity
                .animation(.easeInOut(duration: 0.5), value: imageHiderController.isImageOpaque) // Smooth fade

            // Conditionally display the completion message
            // This still appears/disappears, but you could fade it too if needed
            if imageHiderController.showCompletionMessage {
                Text("Image faded successfully!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .transition(.opacity.animation(.easeInOut)) // Add transition with animation
            } else {
                 // Add a placeholder to maintain layout when message isn't shown
                 // Adjust height based on expected message height if needed
                 Text(" ") // Use an empty text or Spacer
                     .font(.headline)
                     .hidden() // Keeps space without drawing
            }


            Spacer() // Pushes content to the top
        }
        .padding()
        // Note: Global animations can sometimes interfere with more specific ones.
        // Applying animations directly to modifiers (like .opacity or .transition)
        // as done above is often more reliable for controlling specific effects.
    }
}


// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView6()
    }
}
