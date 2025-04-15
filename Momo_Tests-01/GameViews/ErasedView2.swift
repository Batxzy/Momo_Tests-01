import SwiftUI

struct DustRemoverView2: View {
    // MARK: - PROPERTIES
    @Environment(LevelManager.self) private var levelManager

    //imagenes a usar
    let backgroundImage: Image
    let foregroundImage: Image

    // mantengo todas las cordenadas que han sido usdas cuando uso el scratch
    @State private var scratchPoints: [CGPoint] = []

    //array de dos dimensiones
    @State private var erasedGrid: [[Bool]] = []

    //guardar cuantas celdas han sido borradas
    @State private var erasedCells: Int = 0

    //para guardar cuantas celdas hay en realidad
    @State private var totalCells: Int = 0

    let completionThreshold: CGFloat
    @State private var hasTriggeredCompletion: Bool = false

    // Configuration
    private let scratchRadius: CGFloat = 35
    private let gridScale: CGFloat = 10.0
    private let interpolationStep: CGFloat = 8.0

    // For interpolation
    @State private var lastPoint: CGPoint?

    // Using your exact dimensions
    private let backgroundWidth: CGFloat = 334
    private let backgroundHeight: CGFloat = 720
    private let foregroundWidth: CGFloat = 334
    private let foregroundHeight: CGFloat = 300

    private var erasedPercentage: CGFloat {
        guard totalCells > 0 else { return 0 }
        return min(100.0, (CGFloat(erasedCells) / CGFloat(totalCells)) * 100.0)
    }
    // MARK: - Mask View Component
    private var scratchMask: some View {
        Canvas { context, size in
            var path = Path()
            for point in scratchPoints {
                let rect = CGRect(
                    x: point.x - scratchRadius,
                    y: point.y - scratchRadius,
                    width: scratchRadius * 2,
                    height: scratchRadius * 2
                )
                path.addEllipse(in: rect)
            }
            context.fill(path, with: .color(.black))
        }
        .frame(width: foregroundWidth, height: foregroundHeight)
    }

    // MARK: - Drag Gesture Logic
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                guard !hasTriggeredCompletion else { return } // Stop processing if already complete

                let location = value.location

                // Update visual mask immediately
                addScratchPoint(location)
                interpolatePoints(from: lastPoint, to: location)
                lastPoint = location

                // --- Direct Main Thread Grid Update ---
                updateGridAndCheckCompletion(at: location)
            }
            .onEnded { _ in
                lastPoint = nil // Reset interpolation on gesture end
            }
    }

    // MARK: -Funciones y codigo del gird

    private func initializeGrid() {
        // Runs on Main Actor via .task
        let gridWidth = max(1, Int(ceil(foregroundWidth / gridScale)))
        let gridHeight = max(1, Int(ceil(foregroundHeight / gridScale)))

        erasedGrid = Array(repeating: Array(repeating: false, count: gridHeight), count: gridWidth)
        totalCells = gridWidth * gridHeight
        erasedCells = 0
        hasTriggeredCompletion = false
        scratchPoints = []
        lastPoint = nil
    }

    private func addScratchPoint(_ point: CGPoint) {
         let boundedPoint = CGPoint(
             x: max(0, min(point.x, foregroundWidth)),
             y: max(0, min(point.y, foregroundHeight))
         )
        guard boundedPoint.x >= 0 && boundedPoint.y >= 0 else { return }
        scratchPoints.append(boundedPoint)
    }

    private func interpolatePoints(from start: CGPoint?, to end: CGPoint) {
        guard let start = start else { return }
        let distance = hypot(end.x - start.x, end.y - start.y)
        guard distance >= interpolationStep else { return }

        let pointsNeeded = Int(distance / interpolationStep)
        guard pointsNeeded > 1 else { return }

        for i in 1..<pointsNeeded {
            let fraction = CGFloat(i) / CGFloat(pointsNeeded)
            let interpolatedPoint = CGPoint(
                x: start.x + (end.x - start.x) * fraction,
                y: start.y + (end.y - start.y) * fraction
            )
             let boundedInterpolatedPoint = CGPoint(
                 x: max(0, min(interpolatedPoint.x, foregroundWidth)),
                 y: max(0, min(interpolatedPoint.y, foregroundHeight))
             )
             if boundedInterpolatedPoint.x >= 0 && boundedInterpolatedPoint.y >= 0 {
                  scratchPoints.append(boundedInterpolatedPoint)
             }
        }
    }

    // MARK: - Combined Grid Update and Completion Check (Main Thread)

    // Updates grid state directly and checks completion
    private func updateGridAndCheckCompletion(at point: CGPoint) {
        guard !erasedGrid.isEmpty, totalCells > 0, !hasTriggeredCompletion else { return }

        let boundedPoint = CGPoint(
            x: max(0, min(point.x, foregroundWidth)),
            y: max(0, min(point.y, foregroundHeight))
        )

        let gridX = Int(boundedPoint.x / gridScale)
        let gridY = Int(boundedPoint.y / gridScale)
        let gridRadius = Int(ceil(scratchRadius / gridScale))
        let gridWidth = erasedGrid.count
        let gridHeight = erasedGrid.first?.count ?? 0

        guard gridX >= 0, gridY >= 0, gridX < gridWidth, gridY < gridHeight else {
            return
        }

        let minX = max(0, gridX - gridRadius)
        let maxX = min(gridWidth - 1, gridX + gridRadius)
        let minY = max(0, gridY - gridRadius)
        let maxY = min(gridHeight - 1, gridY + gridRadius)

        var cellsJustErased = 0

        for i in minX...maxX {
            guard i >= 0, i < gridWidth else { continue } // Bounds check
            for j in minY...maxY {
                 guard j >= 0, j < gridHeight else { continue } // Bounds check

                let distanceSq = (i - gridX) * (i - gridX) + (j - gridY) * (j - gridY)
                if distanceSq <= gridRadius * gridRadius {
                     // Check and update grid state directly
                     if !erasedGrid[i][j] {
                        erasedGrid[i][j] = true
                        cellsJustErased += 1
                    }
                }
            }
        }

        // Update total count and check completion only if needed
        if cellsJustErased > 0 {
            erasedCells += cellsJustErased
            checkCompletion() // Check threshold now
        }
    }

    // Checks completion threshold (Called from main thread)
    private func checkCompletion() {
        // Already checked !hasTriggeredCompletion in caller, but double-check is safe
        guard !hasTriggeredCompletion, totalCells > 0 else { return }

        let currentPercentage = (CGFloat(erasedCells) / CGFloat(totalCells)) * 100.0

        if currentPercentage >= completionThreshold {
            hasTriggeredCompletion = true
             withAnimation(.easeInOut(duration: levelManager.currentLevel.transition.duration)) {
                 levelManager.completeLevel()
            }
        }
    }
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: -25) {
                ZStack(alignment: .top) {
                    backgroundImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: backgroundWidth, height: backgroundHeight)
                        .clipped()
                    
                    foregroundImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: foregroundWidth, height: foregroundHeight)
                        .clipped()
                        .mask(scratchMask)
                        .gesture(dragGesture)
                }
                
                VStack() {
                    Text("Erased: \(erasedPercentage, specifier: "%.1f")%")
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 15)
                .frame(width: backgroundWidth, alignment: .trailing)
            }
            
            .task { // Use .task for initialization
                initializeGrid()
            }
            
           
        }
       

    }

   
}

// MARK: - Preview

#Preview {
    DustRemoverView2(backgroundImage: Image("rectangle33"), foregroundImage: Image("rectangle35"), completionThreshold: 100.0)
    
    
}
