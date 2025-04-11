import SwiftUI

// Extend SwiftUI transitions to match our LevelTransition enum
extension AnyTransition {
    static var fade: AnyTransition {
        .opacity
    }
    
    static func cameraPan(edge: Edge) -> AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .move(edge: edge)),
            removal: .opacity.combined(with: .move(edge: edge))
        )
    }
    
    // Convert our enum to SwiftUI's native transitions with fade
    static func fromLevelTransition(_ transition: LevelTransition, edge: Edge = .trailing) -> AnyTransition {
        switch transition {
        case .fade:
            return .opacity
        case .cameraPan:
            return .cameraPan(edge: edge)
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
