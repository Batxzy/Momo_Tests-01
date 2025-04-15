import SwiftUI

struct DragProgressView: View {

//MARK: - Setup de cosas
    
    @Environment(LevelManager.self) private var levelManager
    
    @State private var progress: Double = 0.0
    @State private var isComplete: Bool = false
    @State private var timer: Timer?
    @State private var isDragging: Bool = false

    // Configuration
    let swipeSensitivity: Double // User-defined sensitivity (1-10)
    let blueRectangleSize = CGSize(width: 334, height: 668)
    let greenRectangleSize = CGSize(width: 282, height: 200)
    let progressBarWidth: CGFloat = 300
    let progressBarHeight: CGFloat = 20

    @State private var lastDragPosition: CGPoint = .zero
    
    // posicion del rectanglo verde
    let greenRectRelativePosition: CGPoint = CGPoint(x: 0.5, y: 0.80)

    // control del drag
    private let decrementAmount: Double = 0.03
    private let timerInterval: TimeInterval = 0.1

//MARK: - Funciones y geststos
    
    // Calculates the internal multiplier based on user sensitivity
    private var dragMultiplier: Double {
        let validatedSensitivity = max(1.0, min(10.0, swipeSensitivity))
        // Map 1-10 (easy-hard) to 0.001-0.0001 (high-low multiplier)
        let maxMultiplier = 0.001
        let minMultiplier = 0.00001
        return maxMultiplier - ((validatedSensitivity - 1) / 9.0) * (maxMultiplier - minMultiplier)
    }
    
    // Drag Gesture Logic
    private var dragGesture: some Gesture {
            DragGesture(minimumDistance: 1) // Lower minimum distance for responsiveness
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        lastDragPosition = value.location // Initialize last position
                        // Stop the timer immediately when dragging starts
                        stopTimer()
                    } else {
                        // Calculate distance of this small drag motion delta
                        let currentPos = value.location
                        let dx = currentPos.x - lastDragPosition.x
                        let dy = currentPos.y - lastDragPosition.y
                        let distanceDelta = sqrt(dx*dx + dy*dy) // Distance of this segment

                        // Update progress based on the delta distance and multiplier
                        let increment = Double(distanceDelta) * dragMultiplier
                        progress = min(progress + increment, 1.0) // Accumulate and clamp

                        // Check if complete
                        if progress >= 1.0 && !isComplete {
                            isComplete = true
                            levelManager.completeLevel()
                        }

                        // Update last position for the next delta calculation
                        lastDragPosition = currentPos
                    }
                }
                .onEnded { _ in
                    isDragging = false
                    // Reset last position (optional, but good practice)
                    lastDragPosition = .zero
                    // Restart timer only if not complete
                    if !isComplete {
                        startTimer()
                    }
                }
        }

    // Timer Management Functions
    private func startTimer() {
        // Invalidate existing timer just in case
        timer?.invalidate()
        // Only start if not complete and not currently dragging
        if !isComplete && !isDragging {
            timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
                // Check isDragging again inside timer closure for safety
                if !isDragging && progress > 0 {
                    progress = max(progress - decrementAmount, 0.0)
                    if progress == 0.0 {
                        stopTimer() // Stop timer if progress reaches zero
                    }
                } else if isDragging {
                    // If dragging starts unexpectedly while timer is running, stop it.
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
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: blueRectangleSize.width, height: blueRectangleSize.height)
                    .overlay(
                        GeometryReader { blueGeometry in
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: greenRectangleSize.width, height: greenRectangleSize.height)
                                .position(
                                    x: blueGeometry.size.width * greenRectRelativePosition.x,
                                    y: blueGeometry.size.height * greenRectRelativePosition.y
                                )
                                .gesture(dragGesture)
                        }
                    )
            }
            .frame(width: blueRectangleSize.width, height: blueRectangleSize.height)

            // --- Progress Bar Area ---
            VStack(spacing: 10) {

                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: progressBarHeight / 2)
                        .fill(.gray.opacity(0.3))

                    // Filled progress indicator
                    RoundedRectangle(cornerRadius: progressBarHeight / 2)
                        .fill(isComplete ? Color.green : Color.red)
                        .frame(width: progressBarWidth * CGFloat(progress))
                        // Use a smooth animation for progress changes
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                }
                .frame(width: progressBarWidth, height: progressBarHeight)
            }
            .padding(20)
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
        DragProgressView(swipeSensitivity: 9)
            .environment(LevelManager())
    }
}
