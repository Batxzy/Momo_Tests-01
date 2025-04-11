import SwiftUI

struct TapProgressView: View {
    // Track progress from 0 to 1
    @State private var progress: Double = 0.0
    // Track if the bar has reached 100%
    @State private var isComplete: Bool = false
    // Timer to decrease progress
    @State private var timer: Timer? = nil
    
    // Get the level manager from the environment
    @Environment(\.levelManager) private var levelManager
    
    // Amount to increase on tap
    private let tapIncrement: Double = 0.1
    // Amount to decrease per timer tick
    private let decrementAmount: Double = 0.03
    // Timer interval
    private let timerInterval: TimeInterval = 0.1
    
    var body: some View {
        VStack {
            // Tap area
            ZStack {
                Rectangle()
                    .fill(Color.red)
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle()) // Ensures the entire area is tappable
                    .onTapGesture {
                        handleTap()
                    }
                
                // Overlay for completion state
                if isComplete {
                    Rectangle()
                        .fill(Color.blue)
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .transition(.opacity)
                }
            }
            .padding()
            
            // Progress bar with modern animation
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background of the progress bar
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    // Filled portion of the progress bar
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isComplete ? Color.green : Color.blue)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 20)
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
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    func stopTimer() {
       timer?.invalidate()
       timer = nil
       }
    
    private func handleTap() {
        guard !isComplete else { return }
        
        // Use withAnimation for smooth progress update
        withAnimation() {
            progress = min(progress + tapIncrement, 1.0)
        }
        
        if progress >= 1.0 {
            completeGame()
        }
    }
    
    private func completeGame() {
        isComplete = true
        stopTimer()
        
        // Use DispatchQueue instead of async/await since user prefers to avoid async
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            levelManager.completeCurrentLevel()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            if !isComplete && progress > 0 {
                // Use withAnimation for smoother transitions
                withAnimation {
                    // Decrease progress over time
                    progress = max(progress - decrementAmount, 0.0)
                }
            }
        }
        
     
        
    }
}
#Preview {
    // Create a simple LevelManager for the preview
    let levelManager = LevelManager(chapters: [])
    
    return TapProgressView()
        .environment(\.levelManager, levelManager)
}
