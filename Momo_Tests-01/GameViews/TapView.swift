import SwiftUI

struct TapProgressView: View {
    //MARK: - vairbales y cosistas  estado
    var illustration : Image

    private let ilustrationWidth: CGFloat = 340
    
    private let ilustrationHeight: CGFloat = 600
        
    // Track progress from 0 to 1
    @State private var progress: Double = 0.0
    // Track if the bar has reached 100%
    @State private var isComplete: Bool = false
    // Timer to decrease progress
    @State private var timer: Timer? = nil
    
    // Get the level manager from the environment
    @Environment(LevelManager.self) private var levelManager
    
    // Amount to increase on tap
    private let tapIncrement: Double = 0.1
    // Amount to decrease per timer tick
    private let decrementAmount: Double = 0.03
    // Timer interval
    private let timerInterval: TimeInterval = 0.1
//MARK: - Funciones
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
        
        levelManager.completeLevel()
    }
    
    private func stopTimer() {
         timer?.invalidate()
         timer = nil
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
//MARK: - View
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                // Tap area
                
                illustration
                    .resizable()
                    .scaledToFill()
                    .frame(width: ilustrationWidth, height: ilustrationHeight)
                    .clipped()
                
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
                .frame (width: 300)
                .padding()
                
                //tapable area
                Rectangle()
                    .fill(Color.red)
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .contentShape(Rectangle()) // Ensures the entire area is tappable
                    .onTapGesture {
                        handleTap()
                    }
                    .padding(15)
            }
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
    }
    
  
    
   
}
#Preview {
 TapProgressView(illustration: Image("rectangle33"))
}
