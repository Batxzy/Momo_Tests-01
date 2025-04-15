import SwiftUI

struct ImageChangeView: View {

    let initialImage: Image
    let finalImage: Image
    let onComplete: () -> Void

    @State private var currentImage: Image
    
    @State private var wasClicked: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    init(initialImage: Image, finalImage: Image, onComplete: @escaping () -> Void) {
        self.initialImage = initialImage
        self.finalImage = finalImage
        self.onComplete = onComplete
        _currentImage = State(initialValue: initialImage)
    }

    var body: some View {
        VStack {
            Spacer()
            // Display the currentImage directly
            currentImage
                .resizable()
                .scaledToFill() // Use scaledToFill as you had
                .frame(width: 343, height: 673)
                .clipped() // Keep clipped as you had
                .padding()
                .onTapGesture {
                    handleTap()
                }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black) // Keep black background
        .transition(.opacity.animation(.easeInOut)) // Keep transition
    }

    private func handleTap() {
        // Only proceed if it hasn't been clicked yet
        guard !wasClicked else { return }

        wasClicked = true
        // Change the state to the final Image object
        currentImage = finalImage

        // Schedule the completion callback after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // 1-second delay
            onComplete()
        }
    }
}

// --- Corrected Preview ---
#Preview {
    // Create actual Image instances for the preview
    ImageChangeView(
        initialImage: Image( "rectangle33"), // Example initial image
        finalImage: Image("rectangle35"), // Example final image
        onComplete: {
            print("Preview ImageChangeView completed!")
        } // Provide a closure for onComplete
    )
}
