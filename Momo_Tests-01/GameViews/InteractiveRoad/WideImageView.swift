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
    
    @Environment(LevelManager.self) private var levelManager
    @State private var stateManager = StoryStateManager()

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
            .disabled(stateManager.isAnimating || stateManager.isDisplayingDialogue)
        }
    
    // MARK: - Body
    var body: some View {
        VStack() {

                GeometryReader { frameGeometry in
                    ZStack(){
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
                        
                        TapOverlayView(stateManager: stateManager)

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
                           .shadow(color: .white, radius: 12)
                           .position(
                               x: frameGeometry.size.width * 0.3,  //
                               y: frameGeometry.size.height * 0.75 //
                           )
                           .allowsHitTesting(false)
                        
                                            
                        // Tap overlay for background taps
                        Group {
                            if stateManager.isDisplayingDialogue, let info = stateManager.currentDialogueInfo {
                                        // Show the dialogue image
                                        Image(info.dialogueImageName)
                                            .resizable()
                                            .scaledToFill() // Fit within the dialogue area frame
                                            .frame(width: frameGeometry.size.width, height: 250)
                                            .clipped()
                                            .transition(.opacity.animation(.easeInOut)) // Fade in/out
                                    } else {
                                        // Optional: Show a placeholder or nothing when no dialogue
                                         Color.clear // Or your placeholder view
                                             .frame(width: frameGeometry.size.width, height: 250)
                                    }
                                }
                            .position(x: frameGeometry.size.width / 2, y: 17)

                    }
                }
                .frame(width: frameWidth, height: frameHeight)
                .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
                .onAppear {
                            stateManager.completionCallback = {
                                levelManager.completeLevel()
                            }
                        }
            
        }
    }
    
}

// MARK: - Button

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


#Preview{
    WideImageView(image: Image( "wide"))
        .environment(LevelManager())
}
