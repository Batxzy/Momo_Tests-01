import SwiftUI

// Extend SwiftUI transitions to match our LevelTransition enum
extension AnyTransition {
    static var fade: AnyTransition {
        .opacity
    }
    
    // Carousel-style pan with spacing between views
    static func carouselPan(edge: Edge = .leading) -> AnyTransition {
        .asymmetric(
            insertion: AnyTransition.offset(x: edge == .leading ? UIScreen.main.bounds.width : -UIScreen.main.bounds.width, y: 0)
                .combined(with: .opacity),
            removal: AnyTransition.offset(x: edge == .leading ? -UIScreen.main.bounds.width : UIScreen.main.bounds.width, y: 0)
                .combined(with: .opacity)
        )
    }
    
    // Convert our enum to SwiftUI's native transitions
    static func fromLevelTransition(_ transition: LevelTransition) -> AnyTransition {
        switch transition {
        case .fade:
            return .opacity
        case .cameraPan:
            return .carouselPan(edge: .leading)
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
