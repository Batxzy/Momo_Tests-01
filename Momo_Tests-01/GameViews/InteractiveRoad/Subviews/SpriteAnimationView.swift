//
//  SpriteAnimationView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 02/05/25.
//

import SwiftUI

struct SpriteAnimationView: View {
    // MARK: - Properties
    let frameImages: [String]
    let frameDuration: Double
    
    @State private var currentFrameIndex = 0
    @State private var isAnimating = false
    @State private var timer: Timer? = nil
    
    @Binding private var isTransitioning: Bool
    
    // MARK: - Initialization
    
    init(
        frameImages: [String],
        frameDuration: Double = 0.2,
        isTransitioning: Binding<Bool> = .constant(false)
    ) {
        self.frameImages = frameImages
        self.frameDuration = frameDuration
        self._isTransitioning = isTransitioning
    }
    
    // MARK: - Body
    
    var body: some View {
        Image(frameImages[currentFrameIndex])
            .resizable()
            .scaledToFit()
            .onChange(of: isTransitioning) { _, newValue in
                if newValue {
                    startAnimation()
                }
            }
            .onAppear {
                if isTransitioning {
                    startAnimation()
                }
            }
            .onDisappear {
                stopAnimation()
            }
    }
    
    // MARK: - Animation Control
    
    private func startAnimation() {
        guard !isAnimating else { return }
        
        isAnimating = true
        
        // Create a repeating timer to advance frames
        timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { _ in
            // Calculate next frame index (wrapping around)
            let nextIndex = (currentFrameIndex + 1) % frameImages.count
            
            // If we're supposed to pause and we're about to loop to first frame
            if !isTransitioning && nextIndex == 0 {
                // Stop until next transition
                stopAnimation()
                return
            }
            
            // Otherwise advance to next frame
                currentFrameIndex = nextIndex
        }
    }
    
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
        isAnimating = false
    }
}

// MARK: - Convenience Extensions

extension Binding {
    static func constant(_ value: Value) -> Binding<Value> {
        Binding(get: { value }, set: { _ in })
    }
}

// MARK: - Preview

struct SpriteAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        SpriteAnimationView(
            frameImages: ["Interaccion 11 Momo caminando (3)", "Interaccion 11 Momo caminando (1)", "Interaccion 11 Momo caminando (2) 1", "Interaccion 11 Momo caminando (1)"],
            frameDuration: 0.15,
            isTransitioning: .constant(true)
        )
        .previewLayout(.sizeThatFits)
        .frame(width: 200, height: 300)
    }
}
