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
        self
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geometry.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}


struct WideImageView: View {
// MARK: - Properties
    
    var image = Image("wide")
    
    @State private var offsetPercentage = 0.0
    
    //guarda las dimenciones de la imagen del fondo
    @State private var imageSize = CGSize.zero
    
    // Layout constants
    private let frameWidth: CGFloat = 343
    private let frameHeight: CGFloat = 733
    
    // posiciones de los personajes
    private let rect1ImagePosition = CGPoint(x: 0.31, y: 0.3)
    
    private let rect2ImagePosition = CGPoint(x: 0.60, y: 0.6)
    
    private let rect3ImagePosition = CGPoint(x: 0.96, y: 0.7)
    
    // MARK: - setup
    
    private func calculateOffset() -> CGFloat {
        let excessWidth = imageSize.width - frameWidth
        return excessWidth > 0 ? -excessWidth * offsetPercentage : 0
    }
    
    private var sliderControls: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("position")
                .font(.callout)
                .foregroundColor(.secondary)
            
            Slider(
                value: $offsetPercentage,
                in: 0...1,
                step: 0.01
            )
            .tint(.blue)
            .padding(.horizontal, 4)
            .onChange(of: offsetPercentage) { newValue in
                print("🎚️ Slider: \(String(format: "%.2f", newValue))")
                print("➡️ Offset: \(String(format: "%.1f", calculateOffset()))")
            }
            
            HStack {
                Text("Left").font(.caption)
                Spacer()
                Text("Right").font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .frame(width: frameWidth)
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
                    
                        Group{
                            InteractiveElementView(imageName: "Reason", position: rect1ImagePosition, imageWidth: imageSize.width, frameHeight: frameHeight)
                            
                            InteractiveElementView(imageName: "Shinji", backgroundColor: .white, position: rect2ImagePosition, imageWidth: imageSize.width, frameHeight: frameHeight)
                            
                            InteractiveElementView(imageName: "rectangle33", position: rect3ImagePosition, imageWidth: imageSize.width, frameHeight: frameHeight)
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
                        
                        
                        TapOverlayView(offsetPercentage: $offsetPercentage)
                        
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

// MARK: - Tap overlay
struct TapOverlayView: View {
    
    @Binding var offsetPercentage: Double
    
    @State private var isAnimating = false
    @State private var currentTargetStateIndex = 0

    private let targetOffsetStates: [Double] = [0.0, 0.25, 0.60, 1.0]

    private let animationDuration = 4.0    // Animation duration

    var body: some View {
        Color.clear // Transparent tappable area
            .contentShape(Rectangle()) // Define the tappable shape
            .onTapGesture {
                // Only trigger if not already animating
                if !isAnimating {
                    advanceToNextStateAndAnimate()
                } else {
                    print("🚫 Animation already in progress. Tap ignored.")
                }
            }
    }
         func advanceToNextStateAndAnimate() {

                isAnimating = true

                let nextStateIndex = (currentTargetStateIndex + 1) % targetOffsetStates.count

                let targetOffset = targetOffsetStates[nextStateIndex]

                print("👆 Tap: Animating from state \(currentTargetStateIndex) (offset \(String(format: "%.2f", offsetPercentage))) to state \(nextStateIndex) (target offset \(String(format: "%.2f", targetOffset)))")

                withAnimation(.easeInOut(duration: animationDuration)) {
                    offsetPercentage = targetOffset
                }

                currentTargetStateIndex = nextStateIndex

                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    isAnimating = false
                    print("✅ Animation complete. Ready for next tap.")
                }
            }
}

// MARK: - Interactive element
struct InteractiveElementView: View {
    let imageName: String
    var backgroundColor: Color? = nil
    let position: CGPoint
    let imageWidth: CGFloat
    let frameHeight: CGFloat
    private let elementWidth: CGFloat = 180, elementHeight: CGFloat = 180, cornerRadius: CGFloat = 12, padding: CGFloat = 16
    var body: some View {
               RoundedRectangle(cornerRadius: cornerRadius)
                   .fill(.ultraThinMaterial)
                   .frame(width: elementWidth, height: elementHeight)
                   .overlay(
                       Image(imageName)
                           .resizable()
                           .scaledToFit()
                           .background(backgroundColor ?? .clear)
                           .padding(padding)
                           .clipped()
                   )
                   .position(
                       x: imageWidth * position.x,
                       y: frameHeight * position.y
                   )
    }
}

#Preview {
    WideImageView()
}
