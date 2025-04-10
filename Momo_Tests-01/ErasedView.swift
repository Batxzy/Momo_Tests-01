import SwiftUI

struct DustRemoverView: View {
// MARK: - PROPERTIES
    
    //imagenes a usar
    let backgroundImage: Image
    let foregroundImage: Image
    
    // mantengo todas las cordenadas que han sido usdas cuando uso el scratch
    @State private var scratchPoints: [CGPoint] = []
    
    // voy a llorar, la ia me dijo menso, pero tiene sentido aqui se va dividir la imagen en celdas para poder guardar mejor que se borro y que no
    
    //array de dos dimensiones
    @State private var erasedGrid: [[Bool]] = []
    
    //guardar cuantas celdas han sido borradas
    @State private var erasedCells: Int = 0
    
    //para guardar cuantas celdas hay en realidad
    @State private var totalCells: Int = 0
    
    //cuando mide el rectangulo y su poscion en el espacio
    @State private var imageFrame: CGRect = .zero
    
    // Configuration
    private let scratchRadius: CGFloat = 25
    private let gridScale: CGFloat = 8.0  // Each grid cell represents 8x8 pixels
    
    // For interpolation between points to ensure smooth visual effect
    @State private var lastPoint: CGPoint?
    
// MARK: -Funciones y codigo del gird
    
    // Initialize the downsampled grid
    private func initializeGrid() {
        // Ensure we have valid dimensions
        let gridWidth = max(1, Int(ceil(imageFrame.width / gridScale)))
        let gridHeight = max(1, Int(ceil(imageFrame.height / gridScale)))
        
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
        
        // IMPORTANT: Contain the point within the image bounds before processing
        let boundedPoint = CGPoint(
            x: max(0, min(point.x, imageFrame.width)),
            y: max(0, min(point.y, imageFrame.height))
        )
        
        // Skip processing if point is out of bounds (optional, since we bounded it above)
        guard boundedPoint.x >= 0 && boundedPoint.y >= 0 &&
              boundedPoint.x <= imageFrame.width && boundedPoint.y <= imageFrame.height else {
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
    
//MARK: - view
    var body: some View {
        ZStack {
            // Background image
            backgroundImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 400.0, height: 400.0)
                
            
            // Foreground image with scratch mask
            foregroundImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 400.0, height: 400.0)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                imageFrame = geometry.frame(in: .local)
                                initializeGrid()
                            }
                    }
                )
                .mask(
                    // Visual mask - original smooth implementation
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
            
            // Display the erased percentage
            VStack {
                Spacer()
                Text("Erased: \(erasedPercentage, specifier: "%.1f")%")
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding()
            }
        }
    }
    
   
}

struct DustRemoverSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        DustRemoverView(
            backgroundImage: Image("rectangle33"),
            foregroundImage: Image("rectangle35")
        )
    }
}


