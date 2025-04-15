import SwiftUI

struct ImageChangeView: View {

    let initialImage: Image
    let finalImage: Image
    let onComplete: () -> Void

    @State private var currentImage: Image
    @State private var wasClicked: Bool = false

    init(initialImage: Image, finalImage: Image, onComplete: @escaping () -> Void) {
        self.initialImage = initialImage
        self.finalImage = finalImage
        self.onComplete = onComplete
        _currentImage = State(initialValue: initialImage)
    }

    private func handleTap() {
        guard !wasClicked else { return }
        wasClicked = true

        withAnimation(.linear) {
             currentImage = finalImage
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onComplete()
        }
    }
    
    var body: some View {
        VStack {
            currentImage
                .resizable()
                .scaledToFill()
                .frame(width: 343, height: 673)
                .clipped()
                .onTapGesture {
                    handleTap()
                }
        }
    }
}

#Preview {
    ImageChangeView(
        initialImage: Image("rectangle33"), // Use SF Symbols or asset names
        finalImage: Image("rectangle35"), // Use SF Symbols or asset names
        onComplete: {
            print("Preview ImageChangeView completed!")
        }
    )
}
