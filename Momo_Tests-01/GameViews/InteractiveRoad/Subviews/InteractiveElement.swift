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
    
    //en realacion a la imagen grande
    let position: CGPoint
    
    //ancho de la imagen grande
    let imageWidth: CGFloat
    
    //lagro del frame contenedor
    let frameHeight: CGFloat
    
    
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
                        .padding(padding)
                        .clipped()
                }
            )
            
            .position(
                x: imageWidth * position.x,
                y: frameHeight * position.y
            )
            .onTapGesture {
                if isInteractive {
                    onTap(elementIndex)
                }
            }
    }
}

struct DialogueViewWide: View {
    // Content properties
    let imageName: String
    let position: CGPoint
    let size: CGSize
    let canAdvance: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
            .frame(width: size.width, height: size.height)
            .overlay(
                VStack {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                    
                    if canAdvance {
                        Text("Tap to continue")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 8)
                    } else {
                        HStack(spacing: 4) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Please wait...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 8)
                    }
                }
            )
            .position(x: position.x, y: position.y)
    }
}

#Preview {
    InteractiveElementView(imageName: "Reason", position: CGPoint(x: 0.5, y: 0.5), imageWidth: 233, frameHeight: 234, elementIndex: 1, isInteractive: true) { Int in
        print("hi")
    }
}
