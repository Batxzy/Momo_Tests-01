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
    
    private var stateManager = StoryStateManager()

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
        ZStack{
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { frameGeometry in
                ZStack() {
                    // Background image
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .readSize { size in
                            if imageSize != size {
                                imageSize = size
                                print("📏 Image size: \(size.width) × \(size.height)")
                                print("📐 Excess width: \(size.width - frameWidth)")
                            }
                        }
                        .offset(x: calculateOffset())
                    
                    TapOverlayView(stateManager: stateManager)
                    
                    // Interactive elements
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
                    
                    // Character
                    SpriteAnimationView(
                        frameImages: ["cat3", "cat1", "cat2", "cat1"],
                        frameDuration: 0.2,
                        isTransitioning: Binding(
                            get: { stateManager.isAnimating },
                            set: { _ in } // We don't need to set this from the animation view
                        )
                    )
                    .frame(width: 200, height: 300)
                    .position(
                        x: frameGeometry.size.width * 0.3,
                        y: frameGeometry.size.height * 0.75
                    )
                    .allowsHitTesting(false)
                    
                    
                    ZStack {
                        if stateManager.isDisplayingDialogue, let info = stateManager.currentDialogueInfo {
                            DialogueViewWide(imageName: info.dialogueImageName, frameGeometry: frameGeometry)
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut, value: stateManager.isDisplayingDialogue)
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
#Preview{
    WideImageView()
        .environment(LevelManager())
}
