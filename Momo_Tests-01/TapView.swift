import SwiftUI

struct TapProgressView: View {
    // Track progress from 0 to 1
    @State private var progress: Double = 0.0
    // Track if the bar has reached 100%
    @State private var isComplete: Bool = false
    // Timer to decrease progress
    @State private var timer: Timer? = nil
    
    // Amount to increase on tap
    private let tapIncrement: Double = 0.1
    // Amount to decrease per timer tick
    private let decrementAmount: Double = 0.03
    // Timer interval
    private let timerInterval: TimeInterval = 0.1
    
    var body: some View {
        VStack {
            // Image with white background
            ZStack {
                Rectangle()
                    .fill(Color.red)
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        if !isComplete {
                            
                            progress = min(progress + tapIncrement, 1.0)
                            
                            if progress >= 1.0 {
                                isComplete = true
                                timer?.invalidate()
                                timer = nil
                            }
                        }
                    }
                
                // Overlay text showing completion status
                if isComplete {
                    Rectangle()
                    .fill(Color.blue)
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            
            // Progress bar with smooth animation
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background of the progress bar
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    // Filled portion of the progress bar - only animate this element
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isComplete ? Color.green : Color.blue)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 20)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 20)
            .padding()
            
            // Display the percentage
            Text("\(Int(progress * 100))%")
                .font(.title)
                .bold()
                .padding(.top, 8)
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
            if !isComplete && progress > 0 {
                // Decrease progress over time (animation is applied by the view)
                progress = max(progress - decrementAmount, 0.0)
            }
        }
    }
}

struct TapProgressView_Previews: PreviewProvider {
    static var previews: some View {
        TapProgressView()
    }
}
