import SwiftUI

// Extend SwiftUI transitions to match our LevelTransition enum
extension AnyTransition {
    static var fade: AnyTransition {
        .opacity
    }
    
    // Simplified carousel pan with more spacing
    static func carouselPan(edge: Edge = .leading) -> AnyTransition {
        // Calculate offsets for a more natural carousel feeling with greater spacing
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 80 // Large spacing between carousel items
        
        // Create offsets that make views slide in/out with space between them
        let insertionOffset = edge == .leading ? screenWidth + spacing : -(screenWidth + spacing)
        let removalOffset = edge == .leading ? -(screenWidth + spacing) : screenWidth + spacing
        
        return .asymmetric(
            insertion: AnyTransition.offset(x: insertionOffset, y: 0)
                .combined(with: .opacity),
                
            removal: AnyTransition.offset(x: removalOffset, y: 0)
                .combined(with: .opacity)
        )
    }
    
    // Convert our enum to SwiftUI's native transitions
    static func fromLevelTransition(_ transition: LevelTransition, direction: LevelManager.TransitionDirection = .next) -> AnyTransition {
        switch transition {
        case .fade:
            return .opacity
        case .cameraPan:
            return direction == .next ? 
                .carouselPan(edge: .leading) : 
                .carouselPan(edge: .trailing)
        }
    }
}

// Helper to convert our enum to animation duration with spring
extension Animation {
    static func fromLevelTransition(_ transition: LevelTransition) -> Animation {
        switch transition {
        case .fade:
            return .spring(response: 0.6, dampingFraction: 0.8)
        case .cameraPan:
            return .spring(response: 0.7, dampingFraction: 0.8)
        }
    }
}
