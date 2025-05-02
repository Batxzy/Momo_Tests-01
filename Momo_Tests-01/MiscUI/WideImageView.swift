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
    private let rect1ImagePosition = CGPoint(x: 0.25, y: 0.3)
    
    private let rect2ImagePosition = CGPoint(x: 0.60, y: 0.6)
    
    private let rect3ImagePosition = CGPoint(x: 0.90, y: 0.7)
    
    // MARK: - setup
    
    private func calculateOffset() -> CGFloat {
        let excessWidth = imageSize.width - frameWidth
        return excessWidth > 0 ? -excessWidth * offsetPercentage : 0
    }
    
    private var sliderControls: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("posicion")
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
                
                // Print current rectangle positions for debugging
                let rect1X = imageSize.width * rect1ImagePosition.x + calculateOffset()
                print("📍 Rect1 current position: \(String(format: "%.1f", rect1X))")
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
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                ZStack {
                                    Image("Reason")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(16)
                                }
                            )
                            .frame(width: 180, height: 180)
                            .position(
                                x: imageSize.width * rect1ImagePosition.x,
                                y: frameHeight * rect1ImagePosition.y
                            )
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .overlay(content: {
                                ZStack {
                                    Image("Shinji")
                                        .resizable()
                                        .scaledToFit()
                                        .background(.white)
                                        .padding(16)
                                        .clipped()
                                }
                            })
                            .frame(width: 180, height: 180)
                            
                            .position(
                                x: imageSize.width * rect2ImagePosition.x,
                                y: frameHeight * rect2ImagePosition.y
                            )
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(content: {
                                ZStack {
                                    Image("rectangle33")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(16)
                                        
                                }
                            })
                            .frame(width: 180, height: 180)
                            .position(
                                x: imageSize.width * rect3ImagePosition.x,
                                y: frameHeight * rect3ImagePosition.y
                            )
                    }
                    .offset(x: calculateOffset())
                }
                .frame(width: frameWidth, height: frameHeight)
                .clipped()
                .debugStroke()
            
            
            // Long press animation control
           LongPressAnimationControl(
               offsetPercentage: $offsetPercentage,
               imageSize: imageSize,
               frameWidth: frameWidth
           )
           .padding(.horizontal, 20)
            // Slider controls
            sliderControls
        }
    }
    
}

// MARK: - Button
struct LongPressAnimationControl: View {
    
    @Binding var offsetPercentage: Double
    @State private var isPressed = false
    @State private var animationPhase = 0
    
    let imageSize: CGSize
    let frameWidth: CGFloat
    
    // Slower animation configuration
    private let animationDuration = 4.0  // Much slower animation
    private let movementIncrement = 0.20 // Move 25% at a time (smaller steps)
    
    var body: some View {
        Text("boton")
            .font(.headline)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isPressed ? Color.blue.opacity(0.7) : Color.blue)
            }
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            // Subtle pulse effect while pressing
            .opacity(isPressed ? 0.9 + (0.1 * sin(Date.timeIntervalSinceReferenceDate * 3)) : 1.0)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            startAnimation()
                        }
                    }
                    .onEnded { _ in
                        stopAnimation()
                    }
            )
    
            // Modern transition
            .animation(.smooth(duration: 0.2), value: isPressed)
    }
    
    private func startAnimation() {
        guard !isPressed else { return }
        
        print("👆 Animation started - moving forward slowly and smoothly")
        isPressed = true
        
        // Calculate target based on current position (smaller increment)
        let targetOffset = min(1.0, offsetPercentage + movementIncrement)
        
        // Use smooth animation with slower timing
        withAnimation(.smooth(duration: animationDuration)) {
            // Animate to target position
            offsetPercentage = targetOffset
        }
    }
    
    private func stopAnimation() {
        guard isPressed else { return }
        
        print("👆 Animation stopped at \(String(format: "%.2f", offsetPercentage))")
        isPressed = false
        
        // Stop animation immediately without additional movement
        withAnimation(.smooth(duration: 0.3)) {
            // No additional movement, just stabilize
            offsetPercentage = offsetPercentage
        }
    }
}



#Preview {
    WideImageView()
}
