import SwiftUI

// Extend SwiftUI transitions to match our LevelTransition enum
extension AnyTransition {
    static var fade: AnyTransition {
        .opacity
    }
    
    // Enhanced carousel-style pan that maintains visibility of adjacent views
    static func carouselPan(edge: Edge = .leading, spacing: CGFloat = 40) -> AnyTransition {
        // Calculate offsets for a more natural carousel feeling
        let screenWidth = UIScreen.main.bounds.width
        let insertionOffset = edge == .leading ? screenWidth * 0.6 : -screenWidth * 0.6
        let removalOffset = edge == .leading ? -screenWidth * 0.6 : screenWidth * 0.6
        
        return .asymmetric(
            insertion: AnyTransition
                .offset(x: insertionOffset, y: 0)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.9, anchor: .center)),
                
            removal: AnyTransition
                .offset(x: removalOffset, y: 0)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.9, anchor: .center))
        )
    }
    
    // Convert our enum to SwiftUI's native transitions, with direction awareness
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
