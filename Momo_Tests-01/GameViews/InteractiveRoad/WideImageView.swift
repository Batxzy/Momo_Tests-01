import SwiftUI


//MARK: - view extensions
//usado para pasar el tamaño del view grande del geometry al main view
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// Extensión en View que permite leer el tamaño usando un modificador.
extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    func debugStroke(_ color: Color = .red) -> some View {
        self.overlay(Rectangle().stroke(color, lineWidth: 1))
    }
}


struct WideImageView: View {
// MARK: - Properties
    
    var image = Image("wide")
    var stateManager = StoryStateManager()

    //guarda las dimenciones de la imagen del fondo
    @State private var imageSize = CGSize.zero
    
    
    // Layout constants
    private let frameWidth: CGFloat = 343
    private let frameHeight: CGFloat = 733
    
    // posiciones de los personajes
    private let elementPositions = [
            CGPoint(x: 0.31, y: 0.3),
            CGPoint(x: 0.60, y: 0.6),
            CGPoint(x: 0.96, y: 0.7)
        ]
    
    private let elementImages = ["Reason", "Shinji", "rectangle33"]
    
    // MARK: - setup
    
    private func calculateOffset() -> CGFloat {
           let excessWidth = imageSize.width - frameWidth
           return excessWidth > 0 ? -excessWidth * stateManager.offsetPercentage : 0
       }
    
    private var sliderControls: some View {
            VStack(alignment: .leading, spacing: 4) {
                
                Slider(
                    value: Binding(
                        get: { stateManager.offsetPercentage },
                        set: { stateManager.offsetPercentage = $0 }
                    ),
                    in: 0...1,
                    step: 0.01
                )
                .tint(.blue)
                .padding(.horizontal, 4)
                
                HStack {
                    Text("Left").font(.caption)
                    Spacer()
                    Text("Right").font(.caption)
                }
                .foregroundColor(.secondary)
            }
            .frame(width: frameWidth)
            .disabled(stateManager.isAnimating || stateManager.showingDialogue)
        }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 2) {
            
            
                GeometryReader { frameGeometry in
                    ZStack() {
                        image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                        //aqui leo las dimensiones del view y se las paso al geometry size
                        .readSize { size in
                            if imageSize != size {
                                imageSize = size
                                print("📏 Image size: \(size.width) × \(size.height)")
                                print("📐 Excess width: \(size.width - frameWidth)")
                            }
                        }
                        .offset(x: calculateOffset())
                    
                        ForEach(0..<elementPositions.count, id: \.self) { index in
                                    InteractiveElementView(
                                        imageName: elementImages[index],
                                        position: elementPositions[index],
                                        imageWidth: imageSize.width,
                                        frameHeight: frameHeight,
                                        elementIndex: index,
                                        isInteractive: stateManager.isElementInteractive(index),
                                        onTap: stateManager.handleElementTap
                                    )
                                }
                            .offset(x: calculateOffset())
                       
                        Image("Momo")
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                           .frame(width: 200, height: 300)
                           .position(
                               x: frameGeometry.size.width * 0.3,  //
                               y: frameGeometry.size.height * 0.75 //
                           )
                           .debugStroke(.green)
                        
                        if stateManager.showingDialogue, let dialogueInfo = stateManager.currentState.dialogueInfo {
                                                DialogueViewWide(
                                                    imageName: dialogueInfo.dialogueImageName,
                                                    position: CGPoint(
                                                        x: frameGeometry.size.width * dialogueInfo.position.x,
                                                        y: frameGeometry.size.height * dialogueInfo.position.y
                                                    ),
                                                    size: dialogueInfo.size,
                                                    canAdvance: stateManager.canAdvanceAfterDialogue
                                                )
                                            }
                                            
                        // Tap overlay for background taps
                        TapOverlayView(stateManager: stateManager)
                        
                    }
                }
                .frame(width: frameWidth, height: frameHeight)
                .clipped()
                .debugStroke()
            
            sliderControls
        }
    }
    
}

// MARK: - Button
import SwiftUI

struct ButtonView: View {
    @Binding var offsetPercentage: Double
    @State private var isAnimating = false
    
    // Animation configuration
    private let movementIncrement = 0.20 // Increase offset by 20%
    private let animationDuration = 1.0    // Animation lasts 4 seconds
    
    var body: some View {
        Button(action: {
            if !isAnimating {
                startAnimation()
            }
        }) {
            Text("boton")
                .font(.headline)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isAnimating ? Color.blue.opacity(0.7) : Color.blue)
                }
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .scaleEffect(isAnimating ? 0.98 : 1.0)
        }
    }
    
    private func startAnimation() {
        isAnimating = true
        
        // Calculate target offset ensuring it doesn't exceed 1.0
        let targetOffset = min(1.0, offsetPercentage + movementIncrement)
        
        withAnimation(.easeInOut(duration: animationDuration)) {
            offsetPercentage = targetOffset
        }
        
        // Reset the animation state after the duration so the button can be pressed again.
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            isAnimating = false
        }
    }
}



#Preview {
    WideImageView()
}
