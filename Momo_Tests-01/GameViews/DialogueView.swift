//
//  DialogueView.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//
struct ContinuousShakeEffect: ViewModifier {
    let time: Double
    let intensity: CGFloat
    let speed: Double

    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle(degrees: sin(time * .pi * speed) * intensity))
            .offset(
                x: cos(time * .pi * speed * 0.88) * intensity * 0.6,
                y: sin(time * .pi * speed * 1.15) * intensity * 0.6
            )
    }
}


import SwiftUI
import AnimateText

struct DialogueView: View {

//MARK: - Variables y cosos del state
    @Environment(LevelManager.self) private var levelManager
               
        @State private var didTap: Bool = false
        @State private var animationCompleted: Bool = false
           
        var dialogueTexts: [String]
        var illustrationImage: Image
        var textFont: Font
        
        // New controls
        var textAppearDelay: Double = 0.3
        var textLineSpacing: CGFloat = 8.0

        // Controls for constant shake
        var enableConstantShake: Bool = false
        var constantShakeIntensity: CGFloat = 1.5
        var constantShakeSpeed: Double = 2.0

        private let illustrationHeight: CGFloat = 530
        private let illustrationWidth: CGFloat = 334
           
        private let dialogueHeight: CGFloat = 170
        private let dialogueWidth: CGFloat = 334
            
        private func handleTap() {
            guard animationCompleted && !didTap else { return }
               
            didTap = true
            levelManager.completeLevel()
        }
//MARK: - view
    var body: some View {
           ZStack {
               Color.white
                   .ignoresSafeArea()
               
               VStack(alignment: .center, spacing: 30) {
                   illustrationImage
                       .resizable()
                       .scaledToFill()
                       .frame(width: illustrationWidth, height: illustrationHeight)
                       .clipShape(RoundedRectangle(cornerRadius: 20))
                   
                   VStack(alignment: .center) {
                          DialogueTextView(
                              texts: dialogueTexts,
                              textFont: textFont,
                              textAppearDelay: textAppearDelay,
                              textLineSpacing: textLineSpacing,
                              enableConstantShake: enableConstantShake,
                              constantShakeIntensity: constantShakeIntensity,
                              constantShakeSpeed: constantShakeSpeed,
                              onAnimationComplete: {
                                  animationCompleted = true
                              }
                          )
                       .padding(.horizontal, 16)
                   }
                   .frame(width: dialogueWidth, height: dialogueHeight, alignment: .center)
                   .background(Color.white)
                   .contentShape(Rectangle())
                   .onTapGesture {
                       handleTap()
                   }
                   .overlay(
                       RoundedRectangle(cornerRadius: 20)
                           .stroke(animationCompleted ? Color.black : Color.gray.opacity(0.3), lineWidth: 3)
                           .animation(.easeInOut, value: animationCompleted)

                   )
               }
           }
       }
   }

struct DialogueTextView: View {
    @State private var animatedTextsInternal: [String] = []
    @State private var continuousAnimationTime: Double = 0.0
    @State private var allAnimationsFinished: Bool = false

    let texts: [String]
    let textFont: Font
    let textAppearDelay: Double
    let textLineSpacing: CGFloat
    
    let enableConstantShake: Bool
    let constantShakeIntensity: CGFloat
    let constantShakeSpeed: Double
    
    let onAnimationComplete: () -> Void

    private let timer = Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect()
       
    // Define the core text content as a @ViewBuilder property
    @ViewBuilder
    private var textContent: some View {
        VStack(spacing: textLineSpacing) {
            ForEach(Array(texts.enumerated()), id: \.offset) { index, _ in // textLine parameter not used here
                if index < animatedTextsInternal.count {
                    AnimateText<ATTopBottomEffect>($animatedTextsInternal[index], type: .words)
                        .font(textFont)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .minimumScaleFactor(0.5)
                }
            }
        }
    }

    var body: some View {
        Group { // Use Group to conditionally apply modifiers to the same view structure
            if enableConstantShake {
                textContent
                    .modifier(ContinuousShakeEffect(time: continuousAnimationTime, intensity: constantShakeIntensity, speed: constantShakeSpeed))
            } else {
                textContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear {
            animatedTextsInternal = Array(repeating: "", count: texts.count)
            allAnimationsFinished = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + textAppearDelay) {
                for i in 0..<texts.count {
                    if i < animatedTextsInternal.count { // Ensure index is valid
                        animatedTextsInternal[i] = texts[i]
                    }
                }
            }
        }
        .onChange(of: animatedTextsInternal) { oldValue, newValue in
            // Ensure allAnimationsFinished is checked before calling onAnimationComplete
            if !allAnimationsFinished && newValue == texts {
                allAnimationsFinished = true // Set flag before calling callback
                onAnimationComplete()
            }
        }
        .onReceive(timer) { _ in
            if enableConstantShake {
                continuousAnimationTime += (1.0/60.0)
            }
        }
    }
}

#Preview {
    DialogueView(
      dialogueTexts: [ "¿Cuánto habrías", "logrado si hubieras", "comenzado antes?"
      ],
      illustrationImage: Image("rectangle33"),
      textFont: .Patrick32,
      textAppearDelay: 3,
      textLineSpacing: 2,
      enableConstantShake: true,
      constantShakeIntensity: 0.8,
      constantShakeSpeed: 2.2)
    
    .environment(LevelManager())
}
