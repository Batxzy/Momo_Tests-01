import SwiftUI

// Extend SwiftUI transitions to match our LevelTransition enum
extension AnyTransition {
    static var fade: AnyTransition {
        .opacity
    }
    
    // Carousel-style pan with spacing between views
    static func carouselPan(edge: Edge = .leading, spacing: CGFloat = 40) -> AnyTransition {
        .asymmetric(
            insertion: AnyTransition.offset(x: edge == .leading ? UIScreen.main.bounds.width + spacing : -UIScreen.main.bounds.width - spacing, y: 0)
                .combined(with: .opacity),
            removal: AnyTransition.offset(x: edge == .leading ? -UIScreen.main.bounds.width - spacing : UIScreen.main.bounds.width + spacing, y: 0)
                .combined(with: .opacity)
        )
    }
    
    // Convert our enum to SwiftUI's native transitions, with direction awareness
    static func fromLevelTransition(_ transition: LevelTransition, direction: LevelManager.TransitionDirection = .next) -> AnyTransition {
        switch transition {
        case .fade:
            return .opacity
        case .cameraPan:
            return direction == .next ? 
                .carouselPan(edge: .leading, spacing: 40) : 
                .carouselPan(edge: .trailing, spacing: 40)
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
