//
//  InteractiveElement.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 02/05/25.
//

import SwiftUI


struct InteractiveElementView: View {
    // Visual properties
    let imageName: String
    let position: CGPoint
    let imageWidth: CGFloat
    let frameHeight: CGFloat
    var backgroundColor: Color? = nil
    
    // Interactive properties
    let elementIndex: Int
    let isInteractive: Bool
    let onTap: (Int) -> Void
    
    // Layout constants
    private let elementWidth: CGFloat = 180
    private let elementHeight: CGFloat = 180
    private let cornerRadius: CGFloat = 12
    private let padding: CGFloat = 16
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.ultraThinMaterial)
            .frame(width: elementWidth, height: elementHeight)
            .overlay(
                VStack {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .background(backgroundColor ?? .clear)
                        .padding(padding)
                }
            )
            // Visual indicator for interactive elements
            .overlay(
                isInteractive ?
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.yellow, lineWidth: 2)
                        : nil
            )
            .animation(.easeInOut, value: isInteractive)
            .position(
                x: imageWidth * position.x,
                y: frameHeight * position.y
            )
            .onTapGesture {
                if isInteractive {
                    print("💥 Element tapped: \(elementIndex)")
                    onTap(elementIndex)
                }
            }
            .brightness(isInteractive ? 0.05 : 0)
    }
}


#Preview {
    InteractiveElementView(imageName: "Reason", position: CGPoint(x: 0.5, y: 0.5), imageWidth: 233, frameHeight: 234, elementIndex: 1, isInteractive: true) { Int in
        print("hi")
    }
}
