import SwiftUI

struct DragProgressView: View {

//MARK: - Setup de cosas
    
    @Environment(LevelManager.self) private var levelManager
    
    @State private var progress: Double = 0.0
    @State private var isComplete: Bool = false
    @State private var timer: Timer?
    @State private var isDragging: Bool = false
    @State private var showSecondImage: Bool = false
    @State private var dragSpeed: CGFloat = 0.0
    @State private var lastSpeedCheckTime: Date = Date()


    // Configuration
    let swipeSensitivity: Double // User-defined sensitivity (1-10)
    let blueRectangleSize = CGSize(width: 334, height: 668)
    let greenRectangleSize = CGSize(width: 282, height: 200)
    let progressBarWidth: CGFloat = 300
    let progressBarHeight: CGFloat = 20
    
    let Ilustration : Image
    let secondIlustration : Image
    
    @State private var lastDragPosition: CGPoint = .zero
    @State private var lastDragTime: Date = Date()

    
    private let speedThreshold: CGFloat = 100
    private let imageChangeDelay: TimeInterval = 0.2

    // posicion del rectanglo verde
    let greenRectRelativePosition: CGPoint = CGPoint(x: 0.5, y: 0.80)

    // control del drag
    private let decrementAmount: Double = 0.03
    private let timerInterval: TimeInterval = 0.1

//MARK: - Funciones y geststos
    
// +++ salve chadgpt esto eran matematicas de vectores que aun no termino de comprender totalmente +++
    
    // Calculates the internal multiplier based on user sensitivity
    private var dragMultiplier: Double {
        let validatedSensitivity = max(1.0, min(10.0, swipeSensitivity))
        // Map 1-10 (easy-hard) to 0.001-0.0001 (high-low multiplier)
        let maxMultiplier = 0.001
        let minMultiplier = 0.00001
        return maxMultiplier - ((validatedSensitivity - 1) / 9.0) * (maxMultiplier - minMultiplier)
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    lastDragPosition = value.location
                    lastDragTime = Date()
                    lastSpeedCheckTime = Date()
                    stopTimer()
                } else {
                    let currentPos = value.location
                    let currentTime = Date()
                    
                    let dx = currentPos.x - lastDragPosition.x
                    let dy = currentPos.y - lastDragPosition.y
                    let distance = sqrt(dx*dx + dy*dy)
                    
                    let timeDelta = currentTime.timeIntervalSince(lastDragTime)
                    
                    // Calculate speed (pixels per second)
                    if timeDelta > 0 {
                        dragSpeed = CGFloat(distance / CGFloat(timeDelta))
                        
                        // Only check for image change if enough time has passed
                        let timeSinceLastCheck = currentTime.timeIntervalSince(lastSpeedCheckTime)
                        if timeSinceLastCheck >= imageChangeDelay {
                            // MODIFIED: Added "sticky" behavior to prevent rapid toggling
                            if dragSpeed > speedThreshold + 50 {
                                showSecondImage = true
                            } else if dragSpeed < speedThreshold - 50 {
                                showSecondImage = false
                            }
                            // (keeping current state if speed is in the "buffer zone")
                            
                            // Reset last check time
                            lastSpeedCheckTime = currentTime
                        }
                    }

                    // Update progress based on distance
                    let increment = Double(distance) * dragMultiplier
                    progress = min(progress + increment, 1.0)

                    // Check if complete
                    if progress >= 1.0 && !isComplete {
                        isComplete = true
                        // Force second image when complete
                        showSecondImage = true
                        
                        // After 3 seconds, complete the level
                        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                            levelManager.completeLevel()
                        }
                    }

                    // Update for next calculation
                    lastDragPosition = currentPos
                    lastDragTime = currentTime
                }
            }
            .onEnded { _ in
                isDragging = false
                lastDragPosition = .zero
                
                // Only return to first image if not complete
                if !isComplete {
                    // MODIFIED: Increased delay to make it more noticeable
                    Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
                        if !isComplete {
                            showSecondImage = false
                        }
                    }
                    startTimer()
                }
            }
    }



    private func startTimer() {
        timer?.invalidate()
        if !isComplete && !isDragging {
            timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
                if !isDragging && progress > 0 {
                    progress = max(progress - decrementAmount, 0.0)
                    if progress == 0.0 {
                        stopTimer()
                    }
                } else if isDragging {
                    stopTimer()
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

//MARK: - View
    var body: some View {
        VStack(spacing: 30) {
            
            //--- Drag Area ----
            ZStack {
                Group {
                    if showSecondImage {
                        secondIlustration
                            .resizable()
                            .scaledToFill()
                            .frame(width: blueRectangleSize.width, height: blueRectangleSize.height)
                            .clipped()
                    } else {
                        Ilustration
                            .resizable()
                            .scaledToFill()
                            .frame(width: blueRectangleSize.width, height: blueRectangleSize.height)
                            .clipped()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
                
                // Overlay for drag gesture
                GeometryReader { blueGeometry in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: greenRectangleSize.width, height: greenRectangleSize.height)
                        .contentShape(Rectangle()) // This preserves hit testing area
                        .position(
                            x: blueGeometry.size.width * greenRectRelativePosition.x,
                            y: blueGeometry.size.height * greenRectRelativePosition.y
                        )
                        .gesture(dragGesture)
                }
            }
            // --- Progress Bar Area ---
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isComplete ? Color.green : Color.red)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 47)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 300, height: 47)
                        .background(
                            Image("Bar")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 300, height: 47)
                                .clipped()
                        )
                }
            }
            .frame(width: 300,height: 47)
        }
        .padding()
        .onAppear(perform: startTimer)
        .onDisappear(perform: stopTimer)
    }

   
}
// MARK: - Preview

struct DragProgressView_Previews: PreviewProvider {
    static var previews: some View {
        // Example with higher sensitivity (harder to fill)
        DragProgressView(swipeSensitivity: 9, Ilustration: Image ("Cat_Game_1_(1)"), secondIlustration: Image("Cat_Game_1_(2)") )
            .environment(LevelManager())
    }
}
