import SwiftUI

struct DustRemoverView2: View {
// MARK: - PROPERTIES
    
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
    
    // Configuration
    private let scratchRadius: CGFloat = 25
    private let gridScale: CGFloat = 8.0  // Each grid cell represents 8x8 pixels
    
    // For interpolation between points to ensure smooth visual effect
    @State private var lastPoint: CGPoint?
    
    // Using your exact dimensions
    private let backgroundWidth: CGFloat = 334
    private let backgroundHeight: CGFloat = 720
    private let foregroundWidth: CGFloat = 334
    private let foregroundHeight: CGFloat = 300
    
// MARK: -Funciones y codigo del gird
    
    // Initialize the downsampled grid
    private func initializeGrid() {
        // Use fixed dimensions for grid
        let gridWidth = max(1, Int(ceil(foregroundWidth / gridScale)))
        let gridHeight = max(1, Int(ceil(foregroundHeight / gridScale)))
        
        // Create grid with at least 1x1 dimensions
        erasedGrid = Array(repeating: Array(repeating: false, count: gridHeight), count: gridWidth)
        totalCells = gridWidth * gridHeight
        erasedCells = 0
        
        print("Grid initialized: \(gridWidth) x \(gridHeight)")
    }
    
    private func updateErasedGrid(at point: CGPoint) {
        // Safety check - make sure grid is initialized
        guard !erasedGrid.isEmpty else {
            print("Grid not initialized yet")
            return
        }
        
        // IMPORTANT: Contain the point within the image bounds
        let boundedPoint = CGPoint(
            x: max(0, min(point.x, foregroundWidth)),
            y: max(0, min(point.y, foregroundHeight))
        )
        
        // Skip processing if point is out of bounds
        guard boundedPoint.x >= 0 && boundedPoint.y >= 0 &&
              boundedPoint.x <= foregroundWidth && boundedPoint.y <= foregroundHeight else {
            print("Point out of bounds: \(point)")
            return
        }
        
        // Convert to grid coordinates using the bounded point
        let gridX = Int(boundedPoint.x / gridScale)
        let gridY = Int(boundedPoint.y / gridScale)
        
        // Calculate grid radius
        let gridRadius = Int(ceil(scratchRadius / gridScale))
        
        // Get grid dimensions
        let gridWidth = erasedGrid.count
        let gridHeight = erasedGrid.first?.count ?? 0
        
        // Skip processing if grid coordinates are invalid
        guard gridX >= 0 && gridY >= 0 && gridX < gridWidth && gridY < gridHeight else {
            print("Grid coordinates out of bounds: (\(gridX), \(gridY))")
            return
        }
        
        // Bounds for our grid search - with extra validation
        let minX = max(0, gridX - gridRadius)
        let maxX = min(gridWidth - 1, gridX + gridRadius)
        let minY = max(0, gridY - gridRadius)
        let maxY = min(gridHeight - 1, gridY + gridRadius)
        
        // Extra validation - ensure the ranges are valid
        guard minX <= maxX && minY <= maxY else {
            print("Invalid grid search range: X(\(minX)...\(maxX)), Y(\(minY)...\(maxY))")
            return
        }
        
        // Track new cells erased
        var newlyErased = 0
        
        // Mark grid cells as erased - with thorough bounds checking
        for i in minX...maxX {
            // Verify i is in bounds
            guard i >= 0, i < gridWidth, i < erasedGrid.count else { continue }
            
            for j in minY...maxY {
                // Verify j is in bounds for this row
                guard j >= 0, j < gridHeight, j < erasedGrid[i].count else { continue }
                
                // Check if point is within the circle
                let distance = sqrt(pow(Double(i - gridX), 2) + pow(Double(j - gridY), 2))
                
                if distance <= Double(gridRadius) && !erasedGrid[i][j] {
                    erasedGrid[i][j] = true
                    newlyErased += 1
                }
            }
        }
        
        // Update the total (keeping the original threading code)
        erasedCells += newlyErased
    }
    
    private var erasedPercentage: CGFloat {
        guard totalCells > 0 else { return 0 }
        return min(100, (CGFloat(erasedCells) / CGFloat(totalCells)) * 100)
    }
    
    var body: some View {
           VStack(spacing: -25) {
               // Main scratch area and images
               ZStack(alignment: .top) {
                   // Background image - using your dimensions
                   backgroundImage
                       .resizable()
                       .aspectRatio(contentMode: .fill)
                       .frame(width: backgroundWidth, height: backgroundHeight)
                       .clipped()
                   
                   // Foreground image - using your dimensions
                   foregroundImage
                       .resizable()
                       .aspectRatio(contentMode: .fill)
                       .frame(width: foregroundWidth, height: foregroundHeight)
                       .clipped()
                       .onAppear {
                           initializeGrid()
                       }
                       .mask(
                           Canvas { context, size in
                               for point in scratchPoints {
                                   let rect = CGRect(
                                       x: point.x - scratchRadius,
                                       y: point.y - scratchRadius,
                                       width: scratchRadius * 2,
                                       height: scratchRadius * 2
                                   )
                                   context.fill(Path(ellipseIn: rect), with: .color(.black))
                               }
                           }
                       )
                       .gesture(
                           DragGesture(minimumDistance: 0, coordinateSpace: .local)
                               .onChanged { value in
                                   let location = value.location
                                   
                                   // Only process if the gesture is within the bounds
                                   guard location.x >= 0 && location.x <= foregroundWidth &&
                                         location.y >= 0 && location.y <= foregroundHeight else {
                                       return
                                   }
                                   
                                   // Add the current point for visual effect
                                   scratchPoints.append(location)
                                   
                                   // Interpolate points between current and last point for smooth erasing
                                   if let last = lastPoint {
                                       let distance = hypot(location.x - last.x, location.y - last.y)
                                       let pointsNeeded = max(1, Int(distance / 5)) // Add points every 5 pts
                                       
                                       if pointsNeeded > 1 {
                                           for i in 1..<pointsNeeded {
                                               let fraction = CGFloat(i) / CGFloat(pointsNeeded)
                                               let interpolatedPoint = CGPoint(
                                                   x: last.x + (location.x - last.x) * fraction,
                                                   y: last.y + (location.y - last.y) * fraction
                                               )
                                               scratchPoints.append(interpolatedPoint)
                                           }
                                       }
                                   }
                                   
                                   // Update tracking grid (in background to maintain performance)
                                   DispatchQueue.global(qos: .userInteractive).async {
                                       self.updateErasedGrid(at: location)
                                       
                                       DispatchQueue.main.async {
                                           // Just to trigger UI update for percentage
                                           self.erasedCells = self.erasedCells
                                       }
                                   }
                                   
                                   lastPoint = location
                               }
                               .onEnded { _ in
                                   lastPoint = nil
                               }
                       )
               }
               
               // Percentage indicator with proper spacing
               VStack() {
                   Text("Erased: \(erasedPercentage, specifier: "%.1f")%")
                       .padding()
                       .background(Color.black)
                       .foregroundColor(.white)
                       .clipShape(Capsule())
               }
               .padding(.horizontal, 15)
               .frame(width: backgroundWidth,alignment: .trailing)
               
               
           }
           .padding(.top, 25)
       }
   }
struct DustRemoverSwiftUIView_Previews2: PreviewProvider {
    static var previews: some View {
        DustRemoverView2(
            backgroundImage: Image("rectangle33"),
            foregroundImage: Image("rectangle35")
        )
    }
}
