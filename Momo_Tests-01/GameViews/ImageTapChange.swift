//
//  ImageTapChange.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 08/05/25.
//

import SwiftUI

struct ImageTapChange: View {
    //MARK: - variables y setup
    @Environment(LevelManager.self) private var levelManager
    @State private var didTap: Bool = false
    
    // State for the currently displayed image
    @State private var currentImage: Image
    @State private var imageIdentifier: UUID

    private var initialIllustration: Image
    private var nextIllustration: Image
    private var delayDuration: Double

        
    private let illustrationHeight: CGFloat = 689
    private let illustrationWidth: CGFloat = 330
    
    // Initializer to set up both images
    init(initialIllustration: Image, nextIllustration: Image, delay: Double = 0.0) {
            self.initialIllustration = initialIllustration
            self.nextIllustration = nextIllustration
            self._currentImage = State(initialValue: initialIllustration)
            self._imageIdentifier = State(initialValue: UUID()) // Initialize the identifier
            self.delayDuration = delay
        }
    
    var body: some View {
            ZStack {
                Color.white
                    .ignoresSafeArea(edges: .all)
                
                currentImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: illustrationWidth, height: illustrationHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
                    .id(imageIdentifier)
                    .transition(.opacity)
                    .onTapGesture {
                        guard !didTap else { return }
                        
                        didTap = true
                        
                        
                            withAnimation(.easeIn(duration: 0.5)) {
                                currentImage = nextIllustration
                                imageIdentifier = UUID()
                            }
                        DispatchQueue.main.asyncAfter(deadline: .now() + delayDuration) {
                            levelManager.completeLevel()
                        }
                    }
            }
        }
    }

#Preview {
    
    ImageTapChange(initialIllustration: Image("Reason"), nextIllustration: Image("rectangle33"), delay: 2)
        .environment(LevelManager())
}
