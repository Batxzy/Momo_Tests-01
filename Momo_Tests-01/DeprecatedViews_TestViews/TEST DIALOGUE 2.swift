//
//  DialogueView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI
import AnimateText

import SwiftUI
import AnimateText

struct DialogueView1: View {
    // MARK: - Properties
    @Environment(LevelManager.self) private var levelManager
    
    @State private var didTap: Bool = false
    @State private var animationCompleted: Bool = false
    
    var dialogueText: String
    var illustrationImage: Image
    
    private let illustrationHeight: CGFloat = 530
    private let illustrationWidth: CGFloat = 334
    
    private let dialogueHeight: CGFloat = 170
    private let dialogueWidth: CGFloat = 334
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 30) {
                // Illustration
                illustrationImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: illustrationWidth, height: illustrationHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Dialogue box with strict containment
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white)
                        .frame(width: dialogueWidth, height: dialogueHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(animationCompleted ? Color.blue.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    
                    // Text container with hard clipping
                    StrictlyContainedAnimatedText(
                        text: dialogueText,
                        containerWidth: dialogueWidth - 40,
                        containerHeight: dialogueHeight - 40,
                        onComplete: { animationCompleted = true }
                    )
                    .frame(width: dialogueWidth - 40, height: dialogueHeight - 40)
                    .clipShape(Rectangle())
                    
                    // Indicator
                    if animationCompleted {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "arrow.forward.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.blue)
                                    .symbolEffect(.pulse)
                                    .padding(.trailing, 16)
                                    .padding(.bottom, 12)
                            }
                        }
                        .frame(width: dialogueWidth, height: dialogueHeight)
                    }
                }
                .frame(width: dialogueWidth, height: dialogueHeight)
                .contentShape(Rectangle())
                .onTapGesture {
                    if animationCompleted && !didTap {
                        didTap = true
                        levelManager.completeLevel()
                    }
                }
            }
        }
    }
}

struct StrictlyContainedAnimatedText: View {
    @State private var animatedText: String = ""
    let text: String
    let containerWidth: CGFloat
    let containerHeight: CGFloat
    let onComplete: () -> Void
    
    var body: some View {
        // Base container with strict bounds
        ZStack {
            // Hard bounding box
            Rectangle()
                .fill(Color.clear)
                .frame(width: containerWidth, height: containerHeight)
            
            // Text rendering with strict containment
            ScrollView {
                AnimateText<ATTopBottomEffect>($animatedText, type: .words)
                    .font(.system(size: 26, weight: .medium))
                    .fontWidth(.compressed) // iOS 16+ modern text compression
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: containerWidth - 16, height: containerHeight - 16)
            }
            .scrollDisabled(true) // Modern way to disable scrolling while using ScrollView for containment
            .frame(width: containerWidth, height: containerHeight)
            .clipShape(Rectangle())
        }
        .frame(width: containerWidth, height: containerHeight)
        .clipped() // Triple enforce clipping
        .onAppear {
            // Start animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animatedText = text
                
                // Calculate completion time based on word count
                let wordCount = text.components(separatedBy: " ").count
                let estimatedDuration = Double(wordCount) * 0.15 + 0.3
                
                DispatchQueue.main.asyncAfter(deadline: .now() + estimatedDuration) {
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    DialogueView1(
        dialogueText: "DSFDSFSDFDSFSDFDSFDSF \nDSFDSFSDFSDFDSFSFDS?",
        illustrationImage: Image("rectangle33")
    )
    .environment(LevelManager())
}
