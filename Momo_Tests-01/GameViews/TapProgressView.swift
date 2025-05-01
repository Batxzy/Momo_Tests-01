import SwiftUI

struct TapProgressView: View {
    //MARK: - vairbales y cosistas  estado
    var FirstIllustration : Image
    
    var SecondIllustration : Image
    
    private let ilustrationWidth: CGFloat = 320
    
    private let ilustrationHeight: CGFloat = 580
        
    // Track progress from 0 to 1
    @State private var progress: Double = 0.0
    // Track if the bar has reached 100%
    @State private var isComplete: Bool = false
    // Timer to decrease progress
    @State private var timer: Timer? = nil
    // Track if the button should be shown after completion
    @State private var showButton: Bool = false
    
    // state para animaciones
    @State private var isTapped: Bool = false

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
        
        isTapped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isTapped = false
        }
        
        if progress >= 1.0 {
            markAsComplete()
        }
    }
    
    private func markAsComplete() {
        isComplete = true
        stopTimer()
        
        // Add delay before showing the button
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                showButton = true
            }
        }
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
        Color.white
            .ignoresSafeArea()
        
        // -- ILUSTRACION Y TAP -- //
        VStack(spacing: 24){
            
            ZStack {
                FirstIllustration
                    .resizable()
                    .scaledToFill()
                    .frame(width: ilustrationWidth, height: ilustrationHeight)
                    .clipped()
                    .opacity(isComplete ? 0 : 1)
                
                SecondIllustration
                    .resizable()
                    .scaledToFill()
                    .frame(width: ilustrationWidth, height: ilustrationHeight)
                    .clipped()
                    .opacity(isComplete ? 1 : 0)
            }
            .animation(.easeInOut(duration: 0.7), value: isComplete)
            
            // -- barra de progreso y boton --//
            VStack(spacing: 24) {
                
                // -- barra de progreso --//
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isComplete ? Color.green : Color.red)
                            .frame(width: geometry.size.width * CGFloat(progress), height: 47)
                        
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
                
                // -- if para el boton o la barra --//
                   if isComplete {
                       if showButton {
                           CustomButtonView(title: "siguiente") {
                               levelManager.completeLevel()
                           }
                           .transition(.opacity)
                       } else {
                           Color.clear
                               .frame(height: 44)
                       }
                   }
                    else {
                        
                       Image("Listen")
                           .resizable()
                           .scaledToFill()
                           .frame(width: 100, height: 100)
                           .contentShape(Rectangle())
                           .scaleEffect(isTapped ? 0.80 : 1.0)
                           .opacity(isTapped ? 0.75 : 1.0)
                           .animation(.spring(duration: 0.3, bounce: 0.4), value: isTapped)
                           .onTapGesture(perform: handleTap)
                           .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        }
                }
                .frame(height: 150,alignment: .top)
                .animation(.smooth, value: isComplete)
            
                }
            }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
}

#Preview {
    TapProgressView(FirstIllustration: Image("rectangle33"), SecondIllustration: Image("rectangle35"))
        .environment(LevelManager())
}
