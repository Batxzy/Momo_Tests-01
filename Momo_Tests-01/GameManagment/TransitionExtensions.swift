import SwiftUI

// Extend SwiftUI transitions to match our LevelTransition enum
extension AnyTransition {
    static var fade: AnyTransition {
        .opacity
    }
    
    // Improved camera pan that properly shows both views during transition
    static func cameraPan(edge: Edge = .leading) -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: edge),
            removal: .move(edge: edge == .leading ? .trailing : .leading)
        )
    }
    
    // Convert our enum to SwiftUI's native transitions
    static func fromLevelTransition(_ transition: LevelTransition) -> AnyTransition {
        switch transition {
        case .fade:
            return .opacity
        case .cameraPan:
            return .cameraPan(edge: .leading) // Always come in from left side
        }
    }
}

// Helper to convert our enum to animation duration with spring
extension Animation {
    static func fromLevelTransition(_ transition: LevelTransition) -> Animation {
        switch transition {
        case .fade:
            return .spring(response: 0.5, dampingFraction: 0.8)
        case .cameraPan:
            return .spring(response: 0.6, dampingFraction: 0.7)
        }
    }
}
