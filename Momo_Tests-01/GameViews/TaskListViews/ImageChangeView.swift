import SwiftUI

struct ImageChangeView: View {

    let initialImage: Image
    let finalImage: Image
    let onComplete: () -> Void

    @State private var wasClicked: Bool = false

    init(initialImage: Image, finalImage: Image, onComplete: @escaping () -> Void) {
        self.initialImage = initialImage
        self.finalImage = finalImage
        self.onComplete = onComplete
    }

    private func handleTap() {
        guard !wasClicked else { return }

        withAnimation(.easeInOut(duration: 0.8)) {
            wasClicked = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            onComplete()
        }
    }

    var body: some View {
        ZStack {
            Color.black
            .ignoresSafeArea()
            VStack(spacing: 30) {
                ZStack {
                    initialImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 343, height: 673)
                        .clipped()
                        .opacity(wasClicked ? 0 : 1)
                    
                    finalImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 343, height: 673)
                        .clipped()
                        .opacity(wasClicked ? 1 : 0)
                }
                
                Button {
                    handleTap()
                } label: {
                    Text("Siguiente")
                        .padding(15)
                        .background(.regularMaterial, in: Capsule())
                        
                }
                .disabled(wasClicked)
                .opacity(wasClicked ? 0 : 1)
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
