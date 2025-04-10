import SwiftUI

struct DragProgressView: View {
    // Track progress from 0 to 1
    @State private var progress: Double = 0.0
    // Track if the bar has reached 100%
    @State private var isComplete: Bool = false
    // Timer to decrease progress
    @State private var timer: Timer? = nil
    
    // Position of green rectangle relative to blue rectangle (0-1 range)
    @State private var greenRectPosition: CGPoint = CGPoint(x: 0.5, y: 0.78)
    
    // Sensitivity control - higher values (1-10) require harder swipes
    var swipeSensitivity: Double = 10// Default: medium difficulty (scale 1-10)
    
    // Track drag gesture state
    @State private var isDragging: Bool = false
    @State private var dragDistance: CGFloat = 0
    @State private var lastDragPosition: CGPoint = .zero
    
    // Amount to decrease per timer tick
    private let decrementAmount: Double = 0.03
    // Timer interval
    private let timerInterval: TimeInterval = 0.1
    
    // Calculate the actual multiplier from the sensitivity (inverted scale)
    private var actualMultiplier: Double {
        // Validate input range
        let validatedSensitivity = max(1.0, min(10.0, swipeSensitivity))
        
        // Map from 1-10 scale (user-friendly) to actual multiplier (0.001-0.0001)
        // Note: Higher sensitivity (10) = smaller multiplier = harder swipes
        //       Lower sensitivity (1) = larger multiplier = easier swipes
        let maxMultiplier = 0.001   // When sensitivity is 1 (easiest)
        let minMultiplier = 0.0001  // When sensitivity is 10 (hardest)
        
        // Linear interpolation between max and min multiplier based on sensitivity
        return maxMultiplier - ((validatedSensitivity - 1) / 9) * (maxMultiplier - minMultiplier)
    }
    
    var body: some View {
        GeometryReader { geometry in
            // Main container
            ZStack {

                VStack(spacing: 0) {
                    // Blue rectangle with padding
                    ZStack {
                        // Blue rectangle with padding
                        Rectangle()
                            .fill(Color.blue)
                            .padding(22)
                            .overlay(
                                GeometryReader { blueGeometry in
                                    // Green rectangle positioned relative to blue rectangle
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(width: 300, height: 200)
                                        .position(
                                            x: (blueGeometry.size.width * greenRectPosition.x) + blueGeometry.frame(in: .local).minX,
                                            y: (blueGeometry.size.height * greenRectPosition.y) + blueGeometry.frame(in: .local).minY
                                        )
                                        .gesture(
                                            DragGesture(minimumDistance: 5)
                                                .onChanged { value in
                                                    if !isDragging {
                                                        isDragging = true
                                                        lastDragPosition = value.location
                                                    } else {
                                                        // Calculate distance of this drag motion
                                                        let currentPos = value.location
                                                        let dx = currentPos.x - lastDragPosition.x
                                                        let dy = currentPos.y - lastDragPosition.y
                                                        let distance = sqrt(dx*dx + dy*dy)
                                                        
                                                        // Accumulate total drag distance
                                                        dragDistance += distance
                                                        
                                                        // Update progress based on drag distance and sensitivity
                                                        let increment = Double(distance) * actualMultiplier
                                                        progress = min(progress + increment, 1.0)
                                                        
                                                        // Check if complete
                                                        if progress >= 1.0 && !isComplete {
                                                            isComplete = true
                                                            timer?.invalidate()
                                                            timer = nil
                                                        }
                                                        
                                                        // Update last position
                                                        lastDragPosition = currentPos
                                                    }
                                                }
                                                .onEnded { _ in
                                                    isDragging = false
                                                    dragDistance = 0
                                                }
                                        )
                                }
                            )
                    }
                    
                    // Completely separate progress bar section
                    VStack(spacing: 10) {
                        Text("\(Int(progress * 100))%")
                            .font(.title)
                            .bold()
                        
                        // Progress bar
                        ZStack(alignment: .leading) {
                            // Background of the progress bar
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.4))
                                .frame(height: 20)
                            
                            // Filled portion of the progress bar
                            RoundedRectangle(cornerRadius: 10)
                                .fill(isComplete ? Color.green : Color.yellow)
                                .frame(width: geometry.size.width * 0.8 * CGFloat(progress), height: 20)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                        }
                        .frame(width: geometry.size.width * 0.8)
                        
                        // Show current sensitivity level and multiplier for debugging
                        VStack(spacing: 2) {
                            Text("Swipe Difficulty: \(String(format: "%.1f", swipeSensitivity)) / 10")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("Multiplier: \(String(format: "%.6f", actualMultiplier))")
                                .font(.caption2)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }
                    .padding(10)
                }
            }
        }
        .onAppear {
            // Start the timer to decrease progress
            startTimer()
        }
        .onDisappear {
            // Clean up timer
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            if !isComplete && progress > 0 && !isDragging {
                // Decrease progress over time, but only when not dragging
                progress = max(progress - decrementAmount, 0.0)
            }
        }
    }
}

struct DragProgressView_Previews: PreviewProvider {
    static var previews: some View {
        DragProgressView(swipeSensitivity: 9) // Medium difficulty
    }
}
